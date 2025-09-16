#!/usr/bin/env bash

# Variables
source ~/.config/user-dirs.dirs # imports the users downloads directory
installedVersion=$(cat /usr/share/discord/resources/build_info.json | jq '.version')
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'
# How to use colors: echo -e "Color is ${RED}Something ... ${GREEN}new." - I think that counts.

# Navigating to the Download-/Work-Directory
cd $XDG_DOWNLOAD_DIR

# Downloading archive
if [ ! -f discord.tar.gz ]; then
   echo "Downloading discord"
   wget - -O discord.tar.gz 'https://discord.com/api/download?platform=linux&format=tar.gz'
fi
if [ ! -f discord.tar.gz ]; then
   echo -e "${RED}Error: Archive \"discord.tar.gz\" not found."
   exit # Emergency Exit
fi

# Extracting the files from archive
echo "Extracting files from Discord archive"
tar -xf discord.tar.gz
downloadedVersion=$(cat $XDG_DOWNLOAD_DIR/Discord/resources/build_info.json | jq '.version')
if [ ! -d Discord ]; then
   echo -e "${RED}Error: Extracted folder \"Discord\" not found."
   exit # Emergency Exit
fi

# Comparing versions
if [[ "$installedVersion" == "$downloadedVersion" ]]; then
   echo -e "${GREEN}Your Discord is already up to date"
   exit # Task successfully failed
fi

# Remove the existing /usr/share/discord directory if it exists
echo "Checking if Discord already exists under /usr/share/"
if [ -d /usr/share/discord ]; then
   echo "Deleting previous installed version"
   sudo rm -r /usr/share/discord
fi

echo "Moving extracted folder into /usr/share as discord"
sudo mv Discord/ /usr/share/discord/

# Creating/updating shortcut for application menu
echo "Creating shortcut for application menu"
if [ ! -f "~/.local/share/applications/discord.desktop" ]; then
   cp /usr/share/discord/discord.desktop ~/.local/share/applications/ # copy .desktop file to ~/.local/share/applications so it'll show up in application launcher
fi

# Clean up
echo "Deleting downloaded archive"
rm discord.tar.gz

echo -e "${GREEN}Installation successfull."

#OTHER
#TODO: Make this whole thing automatic
