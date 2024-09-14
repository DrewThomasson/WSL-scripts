Certainly! Below are two comprehensive `.sh` scripts based on the guide you provided. The first script is for installation, and the second is for uninstallation. Both scripts include necessary checks, user prompts for confirmation, and informative messages to guide you through the process.

---

### **Installation Script (`install_userspace_pacman.sh`):**

```bash
#!/bin/bash

# Install script for setting up userspace pacman root on Steam Deck

# Variables
USERROOT_DEFAULT="$HOME/.root"
USERROOT=""
PACMAN_CONF=""
GPGDIR=""
BASHRC="$HOME/.bashrc"
PACMAN_ALIAS='alias pacman_="sudo pacman -r $USERROOT --gpgdir $USERROOT/etc/pacman.d/gnupg"'

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
echo "It will allow you to install pacman packages in your home directory."
echo "Proceed with caution and at your own risk."
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

# Step 2: Copy pacman.conf
echo "Copying pacman.conf..."
PACMAN_CONF="$USERROOT/etc/pacman.conf"
cp /etc/pacman.conf "$PACMAN_CONF"

# Step 3: Create keyring directory
echo "Creating keyring directory..."
GPGDIR="$USERROOT/etc/pacman.d/gnupg"
mkdir -p "$GPGDIR"

# Step 4: Initialize the keyring
echo "Initializing pacman keyring..."
sudo pacman-key --gpgdir "$GPGDIR" --conf "$PACMAN_CONF" --init

# Step 5: Populate the keyring
echo "Populating pacman keyring..."
sudo pacman-key --gpgdir "$GPGDIR" --conf "$PACMAN_CONF" --populate archlinux

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
pacman_ -Sy

# Step 8: Install core utilities
echo "Installing core utilities..."
pacman_ -S --needed --noconfirm coreutils tar less findutils diffutils grep sed gawk util-linux procps-ng

# Step 9: Update PATH and LD_LIBRARY_PATH in .bashrc
echo "Updating PATH and LD_LIBRARY_PATH in $BASHRC..."
if grep -q 'export USERROOT=' "$BASHRC"; then
    echo "USERROOT already exported in $BASHRC."
else
    echo 'export USERROOT="$HOME/.root"' >> "$BASHRC"
fi

if grep -q 'export PATH=' "$BASHRC" | grep "$USERROOT/usr/bin"; then
    echo "PATH already updated in $BASHRC."
else
    echo 'export PATH=$PATH:"$USERROOT/usr/bin"' >> "$BASHRC"
fi

if grep -q 'export LD_LIBRARY_PATH=' "$BASHRC" | grep "$USERROOT/lib"; then
    echo "LD_LIBRARY_PATH already updated in $BASHRC."
else
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$USERROOT/lib":"$USERROOT/lib64"' >> "$BASHRC"
fi

# Step 10: Inform user to reload shell
echo -e "\nInstallation complete."
echo "Please reload your shell or run 'source ~/.bashrc' to apply the changes."
echo "You can now use 'pacman_' command to install packages in your userspace."

exit 0
```

**Instructions to run the installation script:**

1. Save the script above as `install_userspace_pacman.sh` in your home directory.
2. Open the terminal on your Steam Deck.
3. Make the script executable:

   ```bash
   chmod +x ~/install_userspace_pacman.sh
   ```

4. Run the script:

   ```bash
   ./install_userspace_pacman.sh
   ```

---

### **Uninstallation Script (`uninstall_userspace_pacman.sh`):**

```bash
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
sed -i "\|export PATH=.*\"$USERROOT/usr/bin\"|d" "$BASHRC"

# Remove LD_LIBRARY_PATH modification from .bashrc
echo "Removing LD_LIBRARY_PATH modification from $BASHRC..."
sed -i "\|export LD_LIBRARY_PATH=.*\"$USERROOT/lib\"|d" "$BASHRC"

# Inform user to reload shell
echo -e "\nUninstallation complete."
echo "Please reload your shell or run 'source ~/.bashrc' to apply the changes."

exit 0
```

**Instructions to run the uninstallation script:**

1. Save the script above as `uninstall_userspace_pacman.sh` in your home directory.
2. Open the terminal on your Steam Deck.
3. Make the script executable:

   ```bash
   chmod +x ~/uninstall_userspace_pacman.sh
   ```

4. Run the script:

   ```bash
   ./uninstall_userspace_pacman.sh
   ```

---

**Important Notes:**

- **User Confirmation:** The scripts include prompts that require you to confirm actions by typing `y` or `n`. This is to ensure that you are aware of the changes being made.

- **Error Handling:** The scripts perform checks to ensure they are run by the correct user (`deck`) and that a password is set for sudo operations.

- **Backup:** Before running the uninstallation script, consider backing up any important data within the `$USERROOT` directory if you've stored any custom configurations or data there.

- **Reload Shell:** After running either script, you should reload your shell environment to apply changes by running `source ~/.bashrc` or opening a new terminal window.

- **Usage:** After installation, you can use `pacman_` instead of `pacman` to install packages in your userspace.

---

Feel free to run these scripts, and they should automate the entire process described in the guide. If you have any questions or need further assistance, don't hesitate to ask!













alias pacman_="sudo pacman -r $USERROOT --gpgdir $USERROOT/etc/pacman.d/gnupg"
source ~/.bashrc
export LD_LIBRARY_PATH=$USERROOT/usr/lib:$USERROOT/lib:$USERROOT/lib64:$LD_LIBRARY_PATH
source ~/.bashrc


pacman_ -Sy  # To sync the package databases

# Initialize the keyring
sudo pacman-key --gpgdir "$USERROOT/etc/pacman.d/gnupg" --init

# Populate the keyring
sudo pacman-key --gpgdir "$USERROOT/etc/pacman.d/gnupg" --populate archlinux

# Import and locally sign keys
sudo pacman-key --gpgdir "$USERROOT/etc/pacman.d/gnupg" --recv-keys AF1D2199EF0A3CCF
sudo pacman-key --gpgdir "$USERROOT/etc/pacman.d/gnupg" --lsign-key AF1D2199EF0A3CCF

sudo pacman-key --gpgdir "$USERROOT/etc/pacman.d/gnupg" --recv-keys 3056513887B78AEB
sudo pacman-key --gpgdir "$USERROOT/etc/pacman.d/gnupg" --lsign-key 3056513887B78AEB








if you ever get anything like cannot find or


bash```
(deck@steamdeck ~)$ pacman_ -S leafpad
error: failed to initialize alpm library:
(root: --config, dbpath: /usr/lib/holo/pacmandb/)
could not find or read directory


```



then run this command should fix ti by addding this at the end of the bashrc file 

bash```


echo 'alias pacman_="sudo pacman -r $USERROOT --gpgdir $USERROOT/etc/pacman.d/gnupg"' >> ~/.bashrc


```
then just reinit the bash file with source ~/.bashrc or just aiunch a new terminal window
