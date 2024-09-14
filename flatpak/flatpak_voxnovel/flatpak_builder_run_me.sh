apt-get update

apt-get install -y flatpak flatpak-builder

# Install the required SDK and runtime
flatpak install -y flathub org.freedesktop.Sdk/x86_64/21.08
flatpak install -y flathub org.freedesktop.Platform/x86_64/21.08

# Build the Flatpak image
flatpak-builder build-dir manifest.yaml

echo "Flatpak build completed successfully."
