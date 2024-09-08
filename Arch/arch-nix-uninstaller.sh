#!/bin/bash

# Get the current username
USER_NAME=$(whoami)

# Check if Nix is installed
if [ ! -d "/nix" ]; then
    echo "Nix is not installed."
    exit 0
fi

# Ask the user if they want to remove all Nix applications
read -p "Do you want to uninstall all Nix applications and free up space? [y/N]: " remove_apps
if [[ "$remove_apps" =~ ^[Yy]$ ]]; then
    echo "Uninstalling all Nix applications..."
    nix-env --query --installed | cut -d' ' -f1 | xargs -n1 nix-env -e
    echo "All Nix applications have been removed."
else
    echo "Skipped uninstalling Nix applications."
fi

# Ask the user if they want to proceed with removing the Nix store
read -p "Do you want to remove the Nix store (/nix/store) and all associated files? [y/N]: " remove_nix
if [[ "$remove_nix" =~ ^[Yy]$ ]]; then
    echo "Removing Nix store and all associated files..."
    sudo rm -rf /nix
else
    echo "Skipped removing /nix."
fi

# Ask the user if they want to remove the Nix profiles
read -p "Do you want to remove Nix profiles from your home directory? [y/N]: " remove_profiles
if [[ "$remove_profiles" =~ ^[Yy]$ ]]; then
    echo "Removing Nix profiles..."
    rm -rf "/home/$USER_NAME/.nix-profile"
    rm -rf "/home/$USER_NAME/.config/nixpkgs"
else
    echo "Skipped removing Nix profiles."
fi

# Ask the user if they want to remove Nix-related environment variables from .bashrc
read -p "Do you want to remove Nix-related environment variables from .bashrc? [y/N]: " remove_bashrc
if [[ "$remove_bashrc" =~ ^[Yy]$ ]]; then
    echo "Removing Nix-related environment variables from .bashrc..."
    sed -i '/nix-profile/d' ~/.bashrc
    sed -i '/XDG_DATA_DIRS.*nix-profile/d' ~/.bashrc
    source ~/.bashrc
else
    echo "Skipped removing Nix-related environment variables from .bashrc."
fi

# Ask the user if they want to remove the VSCode desktop file
read -p "Do you want to remove the VSCode desktop file linked by Nix? [y/N]: " remove_vscode
if [[ "$remove_vscode" =~ ^[Yy]$ ]]; then
    echo "Removing VSCode desktop file..."
    rm -f ~/.local/share/applications/code.desktop
else
    echo "Skipped removing the VSCode desktop file."
fi

echo "Nix uninstallation complete. All space used by Nix has been freed."
