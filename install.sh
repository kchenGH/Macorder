#!/usr/bin/env bash

# install.sh — copies the app to /Applications and removes quarantine flag
set -e

# Re-run with sudo if not root
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

echo "✅ Installation complete!"
echo "If Gatekeeper still blocks the app, right-click (or control-click) on the app in /Applications and choose ‘Open’ to authorize it."
