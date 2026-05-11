# dotfiles

Personal configs for daily work. Three platforms, one tree.

```
common/         # cross-platform configs (gitconfig, tmux, nvim)
unix/           # Linux + macOS: zsh, aliases, install.sh, helper commands
windows/        # PowerShell profile, install.ps1
```

The Neovim config (`common/nvim/init.lua`) is identical everywhere:
Catppuccin Mocha + treesitter + LSP (clangd / rust_analyzer / ts_ls).
No autocomplete engine — LSP is a reference tool, not a suggestion engine.

## Install

**Linux / macOS:**
```sh
git clone https://github.com/vsokh/Dotfiles.git ~/dotfiles
cd ~/dotfiles/unix && ./install.sh
```

**Windows:**
```powershell
winget install Git.Git Microsoft.PowerShell JanDeDobbeleer.OhMyPosh
git clone https://github.com/vsokh/Dotfiles.git $HOME\Projects\Dotfiles
cd $HOME\Projects\Dotfiles\windows
pwsh -File .\install.ps1
```

Both installers are idempotent — re-run any time to redeploy after edits.
