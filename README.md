# FlashGBX-macOS [NOW IMPLEMENTED IN THE OFFICIAL REPO]

This is a shell script for compiling and updating FlashGBX on macOs, resulting in a "native" application that is also easy to update. 

Precompiled binaries can also be downloaded from releases, if you don't want to bother with the script.

FlashGBX official repo: https://github.com/lesserkuma/FlashGBX/

## Prerequisites 
- Python
- Pyinstaller
  > pip install -U pyinstaller

## Setup
1. Download flashgbx.sh and put it in a folder for sourcing shell scripts. I have put mine in
2. Source the file in your .zshrc
3. Source .zshrc or restart your terminal

## How to use
Run the script in your preferred terminal with the command "updateFlashGBX"

## Example
I put my script in ~/.config/zsh/functions and I'm sourcing all shell scripts in this folder with the following command in my .zshrc script
```sh
for file in ~/.config/zsh/functions/*.sh; do
    source "$file"
done
```

## How it works
The script
1. Checks the version of the current installation (if any), and compares it to latest release in the [official repo](https://github.com/lesserkuma/FlashGBX/) using githubs api.
2. If a new version is available, it clones the repo to a .tmp folder, and checks out the commit associated with the latest release.
3. Using pyinstaller, the script creates a mac application
4. Then update the app to have the correct version number with plutil
5. And finally it overwrites the current installation with rsync
