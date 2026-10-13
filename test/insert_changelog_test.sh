#!/bin/bash
# Checks insert_changelog.sh with the awk this machine has (BSD awk on macOS, mawk/gawk on Linux).
set -euo pipefail
cd "$(dirname "$0")/.."
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cat > "$WORK/CHANGELOG.md" <<'MD'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

## [0.1.0]

- Initial release
MD

CHANGELOG_CHANGES=$'### Features\n- Coverage reaches 100% on `C:\\new\\tests`\n- Second line' \
  CHANGELOG_FILE="$WORK/CHANGELOG.md" INSERT_LINE=7 VERSION=0.2.0 \
  ./insert_changelog.sh

cat > "$WORK/expected.md" <<'MD'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

## [0.2.0]

### Features
- Coverage reaches 100% on `C:\new\tests`
- Second line

## [0.1.0]

- Initial release
MD

if diff -u "$WORK/expected.md" "$WORK/CHANGELOG.md"; then
  echo "ok: insert_changelog.sh ($(awk --version 2>/dev/null | head -1 || echo "$(command -v awk)"))"
else
  echo "insert_changelog.sh produced unexpected output" >&2
  exit 1
fi
