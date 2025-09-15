#!/usr/bin/env bash
set -euo pipefail

bold() { printf "\033[1m%s\033[0m\n" "$*"; }
ok()   { printf "✅ %s\n" "$*"; }
err()  { printf "❌ %s\n" "$*" >&2; }

PROJECT_NAME="${1:-MovieBrowser}"
PROJECT_BUNDLE="$PROJECT_NAME.xcodeproj"

# Preconditions
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This script must run on macOS."
  exit 1
fi

command -v brew >/dev/null 2>&1 || { err "Homebrew not found. Install from https://brew.sh/"; exit 1; }
ok "Homebrew found."

command -v xcodegen >/dev/null 2>&1 || { err "XcodeGen not found. Install with: brew install xcodegen"; exit 1; }
ok "XcodeGen found: $(xcodegen --version)"

if ! command -v swiftlint >/dev/null 2>&1; then
  err "SwiftLint not found. Install with: brew install swiftlint"
else
  ok "SwiftLint found: $(swiftlint version)"
fi

# Generate
bold "Generating Xcode project with XcodeGen…"
xcodegen generate
ok "Project generated. Open $PROJECT_BUNDLE"

# Open the .xcodeproj
if [[ ! -d "$PROJECT_BUNDLE" ]]; then
  DETECTED="$(ls -1 *.xcodeproj 2>/dev/null | head -n 1 || true)"
  if [[ -n "$DETECTED" ]]; then
    PROJECT_BUNDLE="$DETECTED"
  else
    err "Could not find a .xcodeproj to open."
    exit 1
  fi
fi

open "$PROJECT_BUNDLE"
ok "Opened: $PROJECT_BUNDLE"