#!/usr/bin/env bash

<<c
case $(uname) in
Linux)
  pkgmanager="sudo apt"
  ;;
Darwin)
  pkgmanager=brew
  ;;
*)
  ;;
esac
c

pkgmanager=brew

dotfiles=(
  .zshrc
  .zprofile
  .vimrc
  .tmux.conf
  .gitconfig
  .aliases
)

pkgs=(
  curl
  zsh
  shellcheck
  fzf
  tmux
  tldr
  docker
)

dotdir=$HOME/dotfiles

# install all desired pkgs
for p in ${pkgs[@]}; do
  $pkgmanager install $p
done

# create a soft link for each dotfile
for d in ${dotfiles[@]}; do
  src=$dotdir/$d; link=$HOME/$d
  ln -fs "$src" "$link"
done

# -------- VIM -------- #
# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vim plugins
vim +'PlugInstall --sync' +qa
# -------- VIM -------- #

# -------- SHELL -------- #
# install base16-shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# install oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install pure promt --> '>'
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
# -------- SHELL -------- #

# make zsh as a default shell
[[ ! $SHELL =~ .*zsh ]] && chsh -s $(which zsh) $USER

# finish
GREEN='\e[32m'
RESET='\e[0m'

echo -e "${GREEN}We are done! Don't forget to reload your shell!${RESET}"
