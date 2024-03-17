#! /bin/bash

# Working directory is script path (gnome directory)
SCRIPT_PATH="$(realpath "$0")"
cd "$(dirname "$SCRIPT_PATH")"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
OFF='\033[0m'

# Wallpapers install base location.
LOCATION=~/.local/share

# Location placeholder
PLACEHOLDER="__LOCATION__"

THEME=""

if [ $# -eq 0 ] ; then
  # No theme name present: Show options.
  echo -e "${YELLOW}Select theme${OFF}"
  declare -a THEMES
  INDEX=0
  for entry in ./*.zip
  do
    LEN=${#entry}
    THEMES[INDEX]="${entry:2:LEN-6}"
    INDEX=$((INDEX+1))
  done
  echo ""
  select opt in "${THEMES[@]}"
  do
    THEME="$opt"
    break;
  done
else
  THEME="$1"
fi

if [[ ! ( -e $THEME.zip ) ]] ; then
  # Theme not present: Exit with an error message.
  echo -e "${RED}Invalid theme: $THEME${OFF}"
  exit 1
fi

echo "Checking and cleaning up old $THEME files"

if [ -d "./$THEME" ]; then
    # Delete old directory
    echo -e "${YELLOW}Removing Old Files for ($THEME)\n${OFF}"
    rm -rf "./$THEME"
fi

echo "Adding $THEME to wallpapers..."

mkdir -p $LOCATION/backgrounds/gnome
mkdir -p $LOCATION/gnome-background-properties
unzip -q $THEME.zip -d ./$THEME

if [ -d "$LOCATION/backgrounds/gnome/$THEME-timed" ]; then
    # Delete old files
  echo ""
  echo -e "${YELLOW}Removing old $THEME wallpaper...${OFF}"
  rm -rf $LOCATION/backgrounds/gnome/$THEME-timed
  rm -rf $LOCATION/backgrounds/gnome/$THEME-timed.xml
  rm -rf $LOCATION/gnome-background-properties/$THEME.xml
  echo -e "${GREEN}Removed old $THEME wallpaper!${OFF}"
fi

cd $THEME

# Changing file contents of the XML files.
sed -i "s+$PLACEHOLDER+$LOCATION+g" $THEME.xml
sed -i "s+$PLACEHOLDER+$LOCATION+g" $THEME-timed.xml

# Create required directories & files
mkdir $LOCATION/backgrounds/gnome/$THEME-timed
cp $THEME*.jp* $LOCATION/backgrounds/gnome/$THEME-timed
cp $THEME-timed.xml $LOCATION/backgrounds/gnome
cp $THEME.xml $LOCATION/gnome-background-properties
echo ""
echo -e "${GREEN}Added $THEME dynamic wallpaper!${OFF}"

echo "Cleaning up..."
cd ..
rm -rf $THEME

echo "Files copied to:"
echo "$LOCATION/backgrounds/gnome/$THEME-timed"
echo "$LOCATION/backgrounds/gnome"
echo "$LOCATION/gnome-background-properties"
echo ""
echo -e "${GREEN}Done installing $THEME wallpapers!${OFF}"
