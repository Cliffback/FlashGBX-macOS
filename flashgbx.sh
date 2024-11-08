function updateFlashGBX() {
  (
    set -e

    repo_dir="$HOME/.tmp/FlashGBX"

    if [ -f "/Applications/FlashGBX.app/Contents/Info.plist" ]; then
      installed_version=$(plutil -p "/Applications/FlashGBX.app/Contents/Info.plist" | grep "CFBundleShortVersionString" | awk -F\" '{print $4}')
    else
      installed_version="0"
    fi

    latest_version=$(curl -s https://api.github.com/repos/lesserkuma/FlashGBX/releases/latest | grep '"tag_name":' | awk -F\" '{print $4}') || {
      echo "Error fetching latest version information"
      exit 1
    }

    if [ "$latest_version" = "$installed_version" ]; then
      echo "FlashGBX is already up-to-date (version $installed_version)."
      return 0
    fi

    # Prompt for user confirmation
    echo "A new version of FlashGBX is available."
    echo "current: $installed_version, latest: $latest_version"
    echo -n "Do you want to update? (y/n): "

    read -r user_input
    if [[ ! $user_input =~ ^[Yy]$ ]]; then
      echo "Update cancelled."
      return 0
    fi

    if [ ! -d "$repo_dir" ]; then
      mkdir -p "$repo_dir"
      git clone https://github.com/lesserkuma/FlashGBX.git "$repo_dir" || {
        echo "Error cloning repository"
        exit 1
      }
      cd "$repo_dir"
    else
      cd "$repo_dir"
      git fetch || {
        echo "Error fetching repository updates"
        exit 1
      }
    fi

    # Reset repo to upstream
    git clean -fd
    git reset --hard

    # Checkout latest release
    git checkout tags/"$latest_version" >/dev/null 2>&1 || {
      echo "Error checking out tag $latest_version"
      exit 1
    }

    #update_spec
    printf "# -*- mode: python ; coding: utf-8 -*-\n\n\
a = Analysis(\n\
    ['run.py'],\n\
    pathex=[],\n\
    binaries=[],\n\
    datas=[],\n\
    hiddenimports=[],\n\
    hookspath=[],\n\
    hooksconfig={},\n\
    runtime_hooks=[],\n\
    excludes=[],\n\
    noarchive=False,\n\
)\n\
pyz = PYZ(a.pure)\n\n\
exe = EXE(\n\
    pyz,\n\
    a.scripts,\n\
    [],\n\
    exclude_binaries=True,\n\
    name='FlashGBX',\n\
    debug=False,\n\
    bootloader_ignore_signals=False,\n\
    strip=False,\n\
    upx=True,\n\
    console=False,\n\
    disable_windowed_traceback=False,\n\
    argv_emulation=False,\n\
    target_arch=None,\n\
    codesign_identity=None,\n\
    entitlements_file=None,\n\
    icon=['FlashGBX/res/icon.ico'],\n\
)\n\
coll = COLLECT(\n\
    exe,\n\
    a.binaries,\n\
    a.datas,\n\
    strip=False,\n\
    upx=True,\n\
    upx_exclude=[],\n\
    name='FlashGBX',\n\
)\n\
info_plist = {\n\
    'CFBundleName': 'FlashGBX',\n\
    'CFBundleDisplayName': 'FlashGBX',\n\
    'CFBundleGetInfoString': 'Reads and writes Game Boy and Game Boy Advance cartridge data.',\n\
    'CFBundleShortVersionString': '%s',\n\
    'CFBundleIdentifier': 'com.lesserkuma.FlashGBX',\n\
}\n\
app = BUNDLE(\n\
    coll,\n\
    name='FlashGBX.app',\n\
    icon='FlashGBX/res/icon.ico',\n\
    bundle_identifier='com.lesserkuma.FlashGBX',\n\
    info_plist=info_plist,\n\
)" "$latest_version" > FlashGBX.spec

    yes | pyinstaller FlashGBX.spec

    # Manually copy cartridge information files to the app bundle
    mkdir dist/FlashGBX.app/Contents/MacOS/config
    cp -R FlashGBX/config/* dist/FlashGBX.app/Contents/MacOS/config
    cp -R FlashGBX/res dist/FlashGBX.app/Contents/MacOS
      
    #plutil -replace CFBundleShortVersionString -string "$latest_version" dist/FlashGBX.app/Contents/Info.plist
    rsync -a --delete dist/FlashGBX.app/ /Applications/FlashGBX.app/

    echo "Successfully updated FlashGBX to version $latest_version."

  )
}

function createFlashGBXImage {
  (

    set -e

    repo_dir="$HOME/.tmp/FlashGBX"
    release_repo="Cliffback/FlashGBX-macOS"

    latest_version=$(curl -s https://api.github.com/repos/lesserkuma/FlashGBX/releases/latest | grep '"tag_name":' | awk -F\" '{print $4}') || {
      echo "Error fetching latest version information"
      exit 1
    }

    # Prompt for user confirmation to create an image
    echo -n "Do you want to create an image of FlashGBX v$latest_version? (y/n): "
    read -r user_input
    if [[ ! $user_input =~ ^[Yy]$ ]]; then
      echo "Creation cancelled."
      return 0
    fi

    # Clone or fetch the FlashGBX repository
    if [ ! -d "$repo_dir" ]; then
      mkdir -p "$repo_dir"
      git clone https://github.com/lesserkuma/FlashGBX.git "$repo_dir" || {
        echo "Error cloning repository"
        exit 1
      }
    fi
    cd "$repo_dir"
    git fetch
    git checkout tags/"$latest_version" >/dev/null 2>&1 || {
      echo "Error checking out tag $latest_version"
      exit 1
    }

    #update_spec
    printf "# -*- mode: python ; coding: utf-8 -*-\n\n\
a = Analysis(\n\
    ['run.py'],\n\
    pathex=[],\n\
    binaries=[],\n\
    datas=[],\n\
    hiddenimports=[],\n\
    hookspath=[],\n\
    hooksconfig={},\n\
    runtime_hooks=[],\n\
    excludes=[],\n\
    noarchive=False,\n\
)\n\
pyz = PYZ(a.pure)\n\n\
exe = EXE(\n\
    pyz,\n\
    a.scripts,\n\
    [],\n\
    exclude_binaries=True,\n\
    name='FlashGBX',\n\
    debug=False,\n\
    bootloader_ignore_signals=False,\n\
    strip=False,\n\
    upx=True,\n\
    console=False,\n\
    disable_windowed_traceback=False,\n\
    argv_emulation=False,\n\
    target_arch=None,\n\
    codesign_identity=None,\n\
    entitlements_file=None,\n\
    icon=['FlashGBX/res/icon.ico'],\n\
)\n\
coll = COLLECT(\n\
    exe,\n\
    a.binaries,\n\
    a.datas,\n\
    strip=False,\n\
    upx=True,\n\
    upx_exclude=[],\n\
    name='FlashGBX',\n\
)\n\
info_plist = {\n\
    'CFBundleName': 'FlashGBX',\n\
    'CFBundleDisplayName': 'FlashGBX',\n\
    'CFBundleGetInfoString': 'Reads and writes Game Boy and Game Boy Advance cartridge data.',\n\
    'CFBundleShortVersionString': '%s',\n\
    'CFBundleIdentifier': 'com.lesserkuma.FlashGBX',\n\
}\n\
app = BUNDLE(\n\
    coll,\n\
    name='FlashGBX.app',\n\
    icon='FlashGBX/res/icon.ico',\n\
    bundle_identifier='com.lesserkuma.FlashGBX',\n\
    info_plist=info_plist,\n\
)" "$latest_version" > FlashGBX.spec

    yes | pyinstaller FlashGBX.spec

    # Manually copy cartridge information files to the app bundle
    mkdir dist/FlashGBX.app/Contents/MacOS/config
    cp -R FlashGBX/config/* dist/FlashGBX.app/Contents/MacOS/config

    mkdir -p dist/dmg
    cp -r "dist/FlashGBX.app" dist/dmg

    # Check if the DMG file already exists and remove it if it does
    dmg_path="dist/FlashGBX.dmg"
    if [ -f "$dmg_path" ]; then
      echo "Removing existing DMG file..."
      rm "$dmg_path"
    fi

    create-dmg \
      --volname "FlashGBX" \
      --volicon "FlashGBX/res/icon.ico" \
      --window-pos 200 120 \
      --window-size 600 300 \
      --icon-size 100 \
      --icon "FlashGBX.app" 175 120 \
      --hide-extension "FlashGBX.app" \
      --app-drop-link 425 120 \
      "dist/FlashGBX.dmg" \
      "dist/dmg/"

    echo "Successfully created image of FlashGBX v$latest_version."

    # Check permission level for the release repository
    permission_level=$(gh repo view "$release_repo" --json viewerPermission --jq '.viewerPermission')
    if [[ $permission_level == "ADMIN" || $permission_level == "WRITE" ]]; then
      # User has admin or write access, ask for confirmation to create a release
      echo "You have permission to create a release on $release_repo."
      echo "Do you want to create a release for FlashGBX v$latest_version? (y/n): "
      read -r release_input

      if [[ $release_input =~ ^[Yy]$ ]]; then
        # User confirmed, create a release
        dmg_path="dist/FlashGBX.dmg"  # Ensure this is the correct path to your DMG file
        if [ -f "$dmg_path" ]; then
          release_notes=$(cat <<EOF
App compiled and packaged from the official repo.

Probably only works on Apple Silicone

If you can't open it, it probably got quarantined during download. Run the following to unquarantine it:
xattr -d com.apple.quarantine /path/to/FlashGBX.app
EOF
      )
          gh release create "$latest_version" \
            --repo "$release_repo" \
            --title "FlashGBX v$latest_version" \
            --notes "$release_notes" \
            "$dmg_path"
          echo "Release successfully created for FlashGBX v$latest_version."
        else
          echo "DMG file not found. Release not created."
        fi  
      else
        echo "Release creation cancelled."
      fi
    else
      echo "You do not have permission to create a release on $release_repo."
    fi

    # Clean up
    cd "$HOME"
  )
}
