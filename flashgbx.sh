function updateFlashGBX() {
  (
    set -e

    repo_dir="$HOME/.tmp/FlashGBX"

    if [ -f "/Applications/FlashGBX.app/Contents/Info.plist" ]; then
      installed_version=$(plutil -p "/Applications/FlashGBX.app/Contents/Info.plist" | grep "CFBundleShortVersionString" | awk -F\" '{print $4}')
    else
      installed_version="0"
    fi

    latest_version=$(curl -s https://api.github.com/repos/lesserkuma/FlashGBX/releases/latest | grep '"tag_name":' | awk -F\" '{print $4}') || { echo "Error fetching latest version information"; exit 1; }

    if [ "$latest_version" = "$installed_version" ]; then
      echo "FlashGBX is already up-to-date (version $installed_version)."
      return 0
    fi

    # Prompt for user confirmation
    echo "A new version of FlashGBX is available."
    echo "current: $installed_version, latest: $latest_version"
    echo -n "Do you want to update? (y/n): "

    read -r user_input
    if [[ ! $user_input =~ ^[Yy]$ ]]
    then
      echo "Update cancelled."
      return 0
    fi

    if [ ! -d "$repo_dir" ]; then
      mkdir -p "$repo_dir"
      git clone https://github.com/lesserkuma/FlashGBX.git "$repo_dir" || { echo "Error cloning repository"; exit 1; }
      cd "$repo_dir"
    else
      cd "$repo_dir"
      git fetch || { echo "Error fetching repository updates"; exit 1; }
    fi

    git checkout tags/$latest_version > /dev/null 2>&1 || { echo "Error checking out tag $latest_version"; exit 1; }

    yes | pyinstaller --name 'FlashGBX' --icon 'FlashGBX/res/icon.ico' --windowed run.py
    plutil -replace CFBundleShortVersionString -string "$latest_version" dist/FlashGBX.app/Contents/Info.plist
    rsync -a --delete dist/FlashGBX.app/ /Applications/FlashGBX.app/

    echo "Successfully updated FlashGBX to version $latest_version."

  )
}


