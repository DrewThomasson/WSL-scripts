#!/bin/bash

# Step 1: Remove the Miniconda directory
echo "Removing Miniconda..."
rm -rf ~/miniconda3

# Step 2: Remove Conda initialization from .bashrc and .zshrc
echo "Removing Conda initialization from shell configurations..."

# For bash
if grep -q "conda initialize" ~/.bashrc; then
  sed -i '/conda initialize/,+7d' ~/.bashrc
  echo "Removed Conda initialization from ~/.bashrc"
fi

# For zsh
if grep -q "conda initialize" ~/.zshrc; then
  sed -i '/conda initialize/,+7d' ~/.zshrc
  echo "Removed Conda initialization from ~/.zshrc"
fi

# Step 3: Reload the shell configuration
echo "Reloading shell configuration..."
source ~/.bashrc
source ~/.zshrc

echo "Miniconda has been uninstalled!"
