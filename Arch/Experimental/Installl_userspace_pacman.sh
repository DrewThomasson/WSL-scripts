#!/bin/bash

# Install script for setting up userspace pacman root on Steam Deck
# This script configures pacman to automatically accept all PGP keys.

# Variables
USERROOT_DEFAULT="$HOME/.root"
USERROOT=""
PACMAN_CONF=""
GPGDIR=""
BASHRC="$HOME/.bashrc"
PACMAN_ALIAS='alias pacman_="sudo pacman -r $USERROOT --config $USERROOT/etc/pacman.conf"'

# Function to check if password is set for 'deck' user
check_password_set() {
    echo -e "\nChecking if password is set for user 'deck'..."
    if sudo -l >/dev/null 2>&1; then
        echo "Password is set."
    else
        echo "Password is not set or sudo is not configured properly."
        echo "Please run 'passwd' to set a password for user 'deck' before proceeding."
        exit 1
    fi
}

# Introduction
echo "This script will set up a userspace pacman root on your Steam Deck."
echo "It will configure pacman to automatically accept all PGP keys during package installations."
echo "Proceed with caution, as this can pose security risks."
read -p "Do you wish to continue? [y/N]: " proceed
if [[ "$proceed" != "y" && "$proceed" != "Y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Check if running as 'deck' user
if [[ "$USER" != "deck" ]]; then
    echo "This script must be run as the 'deck' user."
    exit 1
fi

# Check if password is set
check_password_set

# Ask for USERROOT path
read -p "Enter the path for the new root directory [$USERROOT_DEFAULT]: " input_userroot
USERROOT="${input_userroot:-$USERROOT_DEFAULT}"

# Confirm the USERROOT path
echo "The new root directory will be: $USERROOT"
read -p "Is this correct? [Y/n]: " confirm_userroot
if [[ "$confirm_userroot" == "n" || "$confirm_userroot" == "N" ]]; then
    echo "Installation cancelled."
    exit 0
fi

export USERROOT

# Step 1: Create new root directory
echo -e "\nCreating new root directory at $USERROOT..."
mkdir -p "$USERROOT/etc"
mkdir -p "$USERROOT/var/lib/pacman"
mkdir -p "$USERROOT/var/cache/pacman/pkg"

# Step 2: Copy and modify pacman.conf
echo "Copying pacman.conf..."
PACMAN_CONF="$USERROOT/etc/pacman.conf"
cp /etc/pacman.conf "$PACMAN_CONF"

echo "Modifying pacman.conf..."
# Modify pacman.conf to use $USERROOT paths and disable signature checking
sed -i "s|^DBPath.*|DBPath     = $USERROOT/var/lib/pacman/|g" "$PACMAN_CONF"
sed -i "s|^#CacheDir.*|CacheDir   = $USERROOT/var/cache/pacman/pkg/|g" "$PACMAN_CONF"
sed -i "s|^CacheDir.*|CacheDir   = $USERROOT/var/cache/pacman/pkg/|g" "$PACMAN_CONF"
sed -i "s|^GPGDir.*|GPGDir     = $USERROOT/etc/pacman.d/gnupg/|g" "$PACMAN_CONF"
sed -i "s|^#SigLevel.*|SigLevel = Never|g" "$PACMAN_CONF"
sed -i "s|^SigLevel.*|SigLevel = Never|g" "$PACMAN_CONF"

# Step 3: Create keyring directory
echo "Creating keyring directory..."
GPGDIR="$USERROOT/etc/pacman.d/gnupg"
mkdir -p "$GPGDIR"

# Step 4: Initialize the keyring (optional since signature checking is disabled)
echo "Initializing pacman keyring..."
sudo pacman-key --gpgdir "$GPGDIR" --config "$PACMAN_CONF" --init

# Step 5: Populate the keyring (optional)
echo "Populating pacman keyring..."
sudo pacman-key --gpgdir "$GPGDIR" --config "$PACMAN_CONF" --populate archlinux

# Step 6: Add pacman_ alias to .bashrc
echo "Adding pacman_ alias to $BASHRC..."
if grep -q 'alias pacman_=' "$BASHRC"; then
    echo "Pacman alias already exists in $BASHRC."
else
    echo "$PACMAN_ALIAS" >> "$BASHRC"
    echo "Pacman alias added."
fi

# Source .bashrc to update alias
source "$BASHRC"

# Step 7: Sync pacman
echo "Syncing pacman databases..."
pacman_ -Sy --noconfirm

# Step 8: Install core utilities
echo "Installing core utilities..."
pacman_ -S --needed --noconfirm coreutils tar less findutils diffutils grep sed gawk util-linux procps-ng

# Step 9: Update PATH and LD_LIBRARY_PATH in .bashrc
echo "Updating PATH and LD_LIBRARY_PATH in $BASHRC..."
if grep -q 'export USERROOT=' "$BASHRC"; then
    echo "USERROOT already exported in $BASHRC."
else
    echo "export USERROOT=\"$USERROOT\"" >> "$BASHRC"
fi

if grep -q "export PATH=.*$USERROOT/usr/bin" "$BASHRC"; then
    echo "PATH already updated in $BASHRC."
else
    echo 'export PATH="$USERROOT/usr/bin:$PATH"' >> "$BASHRC"
fi

if grep -q "export LD_LIBRARY_PATH=.*$USERROOT/usr/lib" "$BASHRC"; then
    echo "LD_LIBRARY_PATH already updated in $BASHRC."
else
    echo 'export LD_LIBRARY_PATH="$USERROOT/usr/lib:$USERROOT/lib:$USERROOT/lib64:$LD_LIBRARY_PATH"' >> "$BASHRC"
fi

# Step 10: Inform user to reload shell
echo -e "\nInstallation complete."
echo "Please reload your shell or run 'source ~/.bashrc' to apply the changes."
echo "You can now use the 'pacman_' command to install packages in your userspace."
echo "Note: Signature checking is disabled. All packages will be installed without PGP verification."

exit 0
