#!/bin/bash

# Function to calculate the available disk space in KB
get_disk_usage_kb() {
    df / | grep -E "/$" | awk '{print $4}'
}

# Convert from KB to MB
convert_to_mb() {
    echo $(( $1 / 1024 ))
}

# Get the current username
USER_NAME=$(whoami)

# Get initial disk usage
initial_space_kb=$(get_disk_usage_kb)
initial_space_mb=$(convert_to_mb $initial_space_kb)
echo "Available space before installation: $initial_space_mb MB"

# Estimate the space required (Nix installation is typically 5000 MB)
required_space="533"
echo "The Nix installation will require approximately $required_space MB of space."

# Ask the user for confirmation
read -p "Do you want to proceed with the installation? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Installation canceled."
    exit 0
fi

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

# Get final disk usage
final_space_kb=$(get_disk_usage_kb)
final_space_mb=$(convert_to_mb $final_space_kb)
echo "Available space after installation: $final_space_mb MB"

# Calculate the space used during installation
space_used_kb=$((initial_space_kb - final_space_kb))
space_used_mb=$(convert_to_mb $space_used_kb)
echo "Space used by the installation: $space_used_mb MB"

echo "Nix installation and configuration complete."
echo "To install packages with Nix use:"
echo "nix-env -iA nixpkgs.htop"
echo "To uninstall packages with Nix use:"
echo "nix-env -e package_name"
echo "You may have to open a new terminal window to start using nix"
