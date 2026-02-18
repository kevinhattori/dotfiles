#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

files=(".tmux.conf" ".zshrc")

for file in "${files[@]}"; do
    target="$HOME/$file"
    source="$DOTFILES_DIR/$file"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -sf "$source" "$target"
    echo "Linked $target -> $source"
done

# Config directories (files nested under ~/.config)
config_dirs=(".config/cava")

for dir in "${config_dirs[@]}"; do
    mkdir -p "$HOME/$(dirname "$dir")"
    target="$HOME/$dir"
    source="$DOTFILES_DIR/$dir"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -sf "$source" "$target"
    echo "Linked $target -> $source"
done
