# Windows dev environment installer.
# Usage:  pwsh -File .\install.ps1
# Idempotent — safe to re-run.

#Requires -Version 7.0

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function H1($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "  OK  $msg" -ForegroundColor Green }
function Note($msg) { Write-Host "  --  $msg" -ForegroundColor DarkGray }
function Warn($msg) { Write-Host "  !!  $msg" -ForegroundColor Yellow }

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' +
                [Environment]::GetEnvironmentVariable('Path','Machine')
}

# ---------------------------------------------------------------------------
H1 'ExecutionPolicy'
# ---------------------------------------------------------------------------
$ep = Get-ExecutionPolicy -Scope CurrentUser
if ($ep -in @('Undefined','Restricted','AllSigned')) {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    Ok "set CurrentUser policy to RemoteSigned (was $ep)"
} else {
    Ok "already $ep"
}

# ---------------------------------------------------------------------------
H1 'scoop'
# ---------------------------------------------------------------------------
if (-not (Get-Command scoop -EA SilentlyContinue)) {
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
    Refresh-Path
    Ok 'scoop installed'
} else {
    Ok 'scoop already installed'
}

scoop bucket add extras 2>&1 | Out-Null
Ok 'extras bucket present'

# ---------------------------------------------------------------------------
H1 'scoop packages'
# ---------------------------------------------------------------------------
$packages = @(
    @{ Name = 'neovim';  Cmd = 'nvim'  },
    @{ Name = 'ripgrep'; Cmd = 'rg'    },
    @{ Name = 'fd';      Cmd = 'fd'    },
    @{ Name = 'fzf';     Cmd = 'fzf'   },
    @{ Name = 'bat';     Cmd = 'bat'   },
    @{ Name = 'eza';     Cmd = 'eza'   },
    @{ Name = 'zoxide';  Cmd = 'zoxide'},
    @{ Name = 'delta';   Cmd = 'delta' },
    @{ Name = 'cmake';   Cmd = 'cmake' },
    @{ Name = 'ninja';   Cmd = 'ninja' },
    @{ Name = 'llvm';    Cmd = 'clang' },
    @{ Name = 'gh';      Cmd = 'gh'    }
)
foreach ($p in $packages) {
    $name = $p.Name; $cmd = $p.Cmd
    # Skip if the command is already on PATH (covers other installers like winget),
    # or scoop has already installed it (covers PATH not yet refreshed).
    if ((Get-Command $cmd -EA SilentlyContinue) -or (Test-Path "$HOME\scoop\apps\$name")) {
        Note "$name already present"
    } else {
        Write-Host "  installing $name ..."
        scoop install $name
    }
}
Refresh-Path

# ---------------------------------------------------------------------------
H1 'PowerShell modules'
# ---------------------------------------------------------------------------
$modules = @('posh-git', 'Terminal-Icons', 'PSFzf')
foreach ($m in $modules) {
    if (Get-Module -ListAvailable -Name $m) {
        Note "$m already installed"
    } else {
        Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber
        Ok "$m installed"
    }
}

# ---------------------------------------------------------------------------
H1 'oh-my-posh'
# ---------------------------------------------------------------------------
if (Get-Command oh-my-posh -EA SilentlyContinue) {
    Ok 'oh-my-posh already available'
} else {
    Warn 'oh-my-posh missing; install via:  winget install JanDeDobbeleer.OhMyPosh'
    Warn 'or:  scoop install oh-my-posh'
}

# ---------------------------------------------------------------------------
H1 'TypeScript language server (optional, needs Node)'
# ---------------------------------------------------------------------------
if (Get-Command npm -EA SilentlyContinue) {
    if (Get-Command typescript-language-server -EA SilentlyContinue) {
        Note 'typescript-language-server already installed'
    } else {
        npm install -g typescript typescript-language-server
        Ok 'typescript + typescript-language-server installed globally'
    }
} else {
    Warn 'Node.js not found; install it for TypeScript LSP support'
    Warn '  winget install OpenJS.NodeJS.LTS'
}

