#!/usr/bin/env bash

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES=(
  home
  ghostty
  lazygit
  nvim
  starship
)

TARGETS=(
  "$HOME/.tmux.conf"
  "$HOME/.wezterm.lua"
  "$HOME/.zshrc"
  "$HOME/.config/ghostty"
  "$HOME/.config/lazygit"
  "$HOME/.config/nvim"
  "$HOME/.config/starship.toml"
)

log_step() {
  printf '\n==> %s\n' "$1"
}

manage_lazygit_macos_config() {
  if [ "$(uname -s)" != "Darwin" ]; then
    return 0
  fi

  local source_config="$HOME/.config/lazygit/config.yml"
  local target_dir="$HOME/Library/Application Support/lazygit"
  local target_config="$target_dir/config.yml"
  local timestamp
  local backup

  mkdir -p "$target_dir"

  if [ -L "$target_config" ] && [ "$(readlink "$target_config")" = "$source_config" ]; then
    return 0
  fi

  if [ -e "$target_config" ]; then
    timestamp="$(date +%Y%m%d%H%M%S)"
    backup="${target_config}.pre-stow-${timestamp}.bak"
    echo "Backing up existing lazygit config: $target_config -> $backup"
    mv "$target_config" "$backup"
  fi

  ln -s "$source_config" "$target_config"
}

remove_lazygit_macos_config() {
  if [ "$(uname -s)" != "Darwin" ]; then
    return 0
  fi

  local source_config="$HOME/.config/lazygit/config.yml"
  local target_config="$HOME/Library/Application Support/lazygit/config.yml"

  if [ -L "$target_config" ] && [ "$(readlink "$target_config")" = "$source_config" ]; then
    rm -f "$target_config"
  fi
}

ensure_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    echo "stow is required but not installed."
    echo "Run ./script/bootstrap first, or install stow manually."
    exit 1
  fi
}

is_dotfiles_link() {
  local path="$1"

  [ -L "$path" ] || return 1

  case "$(readlink "$path")" in
    "$DOTFILES_ROOT"/*) return 0 ;;
    *) return 1 ;;
  esac
}

migrate_conflicting_targets() {
  local path
  local timestamp
  local backup

  timestamp="$(date +%Y%m%d%H%M%S)"

  for path in "${TARGETS[@]}"; do
    if is_dotfiles_link "$path"; then
      echo "Removing legacy dotfiles symlink: $path -> $(readlink "$path")"
      rm -f "$path"
      continue
    fi

    if [ -e "$path" ]; then
      backup="${path}.pre-stow-${timestamp}.bak"
      echo "Backing up existing target: $path -> $backup"
      mv "$path" "$backup"
    fi
  done
}

run_stow_preflight() {
  local -a args=("$@")
  local log_file

  log_file="$(mktemp)"

  if ! stow --simulate --restow --verbose=2 --dir="$DOTFILES_ROOT" --target="$HOME" "${args[@]}" > "$log_file" 2>&1; then
    echo "stow detected conflicts and no changes were applied."
    cat "$log_file"
    rm -f "$log_file"
    echo
    echo "Resolve the conflicting files, then re-run ./script/install."
    exit 1
  fi

  echo "Planned stow changes:"
  cat "$log_file"
  rm -f "$log_file"
}
