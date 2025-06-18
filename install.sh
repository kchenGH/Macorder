#!/usr/bin/env bash
set -e

# install.sh — copies the app to /Applications, fixes permissions, and clears quarantine

# Ensure root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "⏳ Re-running with sudo…"
  exec sudo "$0" "$@"
fi

APP_NAME="Macro Recorder.app"
DEST_DIR="/Applications"
SRC_DIR="$(pwd)/$APP_NAME"

# Check for .app
if [ ! -d "$SRC_DIR" ]; then
  echo "⚠️  Error: $APP_NAME not found in $(pwd)."
  exit 1
fi

# Copy to /Applications
echo "➡️ Copying $APP_NAME to $DEST_DIR…"
rm -rf "$DEST_DIR/$APP_NAME"
cp -R "$SRC_DIR" "$DEST_DIR/"

# Remove quarantine attribute
echo "🛡 Removing quarantine attributes…"
xattr -dr com.apple.quarantine "$DEST_DIR/$APP_NAME"

# Restore executable bit on main binary
MAIN_BIN="$DEST_DIR/$APP_NAME/Contents/MacOS/Macro Recorder"
if [ -f "$MAIN_BIN" ]; then
  echo "🔧 Restoring executable permission on main binary…"
  chmod +x "$MAIN_BIN"
else
  echo "⚠️  Warning: Main executable not found at $MAIN_BIN"
fi

# Done
echo "✅ Installation complete!"
echo "You can launch Macro Recorder from /Applications or Spotlight."
echo "If it still won't open, right-click the app in /Applications and choose ‘Open’ to authorize it."