# ---------------------------------------------------------------------------
H1 'rust-analyzer (optional, needs rustup)'
# ---------------------------------------------------------------------------
if (Get-Command rust-analyzer -EA SilentlyContinue) {
    Ok 'rust-analyzer already available'
} elseif (Get-Command rustup -EA SilentlyContinue) {
    rustup component add rust-analyzer
    Ok 'rust-analyzer installed via rustup'
} else {
    Warn 'rustup not found; for Rust LSP, install rustup from https://rustup.rs/'
}

# ---------------------------------------------------------------------------
H1 'Deploy configs'
# ---------------------------------------------------------------------------
function Deploy-File($src, $dst) {
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }

    if (Test-Path $dst) {
        $hashSrc = (Get-FileHash $src).Hash
        $hashDst = (Get-FileHash $dst).Hash
        if ($hashSrc -eq $hashDst) {
            Note "$dst already up-to-date"
            return
        }
        $bak = "$dst.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $dst $bak
        Note "backup -> $bak"
    }
    Copy-Item $src $dst -Force
    Ok "deployed $dst"
}

Deploy-File "$here\Microsoft.PowerShell_profile.ps1" `
            "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

Deploy-File "$here\nvim\init.lua" `
            "$env:LOCALAPPDATA\nvim\init.lua"

# ---------------------------------------------------------------------------
H1 'Bootstrap Neovim plugins + treesitter parsers'
# ---------------------------------------------------------------------------
$lazyPath    = "$env:LOCALAPPDATA\nvim-data\lazy\lazy.nvim"
$parserDir   = "$env:LOCALAPPDATA\nvim-data\lazy\nvim-treesitter\parser"
$wantParsers = @(
    'c','cpp','cmake','make','lua','vim','vimdoc','powershell','bash',
    'json','jsonc','yaml','toml','markdown','markdown_inline',
    'python','rust','javascript','typescript','tsx','html','css',
    'gitcommit','diff'
)

if (-not (Get-Command nvim -EA SilentlyContinue)) {
    Warn 'nvim not on PATH; open a new shell and re-run this script.'
}
else {
    # Step 1: clone plugins only if lazy.nvim is missing
    if (-not (Test-Path $lazyPath)) {
        Write-Host '  cloning plugins via lazy.nvim ...'
        nvim --headless '+Lazy! sync' +qa 2>&1 | Out-Null
        Ok 'plugins cloned'
    } else {
        Note 'plugins already cloned'
    }

    # Step 2: install only missing parsers
    $haveParsers = @()
    if (Test-Path $parserDir) {
        $haveParsers = Get-ChildItem $parserDir -Filter '*.so' |
            ForEach-Object { $_.BaseName }
    }
    $missing = $wantParsers | Where-Object { $_ -notin $haveParsers }

    if ($missing.Count -gt 0) {
        Write-Host "  compiling $($missing.Count) missing treesitter parsers ..."
        $arg = '+TSInstallSync ' + ($missing -join ' ')
        nvim --headless $arg +qa 2>&1 | Out-Null
    }

    $finalCount = if (Test-Path $parserDir) {
        (Get-ChildItem $parserDir -Filter '*.so').Count
    } else { 0 }
    Ok "nvim bootstrap done ($finalCount parsers installed)"
}

# ---------------------------------------------------------------------------
H1 'Done'
# ---------------------------------------------------------------------------
Write-Host @'

  Open a fresh PowerShell window so the new profile loads.
  Try:  ll        # eza file list with git status
        z proj    # smart cd (zoxide)
        Ctrl-T    # fzf file picker
        Ctrl-R    # fzf history
        v file    # nvim alias
        vz        # edit profile
        vv        # edit nvim init

  In nvim:  <space>f  files     <space>g  grep
            gd        go to def     K       hover docs
            :vsp      vertical split
'@ -ForegroundColor Green
