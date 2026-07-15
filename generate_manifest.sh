#!/usr/bin/env bash
# Regenerate Repository_Manifest.txt from tracked files.
# Excludes Obsidian app config; includes the manifest itself for self-consistency.
set -euo pipefail
cd "$(dirname "$0")"
git -c core.quotepath=false ls-files \
  | grep -v '^\.obsidian/' \
  > Repository_Manifest.txt
echo "Manifest regenerated: $(wc -l < Repository_Manifest.txt) entries"
