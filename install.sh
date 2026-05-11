#!/usr/bin/env bash
# Idempotent dotfiles installer for Linux (apt) and macOS (brew).
# Safe to re-run: each step skips work that's already done.

set -e

OS="$(uname)"
DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

log()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m  OK\033[0m %s\n' "$*"; }
skip() { printf '\033[90m  --\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  !!\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
install_pkgs() {
    log "Installing packages"
    local pkgs=(curl zsh fzf fd-find shellcheck tmux tldr ripgrep diff-so-fancy git)
    # macOS uses 'fd', Debian/Ubuntu ships 'fd-find' (binary is 'fdfind'); resolved per-OS.

    case "$OS" in
        Linux)
            if ! command -v apt-get >/dev/null; then
                warn "apt-get not found; install packages manually: ${pkgs[*]}"
                return
            fi
            sudo apt-get update -y
            # Linux package names differ slightly
            sudo apt-get install -y \
                curl zsh fzf fd-find shellcheck tmux tldr ripgrep git
            # diff-so-fancy: not in apt; install via npm or as a standalone perl script
            if ! command -v diff-so-fancy >/dev/null; then
                warn "diff-so-fancy not in apt; install separately if needed:"
                warn "  curl -L https://github.com/so-fancy/diff-so-fancy/releases/latest/download/diff-so-fancy -o ~/.local/bin/diff-so-fancy && chmod +x ~/.local/bin/diff-so-fancy"
            fi
            ;;
        Darwin)
            if ! command -v brew >/dev/null; then
                warn "Homebrew not found; install from https://brew.sh first"
                return
            fi
            for p in curl zsh fzf fd shellcheck tmux tldr ripgrep diff-so-fancy git; do
                if brew list --formula "$p" >/dev/null 2>&1; then
                    skip "$p already installed"
                else
                    brew install "$p"
                fi
            done
            ;;
        *)
            warn "Unsupported OS: $OS — install packages manually: ${pkgs[*]}"
            ;;
    esac
}

# ---------------------------------------------------------------------------
link_configs() {
    log "Linking dotfiles into \$HOME"
    local dotfiles=(.zshrc .zprofile .vimrc .tmux.conf .gitconfig .aliases .hgrc)
    for d in "${dotfiles[@]}"; do
        local src="$DOTDIR/$d"
        local dst="$HOME/$d"
        if [[ ! -f "$src" ]]; then
            warn "missing source $src — skipping"
            continue
        fi
        # If dst is already the right symlink, do nothing.
        if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
            skip "$dst -> $src"
            continue
        fi
        # If dst exists and isn't a symlink to src, back it up first.
        if [[ -e "$dst" || -L "$dst" ]]; then
            local bak
            bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
            mv "$dst" "$bak"
            skip "backed up existing $dst -> $bak"
        fi
        ln -s "$src" "$dst"
        ok "linked $dst"
    done
}

# ---------------------------------------------------------------------------
setup_vim() {
    log "Setting up vim-plug + plugins"
    local plug="$HOME/.vim/autoload/plug.vim"
    if [[ -f "$plug" ]]; then
        skip "vim-plug already installed"
    else
        curl -fsSLo "$plug" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        ok "vim-plug installed"
    fi
    vim +'PlugInstall --sync' +qa || warn "vim PlugInstall failed; run it manually"
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
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git           "$HOME/.oh-my-zsh"
    clone_if_missing https://github.com/chriskempson/base16-shell.git "$HOME/.config/base16-shell"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions          "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    clone_if_missing https://github.com/sindresorhus/pure.git         "$HOME/.zsh/pure"

    # Make zsh the default shell if it isn't already.
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    if [[ -z "$zsh_path" ]]; then
        warn "zsh not installed — skipping chsh"
    elif [[ "$SHELL" == "$zsh_path" ]]; then
        skip "zsh is already the default shell"
    else
        # /etc/shells must include zsh for chsh to accept it.
        if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
        fi
        chsh -s "$zsh_path" "$USER" && ok "default shell set to $zsh_path" \
            || warn "chsh failed; set default shell manually"
    fi
}

# ---------------------------------------------------------------------------
completion() {
    printf '\n\033[32m==> Done.\033[0m Restart your shell (or `exec zsh`) to pick up changes.\n'
}

install_pkgs
link_configs
setup_vim
setup_shell
completion
