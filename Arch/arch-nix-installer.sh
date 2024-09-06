#!/bin/bash

# Ensure the user 'deck' has permission to write to the /nix directory
sudo chown -R deck /nix

# Install Nix package manager
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Setup Nix environment
echo "Setting up Nix environment..."
source /home/deck/.nix-profile/etc/profile.d/nix.sh

# Verify installation
nix --version

# Create Nix configuration file to allow unfree packages
mkdir -p ~/.config/nixpkgs
echo "{ allowUnfree = true; }" > ~/.config/nixpkgs/config.nix

# Export XDG_DATA_DIRS to include .nix-profile
echo 'export XDG_DATA_DIRS="/home/deck/.nix-profile/share"' >> ~/.bashrc
source ~/.bashrc

# Create and link vscode desktop file (optional step)
ln -s /home/deck/.nix-profile/share/applications/code.desktop ~/.local/share/applications/
chmod +x ~/.local/share/applications/code.desktop

echo "Nix installation and configuration complete."
