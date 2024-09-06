#!/bin/bash

echo "This script will now attempt to download the default xtts v2 model files into the correct folder"

# Define the path using the home directory variable
MODEL_DIR="$HOME/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2/"

# Check the size of the model directory before downloading
du -sh "$MODEL_DIR"

# Wipe xtts dir (keep the directory, remove its contents)
rm -rf "$MODEL_DIR"/*

# Change to the model directory
cd "$MODEL_DIR" || exit

# Download the model file
wget -O xtts_v2_default_model.zip "https://huggingface.co/drewThomasson/XTTS_v2_backup_model_files/resolve/main/xtts_v2_default_model.zip"

# Check the size of the downloaded zip file
du -sh "$MODEL_DIR/xtts_v2_default_model.zip"

# Unzip the downloaded model file
unzip xtts_v2_default_model.zip

# Remove the zip file after extraction
rm xtts_v2_default_model.zip

# Display the size of the model folder after extraction
echo "Size of model folder now is:"
du -sh "$MODEL_DIR"

# Navigate back to the home directory
cd ~

# Output completion messages
echo "Xtts model downloaded to the correct directory"
echo "Complete!"


#!/bin/bash

#du -sh /home/drew/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2/

#cd /home/drew/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2/

#wget -O xtts_v2_default_model.zip "https://huggingface.co/drewThomasson/XTTS_v2_backup_model_files/resolve/main/xtts_v2_default_model.zip"

#du -sh /home/drew/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2/xtts_v2_default_model.zip

#unzip xtts_v2_default_model.zip

#rm xtts_v2_default_model.zip

#echo "Size of model folder now is:"

#du -sh /home/drew/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2/

#cd ~

#echo "Xtts model Downloaded to correct Directory"

#echo "Complete!"



