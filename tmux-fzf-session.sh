#!/usr/bin/env bash
# Fuzzy-pick a tmux session and attach (used from display-popup in .tmux.conf).
set -euo pipefail
session="$(tmux list-sessions -F '#{session_name}' | fzf --reverse)"
[[ -n "${session}" ]] && tmux switch-client -t "${session}"
