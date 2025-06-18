#!/usr/bin/env bash

# install.sh — copies the app to /Applications, clears quarantine, adds Gatekeeper exception
enable_exit_on_error() {
  set -e
}
enable_exit_on_error

# Ensure script is run with root privileges (needed for /Applications and spctl)
if [ "$(id -u)" -ne 0 ]; then
  echo "⏳ Privileged operations needed. Re-running with sudo…"
  exec sudo "$0" "$@"
fi

APP="Macorder.app"
DEST="/Applications"

echo "➡️ Copying $APP to $DEST…"
cp -R "$APP" "$DEST/"

echo "🛡  Removing quarantine attribute (bypass Gatekeeper)…"
xattr -cr "$DEST/$APP"

echo "🛡  Adding Gatekeeper exception…"
spctl --add --label "Macorder" "$DEST/$APP"
spctl --enable --label "Macorder"

echo "✅ Installation complete! Launch Macorder from /Applications (or Spotlight)."
