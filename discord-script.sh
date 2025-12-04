#!/usr/bin/env bash

# Variables
source ~/.config/user-dirs.dirs # imports the users downloads directory
currentuser=$(whoami)
installedVersion=$(cat /usr/share/discord/resources/build_info.json | jq '.version')
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# How to use colors: echo -e "Color is ${RED}Something ... ${GREEN}new. ${NOCOLOR}for me" - I think that counts as a tutorial.

# Navigating to the Download-/Work-Directory
cd $XDG_DOWNLOAD_DIR

# Downloading archive
if [ ! -f discord.tar.gz ]; then
   echo "Downloading discord"
   wget - -O discord.tar.gz 'https://discord.com/api/download?platform=linux&format=tar.gz' -P $XDG_DOWNLOAD_DIR
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
   echo "$installedVersion"
   echo "$downloadedVersion"
   echo -e "${GREEN}Your Discord is already up to date"
   exit # Task successfully failed
fi

# Setting flag for discord to skip updates / ignore them
skipUpdate=$(cat '~/.config/discord/settings.json' | jq '.SKIP_HOST_UPDATE')
if [ ! $skipUpdate == "true"]; then
   echo -e "Flag SKIP_HOST_UPDATE not set in settings.json. Setting Flag"
   jq '. += {"SKIP_HOST_UPDATE" : true}' ~/.config/discord/settings.json > ~/.config/discord/settings.json.tmp && mv ~/.config/discord/settings.json.tmp ~/.config/discord/settings.json
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
#FIXME: Shortcut gets broken after update and restart | maybe write new .desktop file?
echo "Creating shortcut for application menu"
if [ ! -f "/usr/share/applications/discord.desktop" ]; then
   #cp /usr/share/discord/discord.desktop /home/$currentuser/.local/share/applications/
   cp /usr/share/discord/discord.desktop /usr/share/applications/
fi

# Clean up
echo "Deleting downloaded archive"
rm discord.tar.gz

echo -e "${GREEN}Installation successfull."
