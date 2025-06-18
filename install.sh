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

APP="Macro Recorder.app"
DEST="/Applications"

echo "➡️ Copying $APP to $DEST…"
cp -R "$APP" "$DEST/"

echo "🛡  Removing quarantine attribute (bypass Gatekeeper)…"
xattr -cr "$DEST/$APP"

echo "🛡  Adding Gatekeeper exception…"
spctl --add --label "Macro Recorder" "$DEST/$APP"
spctl --enable --label "Macro Recorder"

echo "✅ Installation complete! Launch Macro Recorder from /Applications (or Spotlight)."
