# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

source $ZSH/oh-my-zsh.sh

plugins=(
  git
  zsh-autosuggestions 
  zsh-syntax-highlighting
) 

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Load pure mode prompt
fpath+=$HOME/.zsh/pure

autoload -U compinit promptinit

promptinit
prompt pure

compinit

# enabled vi mode
bindkey -v
bindkey "^I " autosuggest-accept

# apply shell's theme to vim
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# enable preferred theme
base16_onedark


case $(uname) in
Linux)
  export IP=""
  ;;
Darwin)
  export IP=`ipconfig getifaddr en0`
  ;;
*)
  ;;
esac

export DEV="~/dev"
export EDITOR="vim"

#export ANDROID_SDK_ROOT=/usr/local/share/android-sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_SDK_HOME=$ANDROID_SDK_ROOT

export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"

#export ANDROID_NDK_ROOT=/usr/local/share/android-ndk
export ANDROID_NDK_ROOT=$HOME/Library/Android/sdk/ndk
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT
export PATH="/usr/local/opt/python@3.8/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/python@3.8/lib"

export PATH="/usr/local/opt/binutils/bin:$PATH"
export PATH="$HOME/.nimble/bin:$PATH"
export PATH="/Applications/CMake.app/Contents/bin":"$PATH"
export SDL2_ROOT=/usr/local/Cellar/sdl2/2.0.10

export CLAW_ROOT=$HOME/dev/huuuge/claw
export BINGO_SERVER_HOME=$HOME/dev/huuuge/serverbingo
export BINGO_CLIENT_HOME=$HOME/dev/huuuge/gamebingo

export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

export BAT_PAGER="less -R"
export BAT_CONFIG_PATH="$HOME/dotfiles/.bat.conf"

# to enable nice colors in tmux
export TERM=xterm-256color

# to enalbe syntax highlighting for man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias rg='rg -p \
      --colors match:none --colors match:fg:black --colors match:bg:yellow \
      --colors path:fg:green --colors path:style:bold \
      --colors line:fg:yellow --colors line:style:intense --colors line:style:bold \
      "$@" | less -FX'

[[ -f $HOME/.aliases ]] && source $HOME/.aliases
