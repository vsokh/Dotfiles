#!/usr/bin/env bash
# Idempotent dotfiles installer for Linux (apt) and macOS (brew).
# Safe to re-run: each step skips work that's already done.

set -e

OS="$(uname)"
DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$DOTDIR/.." && pwd)"
COMMON="$REPO/common"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

log()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m  OK\033[0m %s\n' "$*"; }
skip() { printf '\033[90m  --\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  !!\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
install_pkgs() {
    log "Installing packages"
    case "$OS" in
        Linux)
            if ! command -v apt-get >/dev/null; then
                warn "apt-get not found; install these manually:"
                warn "  curl zsh fzf fd-find shellcheck tmux tlrc ripgrep neovim git-delta"
                return
            fi
            sudo apt-get update -y
            sudo apt-get install -y \
                curl zsh fzf fd-find shellcheck tmux tlrc ripgrep neovim git \
                git-delta build-essential
            # On Debian/Ubuntu fd ships as 'fdfind'. Symlink so scripts using 'fd' work.
            if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
                mkdir -p "$HOME/.local/bin"
                ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
                ok "linked fdfind -> ~/.local/bin/fd"
            fi
            ;;
        Darwin)
            if ! command -v brew >/dev/null; then
                warn "Homebrew not found; install from https://brew.sh first"
                return
            fi
            for p in curl zsh fzf fd shellcheck tmux tlrc ripgrep git-delta git neovim eza zoxide; do
                if brew list --formula "$p" >/dev/null 2>&1; then
                    skip "$p already installed"
                else
                    brew install "$p"
                fi
            done
            ;;
        *)
            warn "Unsupported OS: $OS — install packages manually"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Create a symlink; backs up an existing target unless it already points at src.
symlink() {
    local src="$1" dst="$2"
    if [[ ! -e "$src" && ! -L "$src" ]]; then
        warn "missing source $src — skipping"
        return
    fi
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        skip "$dst -> $src"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        local bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$dst" "$bak"
        skip "backed up existing $dst -> $bak"
    fi
    ln -s "$src" "$dst"
    ok "linked $dst -> $src"
}

link_configs() {
    log "Linking dotfiles into \$HOME"

    # Unix-only configs.
    symlink "$DOTDIR/.zshrc"    "$HOME/.zshrc"
    symlink "$DOTDIR/.zprofile" "$HOME/.zprofile"
    symlink "$DOTDIR/.aliases"  "$HOME/.aliases"

    # Cross-platform configs.
    symlink "$COMMON/.tmux.conf" "$HOME/.tmux.conf"
    symlink "$COMMON/.gitconfig" "$HOME/.gitconfig"
    symlink "$COMMON/nvim/init.lua" "$HOME/.config/nvim/init.lua"

    # zshrc DOTFILES discovery looks at $HOME/dotfiles — point it at the repo.
    symlink "$REPO" "$HOME/dotfiles"
}

# ---------------------------------------------------------------------------
setup_nvim() {
    log "Bootstrapping Neovim plugins + treesitter parsers"
    if ! command -v nvim >/dev/null; then
        warn "nvim not installed; skipping"
        return
    fi

    local lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
    local parser_dir="$HOME/.local/share/nvim/lazy/nvim-treesitter/parser"
    local want=(c cpp cmake make lua vim vimdoc bash json jsonc yaml toml
                markdown markdown_inline python rust javascript typescript tsx
                html css gitcommit diff)

    if [[ ! -d "$lazy_path" ]]; then
        nvim --headless '+Lazy! sync' +qa
        ok "plugins cloned"
    else
        skip "plugins already cloned"
    fi

    # Diff against installed parsers; only install missing ones.
    local missing=()
    if [[ -d "$parser_dir" ]]; then
        for p in "${want[@]}"; do
            [[ -f "$parser_dir/$p.so" ]] || missing+=("$p")
        done
    else
        missing=("${want[@]}")
    fi
    if (( ${#missing[@]} > 0 )); then
        log "compiling ${#missing[@]} missing treesitter parsers"
        nvim --headless "+TSInstallSync ${missing[*]}" +qa
    fi
    ok "nvim bootstrap complete"
}

# ---------------------------------------------------------------------------
clone_if_missing() {
    local url="$1" dst="$2"
    if [[ -d "$dst/.git" ]]; then
        skip "$dst already cloned"
    else
        git clone --depth=1 "$url" "$dst"
        ok "cloned $dst"
    fi
}

setup_shell() {
    log "Installing oh-my-zsh, plugins, base16-shell, pure prompt"
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git                   "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/chriskempson/base16-shell.git         "$HOME/.config/base16-shell"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions         "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    clone_if_missing https://github.com/sindresorhus/pure.git                 "$HOME/.zsh/pure"

    # Make zsh the default shell if it isn't already.
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    if [[ -z "$zsh_path" ]]; then
        warn "zsh not installed — skipping chsh"
    elif [[ "$SHELL" == "$zsh_path" ]]; then
        skip "zsh is already the default shell"
    else
        if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
        fi
        chsh -s "$zsh_path" "$USER" && ok "default shell set to $zsh_path" \
            || warn "chsh failed; set default shell manually"
    fi
}

# ---------------------------------------------------------------------------
completion() {
    printf '\n\033[32m==> Done.\033[0m Restart your shell (or run: exec zsh) to pick up changes.\n\n'
    printf '  Optional next steps for LSP in nvim:\n'
    printf '    C/C++:   apt install clangd   (Linux)  /  brew install llvm  (macOS)\n'
    printf '    Rust:    rustup component add rust-analyzer\n'
    printf '    TS/JS:   npm install -g typescript typescript-language-server\n'
}

install_pkgs
link_configs
setup_nvim
setup_shell
completion
