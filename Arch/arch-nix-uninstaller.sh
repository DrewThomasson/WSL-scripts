#!/bin/bash

# Get the current username
USER_NAME=$(whoami)

# Check if Nix is installed
if [ ! -d "/nix" ]; then
    echo "Nix is not installed."
    exit 0
fi

# Calculate expected space to be freed up
echo "Calculating the space used by Nix and its applications..."

# List all installed Nix packages and their individual sizes
echo "Installed Nix applications and their sizes:"
nix-env --query --installed | while read -r app; do
    app_name=$(echo "$app" | cut -d' ' -f1)
    app_size=$(nix-store --query --size "$(nix-env --query --out-path "$app_name" | cut -d' ' -f3)" | awk '{print $1}')
    echo "$app_name: $(($app_size / 1024 / 1024)) MB"
done

# Get the size of the /nix directory
nix_store_size=$(du -sh /nix | awk '{print $1}')

# Get the size of the Nix profile and configurations in the user's home directory
nix_profile_size=$(du -sh "/home/$USER_NAME/.nix-profile" 2>/dev/null | awk '{print $1}')
nix_config_size=$(du -sh "/home/$USER_NAME/.config/nixpkgs" 2>/dev/null | awk '{print $1}')

# Combine all sizes
total_size="${nix_store_size} (Nix store) + ${nix_profile_size:-0} (Nix profile) + ${nix_config_size:-0} (Nix config)"
echo "Total space to be freed: $total_size"

# Ask the user if they want to proceed with uninstallation
read -p "Do you want to uninstall Nix and all its applications, freeing up approximately $total_size of space? [y/N]: " confirm_uninstall
if [[ ! "$confirm_uninstall" =~ ^[Yy]$ ]]; then
    echo "Uninstallation canceled."
    exit 0
fi

# Calculate initial disk usage
initial_usage=$(df / | tail -1 | awk '{print $3}')

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

# Calculate final disk usage
final_usage=$(df / | tail -1 | awk '{print $3}')

# Calculate freed-up space
freed_space=$((initial_usage - final_usage))

echo "Nix uninstallation complete. All space used by Nix has been freed."
echo "Storage freed up: $((freed_space / 1024)) MB"
