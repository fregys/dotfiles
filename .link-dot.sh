#!/bin/bash

DOTFILES_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
TARGET_DIR="$HOME"

cd "$DOTFILES_DIR" || exit

stow --verbose --no-folding -d "$DOTFILES_DIR" -t "$TARGET_DIR" .
