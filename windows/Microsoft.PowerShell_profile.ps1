# Oh My Posh - Fancy prompt with catppuccin_mocha theme
oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json" | Invoke-Expression

# Terminal-Icons - File icons in directory listings
Import-Module Terminal-Icons

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

# PSReadLine: vi mode + history prediction + Tab to accept suggestion (falls back to normal completion)
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    $line = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
    $newLine = $null; $newCursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$newLine, [ref]$newCursor)
    if ($newLine -eq $line) {
        [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
    }
}

# ===== nvim+powershell dev environment =====

# git status segments + tab completion
Import-Module posh-git

# Ctrl-T: fuzzy file picker. Ctrl-R: fuzzy history.
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# zoxide: smart `cd` with frecency. Use `z <part-of-path>` to jump.
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# editor
$env:EDITOR = 'nvim'

# single-letter aliases (zsh muscle memory)
Set-Alias g  git
Set-Alias v  nvim
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
Set-Alias ls eza
function ll { eza -la --git --icons @args }
function la { eza -a --icons @args }

# config edit shortcuts (vz/vv/vg/sz from your zshrc)
function vz { nvim $PROFILE }
function vv { nvim "$env:LOCALAPPDATA\nvim\init.lua" }
function vg { nvim "$HOME\.gitconfig" }
function sz { . $PROFILE }

# project dirs
function sb  { Set-Location "$HOME\Projects\sandbox" }
function dot { Set-Location "$HOME\Projects" }
