#!/usr/bin/env bash

# install.sh — copies the app to /Applications and removes quarantine flag
set -e

APP="Macorder.app"
DEST="/Applications"

echo "➡️ Copying $APP to $DEST…"
cp -R "$APP" "$DEST/"

echo "🛡  Removing quarantine attribute (bypass Gatekeeper)…"
xattr -cr "$DEST/$APP"

echo "✅ Installation complete! You can now launch Macro Recorder from /Applications."
