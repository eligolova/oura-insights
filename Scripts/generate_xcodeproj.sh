#!/bin/zsh

set -euo pipefail
export LC_ALL=C

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/OuraInsights.xcodeproj/project.pbxproj"

cd "$ROOT_DIR"
xcodegen generate

# XcodeGen 2.44 writes objectVersion 77, but the installed Xcode on this machine
# expects the older project format. Normalizing here keeps project generation reproducible.
perl -0pi -e 's/objectVersion = 77;/objectVersion = 56;/' "$PROJECT_FILE"
