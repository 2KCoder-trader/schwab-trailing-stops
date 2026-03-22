#!/bin/bash
set -e

FLUTTER_VERSION="3.27.4"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz
  tar -xf flutter.tar.xz -C "$HOME"
  rm flutter.tar.xz
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics
flutter pub get
flutter build web --base-href /
