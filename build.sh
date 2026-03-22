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

flutter config --no-analytics
flutter pub get
flutter build web \
  --base-href / \
  --dart-define=APP_KEY=${APP_KEY} \
  --dart-define=APP_SECRET=${APP_SECRET}

echo "--- build/web contents ---"
ls build/web

# Copy built output to web/ so wrangler picks up the compiled files
cp -r build/web/. web/
