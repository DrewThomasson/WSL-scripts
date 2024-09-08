#!/bin/bash

# Get the current username
USER_NAME=$(whoami)

# Check if Nix is installed
if [ ! -d "/nix" ]; then
    echo "Nix is not installed."
    exit 0
fi

# Ask the user if they want to proceed with uninstallation
read -p "Do you want to uninstall Nix and all its applications, freeing up space? [y/N]: " confirm_uninstall
if [[ ! "$confirm_uninstall" =~ ^[Yy]$ ]]; then
    echo "Uninstallation canceled."
    exit 0
fi

# Step 1: Uninstall all Nix applications
echo "Uninstalling all Nix applications..."
nix-env --query --installed | cut -d' ' -f1 | xargs -n1 nix-env -e
echo "All Nix applications have been removed."

# Step 2: Remove Nix store and directories
echo "Removing Nix store and associated files..."
sudo rm -rf /nix
echo "Nix store and files removed."

# Step 3: Remove Nix profiles and user-specific configurations
echo "Removing Nix profiles and configurations from the home directory..."
rm -rf "/home/$USER_NAME/.nix-profile"
rm -rf "/home/$USER_NAME/.config/nixpkgs"
echo "Nix profiles and configurations removed."

# Step 4: Remove Nix-related environment variables from .bashrc
echo "Cleaning up .bashrc..."
sed -i '/nix-profile/d' ~/.bashrc
sed -i '/XDG_DATA_DIRS.*nix-profile/d' ~/.bashrc
source ~/.bashrc
echo "Nix-related environment variables removed from .bashrc."

# Step 5: Remove VSCode desktop file if it exists
echo "Removing VSCode desktop file..."
rm -f ~/.local/share/applications/code.desktop
echo "VSCode desktop file removed."

echo "Nix uninstallation complete. All space used by Nix has been freed."
