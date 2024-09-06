#!/bin/bash

# Get the current username
USER_NAME=$(whoami)

# Check if the user's Nix profile exists; if not, switch to 'deck'
if [ ! -f "/home/$USER_NAME/.nix-profile/etc/profile.d/nix.sh" ]; then
    echo "Nix profile not found for $USER_NAME, switching to 'deck'"
    USER_NAME="deck"
fi

# Ensure the user has permission to write to the /nix directory
sudo chown -R "$USER_NAME" /nix

# Install Nix package manager
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Setup Nix environment
echo "Setting up Nix environment..."
source "/home/$USER_NAME/.nix-profile/etc/profile.d/nix.sh" || { echo "Failed to source nix.sh for $USER_NAME"; exit 1; }

# Verify installation
nix --version || { echo "Nix command not found after sourcing"; exit 1; }

# Create Nix configuration file to allow unfree packages
mkdir -p ~/.config/nixpkgs
echo "{ allowUnfree = true; }" > ~/.config/nixpkgs/config.nix

# Export XDG_DATA_DIRS to include .nix-profile
echo "export XDG_DATA_DIRS=\"/home/$USER_NAME/.nix-profile/share\"" >> ~/.bashrc
source ~/.bashrc

# Create and link vscode desktop file (optional step)
mkdir -p ~/.local/share/applications
ln -s "/home/$USER_NAME/.nix-profile/share/applications/code.desktop" ~/.local/share/applications/
chmod +x ~/.local/share/applications/code.desktop


# nix activateion manual command is
source ~/.nix-profile/etc/profile.d/nix.sh


# nix permenant activation
source ~/.nix-profile/etc/profile.d/nix.sh
# Add Nix to the environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
fi



echo "Nix installation and configuration complete."
