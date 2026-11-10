# Build the native Windows executable (static recompilation via NESRecomp) for one version.
#   .\recomp\build_native.ps1 -Version us -NesRecomp C:\path\to\nesrecomp [-Headless]
# Needs: Python 3.11+, CMake, Visual Studio with C++ (adjust -Generator), a clone of https://github.com/mstan/nesrecomp,
# and your ROM at orig\golgo13_<version>.nes. Output: build\native\<version>\golgo13-<version>.exe
param([ValidateSet('us','jp')][string]$Version = 'us', [Parameter(Mandatory)][string]$NesRecomp,
      [string]$Generator = 'Visual Studio 17 2022', [switch]$Headless)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$rom  = (Join-Path $root "orig\golgo13_$Version.nes").Replace('\','/')
$work = Join-Path $root "build\native\$Version"; New-Item -ItemType Directory -Force $work | Out-Null
$seeds = Join-Path $work 'seeds.txt'
python (Join-Path $root 'tools\make_seeds.py') --version $Version $seeds
$toml = Join-Path $work 'game.toml'
@"
[game]
output_prefix = "golgo13-$Version"
cycle_accurate = true
cycle_seed_file = "$($seeds.Replace('\','/'))"
"@ | Set-Content $toml -Encoding ascii
$bd = Join-Path $work ($(if ($Headless) {'cmake_headless'} else {'cmake'}))
$cfg = @('-S', (Join-Path $NesRecomp 'runner\cyc\project'), '-B', $bd, '-G', $Generator, '-A', 'x64',
         "-DNESRECOMP_ROM=$rom", "-DNESRECOMP_GAME_CONFIG=$($toml.Replace('\','/'))")
if ($Headless) { $cfg += '-DNESRECOMP_HEADLESS=ON' }
cmake @cfg
cmake --build $bd --config Release --parallel
$outName = if ($Headless) { "golgo13-$Version-headless.exe" } else { "golgo13-$Version.exe" }
Copy-Item (Join-Path $bd 'Release\nes_game.exe') (Join-Path $work $outName) -Force
"Built $work\$outName  (run it with your ROM: golgo13-$Version.exe `"$($rom.Replace('/','\'))`")"
