#!/bin/bash

DOTFILES_DIR="$HOME/github/dotfiles"

# Function to backup or delete existing files/dirs
backup_or_delete() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        read -p "Existing $target found. Backup (b) or delete (d)? " choice
        case $choice in
            b|B)
                echo "Backing up $target to $target.bak"
                mv "$target" "$target.bak"
                ;;
            d|D)
                echo "Deleting $target"
                rm -rf "$target"
                ;;
            *)
                echo "Skipping $target"
                return 1
                ;;
        esac
    fi
    return 0
}

# List symlinks pointing to dotfiles
list_symlinks() {
    echo "Active symlinks pointing to $DOTFILES_DIR:"
    find "$HOME" -type l 2>/dev/null | while read link; do
        target=$(readlink "$link")
        if [[ "$target" == *"$DOTFILES_DIR"* ]]; then
            echo "$link -> $target"
        fi
    done
}

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

# Check arguments
if [ "$1" == "--list" ]; then
    list_symlinks
    exit 0
fi

# Install symlinks
echo "Installing dotfiles symlinks..."

targets=(
    "$HOME/.tmux.conf"
    "$HOME/.wezterm.lua"
    "$HOME/.zshrc"
    "$HOME/.config/starship.toml"
    "$HOME/.config/ghostty"
    "$HOME/.config/kitty"
    "$HOME/.config/nvim"
)

for target in "${targets[@]}"; do
    read -p "Link $target? (y/n): " link_choice
    if [[ $link_choice =~ ^[Yy]$ ]]; then
        if backup_or_delete "$target"; then
            source_file=$(basename "$target")
            if [[ "$target" == "$HOME/.config/"* ]]; then
                ln -sf "$DOTFILES_DIR/$source_file" "$target"
                echo "Linked $target"
            else
                ln -sf "$DOTFILES_DIR/$source_file" "$target"
                echo "Linked $target"
            fi
        fi
    else
        echo "Skipped $target"
    fi
done

echo "Dotfiles installation complete. Changes in $DOTFILES_DIR will reflect in real-time."
