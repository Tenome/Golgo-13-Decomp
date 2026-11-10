"""Minimal NMOS 6502 interpreter (official opcodes) used to differential-test lifted C routines against the original code.
Memory: 2 KB RAM mirrored through $0000-$1FFF; PRG-ROM: bank 7 fixed at $C000-$FFFF, bank `bank` (0-6) at $8000-$BFFF;
everything else reads 0 (or .io_reads[addr]). Writes to $2000-$FFFF are recorded in .io_writes so tests can compare them;
writes to $8000-$FFFF also drive a small MMC1 model (serial shift register) that follows PRG bank switches ($E000-$FFFF)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

class CPU:
    def __init__(self, prg):
        self.prg = prg; self.ram = bytearray(0x800)
        self.a = self.x = self.y = 0; self.sp = 0xFF; self.pc = 0
        self.c = self.z = self.i = self.d = self.v = self.n = 0
        self.io_writes = []; self.cycles = 0; self.io_reads = {}
        self.bank = 0; self.mmc_shift = 0; self.mmc_count = 0; self.trace = None; self.stray_write = False; self.io_ctr = 0; self.ram_log = None; self.pad = 0xA5; self.pad_idx = 0; self.exec_log = None; self.ram_runs = set(); self._run = []; self._rlast = 0
    # -- memory
    def rd(self, a):
        a &= 0xFFFF
        if a < 0x2000: return self.ram[a & 0x7FF]
        if a >= 0xC000: return self.prg[7 * 0x4000 + (a & 0x3FFF)]
        if a >= 0x8000: return self.prg[self.bank * 0x4000 + (a & 0x3FFF)]
        if a in self.io_reads: return self.io_reads[a]
        n = self.io_ctr; self.io_ctr += 1                     # same pattern as c/core.c io_read
        if a == 0x2002: return (0x80 if n % 3 == 0 else 0) | (0x40 if n % 2 == 0 else 0)
        if a == 0x4016:
            i = self.pad_idx; self.pad_idx += 1
            return (self.pad >> i) & 1 if i < 8 else 1
        if a == 0x4017: return 0
        return 0
    def wr(self, a, v):
        a &= 0xFFFF; v &= 0xFF
        if a < 0x2000: self.ram[a & 0x7FF] = v
        elif a >= 0x2000:
            if a == 0x4016: self.pad_idx = 0
            self.io_writes.append((a, v))
            if a >= 0x8000: self.mmc1(a, v)
    def mmc1(self, a, v):
        if v & 0x80: self.mmc_shift = 0; self.mmc_count = 0; return
        self.mmc_shift |= (v & 1) << self.mmc_count; self.mmc_count += 1
        if self.mmc_count == 5:
            if a >= 0xE000: self.bank = self.mmc_shift & 7      # PRG register (16 KB mode, fixed last bank)
            self.mmc_shift = 0; self.mmc_count = 0
    def rd16(self, a): return self.rd(a) | self.rd((a + 1) & 0xFFFF) << 8
    def rd16zp(self, a): return self.rd(a & 0xFF) | self.rd((a + 1) & 0xFF) << 8
    # -- stack / flags
    def push(self, v): self.wr(0x100 + self.sp, v); self.sp = (self.sp - 1) & 0xFF
    def pull(self): self.sp = (self.sp + 1) & 0xFF; return self.rd(0x100 + self.sp)
    def getp(self, b=0x30): return self.c | self.z << 1 | self.i << 2 | self.d << 3 | self.v << 6 | self.n << 7 | b
    def setp(self, p): self.c = p & 1; self.z = p >> 1 & 1; self.i = p >> 2 & 1; self.d = p >> 3 & 1; self.v = p >> 6 & 1; self.n = p >> 7 & 1
    def nz(self, v): v &= 0xFF; self.z = int(v == 0); self.n = v >> 7; return v
    # -- addressing: returns effective address (or None for implied/acc/imm handled by caller)
    def ea(self, mode):
        pc = self.pc
        if mode == 'imm': self.pc += 1; return pc
        if mode == 'zp': self.pc += 1; return self.rd(pc)
        if mode == 'zpx': self.pc += 1; return (self.rd(pc) + self.x) & 0xFF
        if mode == 'zpy': self.pc += 1; return (self.rd(pc) + self.y) & 0xFF
        if mode == 'abs': self.pc += 2; return self.rd16(pc)
        if mode == 'abx': self.pc += 2; return (self.rd16(pc) + self.x) & 0xFFFF
        if mode == 'aby': self.pc += 2; return (self.rd16(pc) + self.y) & 0xFFFF
        if mode == 'izx': self.pc += 1; return self.rd16zp(self.rd(pc) + self.x)
        if mode == 'izy': self.pc += 1; return (self.rd16zp(self.rd(pc)) + self.y) & 0xFFFF
        if mode == 'ind':
            self.pc += 2; p = self.rd16(pc)
            return self.rd(p) | self.rd((p & 0xFF00) | ((p + 1) & 0xFF)) << 8   # 6502 page-wrap bug
        raise ValueError(mode)
    def adc(self, v):
        r = self.a + v + self.c
        self.v = int((~(self.a ^ v) & (self.a ^ r) & 0x80) != 0); self.c = int(r > 0xFF); self.a = self.nz(r)
    def cmp(self, r, v): self.c = int(r >= v); self.nz(r - v)
    def step(self):
        from g13dis import TAB
        if self.exec_log is not None and self.pc >= 0x8000:   # executed ROM instruction (PRG offset)
            self.exec_log.add(7 * 0x4000 + (self.pc & 0x3FFF) if self.pc >= 0xC000 else self.bank * 0x4000 + (self.pc & 0x3FFF))
        if self.ram_log is not None:
            if self.pc < 0x2000:                               # RAM code: remember each executed instruction with its bytes, and the whole run (one variant of a stub)
                from g13dis import TAB, LENM
                o_ = self.rd(self.pc)
                if o_ in TAB:
                    ins_ = (self.pc, bytes(self.rd(self.pc + i_) for i_ in range(LENM[TAB[o_][1]])).hex())
                    self.ram_log.add(ins_); self._run.append(ins_); self._rlast = o_
            elif self._run and self._rlast != 0x20:             # control left RAM code by JMP / RTS / RTI: the run is complete
                self.ram_runs.add(tuple(sorted(set(self._run)))); self._run = []
        if self.trace is not None: self.trace.append((self.pc, self.a, self.x, self.y, self.c, self.z, self.n))
        op = self.rd(self.pc); self.pc += 1
        if op not in TAB: raise RuntimeError(f'unsupported opcode {op:02X} at {self.pc - 1:04X}')
        n, m = TAB[op]
        if m == 'rel':
            off = self.rd(self.pc); self.pc += 1
            cond = {'bpl': not self.n, 'bmi': self.n, 'bvc': not self.v, 'bvs': self.v, 'bcc': not self.c, 'bcs': self.c, 'bne': not self.z, 'beq': self.z}[n]
            if cond: self.pc = (self.pc + (off - 256 if off > 127 else off)) & 0xFFFF
            return
        if m in ('imp', 'acc'):
            if m == 'acc':
                a = self.a
                if n == 'asl': self.c = a >> 7; self.a = self.nz(a << 1)
                elif n == 'lsr': self.c = a & 1; self.a = self.nz(a >> 1)
                elif n == 'rol': c = self.c; self.c = a >> 7; self.a = self.nz(a << 1 | c)
                elif n == 'ror': c = self.c; self.c = a & 1; self.a = self.nz(a >> 1 | c << 7)
                return
            if n == 'nop': pass
            elif n == 'brk': raise RuntimeError('brk')
            elif n == 'rts': self.pc = (self.pull() | self.pull() << 8) + 1
            elif n == 'rti': self.setp(self.pull()); self.pc = self.pull() | self.pull() << 8
            elif n == 'pha': self.push(self.a)
            elif n == 'php': self.push(self.getp())
            elif n == 'pla': self.a = self.nz(self.pull())
            elif n == 'plp': self.setp(self.pull())
            elif n == 'clc': self.c = 0
            elif n == 'sec': self.c = 1
            elif n == 'cli': self.i = 0
            elif n == 'sei': self.i = 1
            elif n == 'cld': self.d = 0
            elif n == 'sed': self.d = 1
            elif n == 'clv': self.v = 0
            elif n == 'tax': self.x = self.nz(self.a)
            elif n == 'tay': self.y = self.nz(self.a)
            elif n == 'txa': self.a = self.nz(self.x)
            elif n == 'tya': self.a = self.nz(self.y)
            elif n == 'tsx': self.x = self.nz(self.sp)
            elif n == 'txs': self.sp = self.x
            elif n == 'inx': self.x = self.nz(self.x + 1)
            elif n == 'iny': self.y = self.nz(self.y + 1)
            elif n == 'dex': self.x = self.nz(self.x - 1)
            elif n == 'dey': self.y = self.nz(self.y - 1)
            else: raise RuntimeError(n)
            return
        if n == 'jsr':
            t = self.rd16(self.pc); ret = self.pc + 1; self.push(ret >> 8); self.push(ret & 0xFF); self.pc = t; return
        if n == 'jmp': self.pc = self.ea(m); return
        a = self.ea(m)
        if m != 'abs' and a >= 0x8000 and n in ('sta', 'stx', 'sty', 'inc', 'dec', 'asl', 'lsr', 'rol', 'ror'): self.stray_write = True   # a random pointer aimed at ROM: not a mapper write
        if n == 'lda': self.a = self.nz(self.rd(a))
        elif n == 'ldx': self.x = self.nz(self.rd(a))
        elif n == 'ldy': self.y = self.nz(self.rd(a))
        elif n == 'sta': self.wr(a, self.a)
        elif n == 'stx': self.wr(a, self.x)
        elif n == 'sty': self.wr(a, self.y)
        elif n == 'adc': self.adc(self.rd(a))
        elif n == 'sbc': self.adc(self.rd(a) ^ 0xFF)
        elif n == 'and': self.a = self.nz(self.a & self.rd(a))
        elif n == 'ora': self.a = self.nz(self.a | self.rd(a))
        elif n == 'eor': self.a = self.nz(self.a ^ self.rd(a))
        elif n == 'cmp': self.cmp(self.a, self.rd(a))
        elif n == 'cpx': self.cmp(self.x, self.rd(a))
        elif n == 'cpy': self.cmp(self.y, self.rd(a))
        elif n == 'bit': v = self.rd(a); self.z = int((self.a & v) == 0); self.n = v >> 7; self.v = v >> 6 & 1
        elif n == 'inc': self.wr(a, self.nz(self.rd(a) + 1))
        elif n == 'dec': self.wr(a, self.nz(self.rd(a) - 1))
        elif n in ('asl', 'lsr', 'rol', 'ror'):
            v = self.rd(a)
            if n == 'asl': self.c = v >> 7; r = v << 1
            elif n == 'lsr': self.c = v & 1; r = v >> 1
            elif n == 'rol': c = self.c; self.c = v >> 7; r = v << 1 | c
            else: c = self.c; self.c = v & 1; r = v >> 1 | c << 7
            self.wr(a, self.nz(r))
        else: raise RuntimeError(n)
    def call(self, addr, a=0, x=0, y=0, c=0, max_steps=400000):
        """Run the routine at addr (JSR-style) until it returns; returns (a, x, y, carry)."""
        self.a, self.x, self.y, self.c = a, x, y, c; self.sp = 0xFF
        self.push(0xFF); self.push(0xFD)          # return to $FFFE (RTS adds 1)
        self.pc = addr
        for _ in range(max_steps):
            if self.pc == 0xFFFE: return self.a, self.x, self.y, self.c
            self.step()
        raise RuntimeError('routine did not return')
