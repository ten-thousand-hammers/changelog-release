#!/bin/bash
# Inserts a "## [VERSION]" section holding CHANGELOG_CHANGES into CHANGELOG_FILE at INSERT_LINE.
#
# The text goes through ENVIRON rather than `awk -v`: BSD awk (macOS runners) rejects multi-line -v
# values ("newline in string"), and -v would also turn backslash sequences in the notes into escapes.
set -euo pipefail

: "${CHANGELOG_FILE:?}" "${INSERT_LINE:?}" "${VERSION:?}"
INSERT="$(printf '\n## [%s]\n\n%s' "$VERSION" "${CHANGELOG_CHANGES:-}")"
export INSERT
awk -v line="$INSERT_LINE" 'NR==line{print ENVIRON["INSERT"]}1' \
  "$CHANGELOG_FILE" > "$CHANGELOG_FILE.tmp" && mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"
