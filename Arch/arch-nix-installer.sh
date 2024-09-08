#!/bin/bash

# Get the current username
USER_NAME=$(whoami)

# Ensure the /nix directory exists before attempting to change ownership
if [ ! -d "/nix" ]; then
    echo "Directory /nix does not exist. Creating..."
    sudo mkdir -m 0755 /nix
fi

# Ensure the user has permission to write to the /nix directory
sudo chown -R "$USER_NAME" /nix

# Install Nix package manager
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Setup Nix environment
echo "Setting up Nix environment..."
if [ -f "/home/$USER_NAME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "/home/$USER_NAME/.nix-profile/etc/profile.d/nix.sh"
else
    echo "Failed to source nix.sh for $USER_NAME. Installation might have failed."
    exit 1
fi

# Verify installation
if ! command -v nix &> /dev/null; then
    echo "Nix command not found after sourcing"
    exit 1
else
    echo "Nix installed successfully: $(nix --version)"
fi

# Create Nix configuration file to allow unfree packages
mkdir -p ~/.config/nixpkgs
echo "{ allowUnfree = true; }" > ~/.config/nixpkgs/config.nix

# Export XDG_DATA_DIRS to include .nix-profile in .bashrc, .bash_profile, and .zshrc
for file in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [ -f "$file" ]; then
        if ! grep -q "XDG_DATA_DIRS" "$file"; then
            echo "Adding XDG_DATA_DIRS to $file"
            echo "export XDG_DATA_DIRS=\"/home/$USER_NAME/.nix-profile/share\"" >> "$file"
            source "$file"
        else
            echo "XDG_DATA_DIRS already present in $file"
        fi
    fi
done

# Create and link vscode desktop file if it doesn't already exist
mkdir -p ~/.local/share/applications
if [ ! -f ~/.local/share/applications/code.desktop ]; then
    ln -s "/home/$USER_NAME/.nix-profile/share/applications/code.desktop" ~/.local/share/applications/
    chmod +x ~/.local/share/applications/code.desktop
else
    echo "VSCode desktop file already exists, skipping."
fi

# Final Nix environment activation
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
else
    echo "Failed to activate Nix environment."
    exit 1
fi

echo "Nix installation and configuration complete."
echo "To install packages with Nix use:"
echo "nix-env -iA nixpkgs.htop"
echo "To uninstall packages with Nix use:"
echo "nix-env -e package_name"
nix-env -iA nixpkgs.htop
