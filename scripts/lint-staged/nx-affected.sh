#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
if [ $# -eq 0 ]; then
  echo "No files provided" >&2
  exit 0
fi

mapfile -t rel_files < <(for f in "$@"; do realpath --relative-to="$repo_root" "$f"; done)

comma_separated=$(IFS=, ; echo "${rel_files[*]}")

pnpm exec nx affected:lint --fix --files "$comma_separated"
