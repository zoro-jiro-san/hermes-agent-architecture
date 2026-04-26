#!/bin/bash
# ~/.hermes/scripts/prune-night-research.sh
# Prune and compress nightly research artifacts to bound disk usage.
# Part of Hermes low-resource optimization (2026-04-26).

set -euo pipefail

DIR="${HOME}/.hermes/night-research"

if [[ ! -d "$DIR" ]]; then
    echo "Directory not found: $DIR"
    exit 0
fi

NOW=$(date +%s)
RETENTION_DAYS=30
COMPRESS_AFTER_DAYS=7

deleted=0
compressed=0
kept=0

while IFS= read -r -d '' file; do
    mtime=$(stat -c %Y "$file")
    age_days=$(( (NOW - mtime) / 86400 ))

    if [[ $age_days -gt $RETENTION_DAYS ]]; then
        rm -f "$file"
        deleted=$((deleted+1))
    elif [[ $age_days -gt $COMPRESS_AFTER_DAYS ]]; then
        # Compress only .md files, keep originals replaced with .gz
        if [[ "$file" == *.md ]] && [[ ! "$file" == *.gz ]]; then
            gzip -9 "$file"
            compressed=$((compressed+1))
        fi
    else
        kept=$((kept+1))
    fi
done < <(find "$DIR" -type f -print0)

echo "night-research prune: kept=$kept compressed=$compressed deleted=$deleted"
exit 0
