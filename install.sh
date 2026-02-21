#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Helpers ──────────────────────────────────────────────────────────────────

info()    { echo "[info]  $*"; }
success() { echo "[ok]    $*"; }
skip()    { echo "[skip]  $*"; }

install_brew_formula() {
    local pkg="$1"
    if brew list --formula "$pkg" &>/dev/null; then
        skip "$pkg already installed"
    else
        info "Installing $pkg..."
        brew install "$pkg" || echo "[warn]  Failed to install $pkg"
    fi
}

install_brew_cask() {
    local pkg="$1"
    if brew list --cask "$pkg" &>/dev/null; then
        skip "$pkg already installed"
    else
        info "Installing $pkg..."
        brew install --cask "$pkg" || echo "[warn]  Failed to install $pkg"
    fi
}

# ── Homebrew ─────────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "[error] Homebrew installation failed. Exiting."
        exit 1
    }
else
    skip "Homebrew already installed"
fi

# ── CLI tools ─────────────────────────────────────────────────────────────────

install_brew_formula archey
install_brew_formula cava
install_brew_formula starship
install_brew_formula tmux

# ── Fonts ─────────────────────────────────────────────────────────────────────

install_brew_cask font-jetbrains-mono-nerd-font

# ── oh-my-zsh ────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
        || echo "[warn]  oh-my-zsh installation failed"
else
    skip "oh-my-zsh already installed"
fi

# ── zsh-syntax-highlighting plugin ───────────────────────────────────────────

ZSH_SYNTAX_PLUGIN="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_SYNTAX_PLUGIN" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_PLUGIN" \
        || echo "[warn]  Failed to clone zsh-syntax-highlighting"
else
    skip "zsh-syntax-highlighting already installed"
fi

# ── Catppuccin tmux plugin ───────────────────────────────────────────────────

CATPPUCCIN_TMUX="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPPUCCIN_TMUX" ]; then
    info "Installing Catppuccin tmux plugin..."
    mkdir -p "$HOME/.config/tmux/plugins/catppuccin"
    git clone https://github.com/catppuccin/tmux.git "$CATPPUCCIN_TMUX" \
        || echo "[warn]  Failed to clone Catppuccin tmux plugin"
else
    skip "Catppuccin tmux plugin already installed"
fi

# ── Symlink dotfiles ──────────────────────────────────────────────────────────

files=(".tmux.conf" ".zshrc" ".config/starship.toml")

for file in "${files[@]}"; do
    target="$HOME/$file"
    source="$DOTFILES_DIR/$file"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        info "Backing up existing $target to $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -sf "$source" "$target"
    success "Linked $target -> $source"
done

# Config directories (files nested under ~/.config)
config_dirs=(".config/cava" ".config/ghostty" ".zsh")

for dir in "${config_dirs[@]}"; do
    mkdir -p "$HOME/$(dirname "$dir")"
    target="$HOME/$dir"
    source="$DOTFILES_DIR/$dir"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        info "Backing up existing $target to $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -sf "$source" "$target"
    success "Linked $target -> $source"
done

echo ""
success "Done! Restart your shell or run: source ~/.zshrc"
