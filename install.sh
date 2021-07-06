#!/usr/bin/env bash

install_pkgs() {
    OS=$(uname)
    if   [ "$OS" = "Linux"  ]; then pkgmanager=sudo apt
    elif [ "$OS" = "Darwin" ]; then pkgmanager=brew
    else
        echo "You need to setup a pkgmanager manually for this system.";
        exit 1;
    fi

    pkgs=(
      curl zsh fzf fd shellcheck tmux tldr docker ripgrep
    )

    for p in "${pkgs[@]}"; do
      "$pkgmanager" install "$p"
    done
}

link_configs() {
    dotfiles=(
        .zshrc .zprofile .vimrc .tmux.conf .gitconfig .aliases
    )
    dotdir=$HOME/dotfiles

    for d in "${dotfiles[@]}"; do
      src="$dotdir/$d"; link="$HOME/$d"
      ln -fs "$src" "$link"
    done
}

setup_vim() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +'PlugInstall --sync' +qa
}

setup_shell() {
    git clone https://github.com/chriskempson/base16-shell.git          \
        ~/.config/base16-shell

    git clone https://github.com/ohmyzsh/ohmyzsh.git                    \
        ~/.oh-my-zsh

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  \
        "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

    git clone https://github.com/zsh-users/zsh-autosuggestions          \
        "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

    # install pure promt '>'
    git clone https://github.com/sindresorhus/pure.git                  \
        "$HOME/.zsh/pure"

    # make zsh as a default shell
    [[ ! $SHELL =~ .*zsh ]] && chsh -s "$(command -v zsh)" "$USER"
}

completion() {
    GREEN='\e[32m'
    RESET='\e[0m'

    echo -e "${GREEN}We've done! Don't forget to reload your shell!${RESET}"
}

install_pkgs
link_configs
setup_vim
setup_shell
completion
