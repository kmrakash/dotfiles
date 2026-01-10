#!/bin/bash

DOTFILES_DIR="$HOME/github/dotfiles"

# Function to remove symlink and restore backup
remove_and_restore() {
    local target="$1"
    if [ -L "$target" ]; then
        target_path=$(readlink "$target")
        if [[ "$target_path" == *"$DOTFILES_DIR"* ]]; then
            echo "Removing symlink $target"
            rm "$target"
            backup="$target.bak"
            if [ -e "$backup" ]; then
                echo "Restoring from $backup"
                mv "$backup" "$target"
            fi
        else
            echo "Skipping $target (not pointing to dotfiles)"
        fi
    else
        echo "Skipping $target (not a symlink)"
    fi
}

echo "Uninstalling dotfiles symlinks..."

targets=(
    "$HOME/.tmux.conf"
    "$HOME/.wezterm.lua"
    "$HOME/.zshrc"
    "$HOME/.config/ghostty"
    "$HOME/.config/kitty"
    "$HOME/.config/nvim"
)

for target in "${targets[@]}"; do
    remove_and_restore "$target"
done

echo "Uninstall complete."