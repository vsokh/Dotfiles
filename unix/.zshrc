# Path to oh-my-zsh.
export ZSH="$HOME/.oh-my-zsh"

# Theme is set below via `prompt pure`.
ZSH_THEME=""

# Display red dots while waiting for completion.
COMPLETION_WAITING_DOTS="true"

# plugins MUST be set before sourcing oh-my-zsh.sh — it reads the array during source.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# pure prompt
fpath+=$HOME/.zsh/pure
autoload -U compinit promptinit
promptinit
prompt pure
compinit

# vi mode + Tab to accept history suggestion
bindkey -v
bindkey "^I" autosuggest-accept

# apply shell's theme to vim
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# enable preferred theme
base16_gruvbox-dark-soft

export DEV="$HOME/dev"
export EDITOR="nvim"
export TERM=xterm-256color
export HOMEBREW_NO_INSTALL_CLEANUP=1

# underscore cursor in command-line
printf '\033[4 q'

[[ -f $HOME/.aliases ]] && source $HOME/.aliases

# DOTFILES points at the local clone of vsokh/Dotfiles; install.sh exports it via
# the ~/dotfiles symlink. Fall back to common clone locations so a manual clone
# still works.
if [[ -z "$DOTFILES" ]]; then
  for d in "$HOME/dotfiles" "$HOME/Projects/Dotfiles" "$HOME/.dotfiles"; do
    [[ -d "$d/unix" ]] && { export DOTFILES="$d"; break; }
  done
fi
if [[ -n "$DOTFILES" && -d "$DOTFILES/unix/commands" ]]; then
  for f in "$DOTFILES"/unix/commands/*.sh; do
    [[ -f "$f" ]] && source "$f"
  done
fi

# user-local bins (eg. diff-so-fancy installed by install.sh, npm globals)
export PATH="$HOME/.local/bin:$PATH"
