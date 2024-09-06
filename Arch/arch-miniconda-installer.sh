#!/bin/bash

# Step 1: Create directory for Miniconda installation
mkdir -p ~/miniconda3

# Step 2: Download the latest Miniconda installer
echo "Downloading Miniconda installer..."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh

# Step 3: Install Miniconda silently
echo "Installing Miniconda..."
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3

# Step 4: Remove the installer file
echo "Cleaning up installer..."
rm ~/miniconda3/miniconda.sh

# Step 5: Initialize Conda for bash and zsh
echo "Initializing Conda..."
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

# Step 6: Reload shell configuration
echo "Reloading shell configuration..."
source ~/.bashrc
source ~/.zshrc

# Step 7: Display Conda version to confirm installation
echo "Miniconda installation complete!"
conda --version
