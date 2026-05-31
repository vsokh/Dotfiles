# Windows dev environment

PowerShell 7 + Neovim + Catppuccin Mocha. AI-free (no Copilot, no Codeium, no
auto-popups). LSP for go-to-definition + hover docs only.

## What's here

| File | Goes to |
|---|---|
| `Microsoft.PowerShell_profile.ps1` | `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| `windows-terminal-settings.json` | `…\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| `..\common\nvim\init.lua` | `$env:LOCALAPPDATA\nvim\init.lua` |
| `install.ps1` | runs locally |

### Windows Terminal pane navigation

`Ctrl+Shift+h/j/k/l` moves focus left/down/up/right between split panes
(vim-style). Chosen over plain `Ctrl+hjkl` on purpose: Terminal grabs keybindings
*before* the running app, and `Ctrl+hjkl` is already nvim's window-navigation
(`common/nvim/init.lua`), so the `Shift` keeps the two from colliding. The
default `Alt+arrows` still work too.

Note: Windows Terminal rewrites `settings.json` whenever you change something in
its GUI, so the live file can drift from the repo copy. After tweaking settings
in the UI, copy it back:
`Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" .\windows-terminal-settings.json`

The Neovim config is shared with Linux/macOS — it lives in `..\common\nvim\`
at the repo root.

## Fresh-machine bootstrap

1. Install git (`winget install Git.Git`) and PowerShell 7 (`winget install Microsoft.PowerShell`).
2. `git clone https://github.com/vsokh/Dotfiles.git`
3. `cd Dotfiles\windows && pwsh -File .\install.ps1`

The script installs scoop, the CLI toolchain (neovim, ripgrep, fd, fzf, bat,
eza, zoxide, delta, cmake, ninja, llvm, gh), PowerShell modules (posh-git,
Terminal-Icons, PSFzf), copies the config files into place (backing up
existing ones with a timestamp), and bootstraps lazy.nvim + treesitter
parsers. Re-running is safe; it skips work that's already done.

## Optional, not auto-installed

- **oh-my-posh** (used by the profile prompt) — `winget install JanDeDobbeleer.OhMyPosh`
- **Node.js** (needed for TypeScript LSP) — `winget install OpenJS.NodeJS.LTS`
- **rustup** (needed for Rust LSP) — install from <https://rustup.rs/>

The script detects whether these are present and runs the relevant follow-ups
(npm install, `rustup component add rust-analyzer`).

## Updating after editing in the repo

Re-run `pwsh -File .\install.ps1`. It compares hashes and only copies files
that actually changed.
