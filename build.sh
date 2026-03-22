#!/bin/bash
set -e

FLUTTER_VERSION="3.41.5"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz
  tar -xf flutter.tar.xz -C "$HOME"
  rm flutter.tar.xz
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

if [ -z "${APP_KEY}" ] || [ -z "${APP_SECRET}" ]; then
  echo "ERROR: APP_KEY and APP_SECRET must be set as build environment variables in Cloudflare."
  exit 1
fi

flutter config --no-analytics
flutter pub get
flutter build web \
  --base-href / \
  --dart-define=APP_KEY=${APP_KEY} \
  --dart-define=APP_SECRET=${APP_SECRET}

