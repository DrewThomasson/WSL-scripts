#!/bin/bash

# Uninstall script for removing userspace pacman root on Steam Deck

# Variables
USERROOT="$HOME/.root"
BASHRC="$HOME/.bashrc"

# Introduction
echo "This script will remove the userspace pacman root from your Steam Deck."
echo "It will delete the directory $USERROOT and remove modifications from $BASHRC."
read -p "Do you wish to continue? [y/N]: " proceed
if [[ "$proceed" != "y" && "$proceed" != "Y" ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Confirm deletion
read -p "Are you sure you want to delete $USERROOT and remove configurations? This action cannot be undone. [y/N]: " confirm_delete
if [[ "$confirm_delete" != "y" && "$confirm_delete" != "Y" ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Remove USERROOT directory
echo "Removing $USERROOT..."
rm -rf "$USERROOT"

# Remove pacman_ alias from .bashrc
echo "Removing pacman_ alias from $BASHRC..."
sed -i '/alias pacman_=/d' "$BASHRC"

# Remove USERROOT export from .bashrc
echo "Removing USERROOT export from $BASHRC..."
sed -i '/export USERROOT=/d' "$BASHRC"

# Remove PATH modification from .bashrc
echo "Removing PATH modification from $BASHRC..."
sed -i "\|export PATH=.*$USERROOT/usr/bin|d" "$BASHRC"

# Remove LD_LIBRARY_PATH modification from .bashrc
echo "Removing LD_LIBRARY_PATH modification from $BASHRC..."
sed -i "\|export LD_LIBRARY_PATH=.*$USERROOT/usr/lib|d" "$BASHRC"

# Inform user to reload shell
echo -e "\nUninstallation complete."
echo "Please reload your shell or run 'source ~/.bashrc' to apply the changes."

exit 0
