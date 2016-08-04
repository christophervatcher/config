#!/bin/sh

# Set shell to zsh if it exists.
if [ -f /bin/zsh ]; then
    usermod -s /bin/zsh `id -un`
fi

cp .gitconfig $HOME/
echo "Configure .gitconfig with user.name, user.email, and user.signingkey."
cp .vimrc $HOME/
cp .zshrc $HOME/
cp .ssh/* $HOME/.ssh/
echo "Configure SSH config with host information."
chmod +x bin/*
chmod -x bin/backup-config.conf
cp bin/* $HOME/bin/
echo "Configure executable files."

