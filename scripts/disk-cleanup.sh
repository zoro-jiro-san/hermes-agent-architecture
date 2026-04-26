#!/bin/bash
# Hermes Disk Cleanup — push useful stuff to GitHub, then nuke local
# Rule: If it's on GitHub, delete local. Push /tmp work to private repo first.
# Updated: 2026-04-26 — added cache LRU, nightly research pruning, session archive
set -uo pipefail

log() { echo "[$(date +%H:%M:%S)] $*"; }
BEFORE=$(df / --output=used -BG | tail -1 | tr -d ' G')
GITHUB_USER="zoro-jiro-san"
TMP_REPO="agentic-engineering-2026-04-09"

log "=== Disk Cleanup Started (was ${BEFORE}GB used) ==="

# 0) Ensure SSH key is loaded
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

# 1) Clone the tmp repo to a staging area, stage useful /tmp files, push, delete staging
TMP_STAGING="/tmp/_cleanup_staging_$$"
log "=== Staging /tmp files for GitHub ==="
mkdir -p "$TMP_STAGING"

source ~/.hermes/.env 2>/dev/null || true
git clone "git@github.com:${GITHUB_USER}/${TMP_REPO}.git" "$TMP_STAGING/repo" 2>/dev/null || true

if [[ -d "$TMP_STAGING/repo" ]]; then
    DUMP_DIR="$TMP_STAGING/repo/tmp-dumps/$(date +%Y-%m-%d)"
    mkdir -p "$DUMP_DIR"
    find /tmp -maxdepth 1 -mindepth 1 \
        ! -name ".*" \
        ! -name "systemd-*" \
        ! -name "node-compile-cache" \
        ! -name "_cleanup_*" \
        -newer /tmp -mtime -2 2>/dev/null | while read item; do
        size=$(du -sb "$item" 2>/dev/null | cut -f1)
        [[ "$size" -lt 100 ]] && continue
        [[ "$item" == *.so ]] && continue
        name=$(basename "$item")
        cp -r "$item" "$DUMP_DIR/" 2>/dev/null && log "  Staged: $name ($(du -sh "$item" 2>/dev/null | cut -f1))"
    done
    cd "$TMP_STAGING/repo" 2>/dev/null || true
    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
        git add -A
        git commit -m "tmp-dump: $(date +%Y-%m-%d_%H:%M) — disk cleanup staging" 2>/dev/null || true
        git push origin main 2>/dev/null || git push origin master 2>/dev/null || true
        log "Pushed tmp files to GitHub"
    else
        log "No new tmp files to push"
    fi
else
    log "WARN: Could not clone tmp repo, skipping staging"
fi

# 2) /tmp cleanup — everything older than 1 day
log "=== Cleaning /tmp ==="
find /tmp -maxdepth 1 -mindepth 1 -mtime +1 \
    ! -name ".*" ! -name "systemd-*" ! -name "_cleanup_*" \
    -exec rm -rf {} + 2>/dev/null || true
log "Cleaned /tmp files older than 1 day"

# 3) NPM cache
log "=== npm cache ==="
npm cache clean --force 2>/dev/null || true

# 4) uv cache
if command -v uv &>/dev/null; then
    uv cache prune 2>/dev/null || true
    log "Pruned uv cache"
fi

# 5) Prune nightly research (NEW — low-resource optimization)
log "=== Pruning nightly research ==="
if [[ -x "$HOME/.hermes/scripts/prune-night-research.sh" ]]; then
    bash "$HOME/.hermes/scripts/prune-night-research.sh"
else
    # Fallback: keep last 7 days, delete older
    DIR="$HOME/.hermes/night-research"
    if [[ -d "$DIR" ]]; then
        find "$DIR" -type f -mtime +7 -delete 2>/dev/null || true
        log "Pruned night-research >7d (fallback)"
    fi
fi

# 6) Enforce cache LRU (NEW — low-resource optimization)
log "=== Enforcing cache LRU ==="
if [[ -f "$HOME/.hermes/lib/cache_manager.py" ]]; then
    python3 "$HOME/.hermes/lib/cache_manager.py" 2>/dev/null || true
else
    # Fallback: nuke cache entirely (already done in Janitor, but keep as backup)
    rm -rf "$HOME/.hermes/cache/"* 2>/dev/null || true
    log "Cache purged (fallback)"
fi

# 7) Archive old sessions (NEW — prevent memory.db bloat)
log "=== Session archival ==="
DB="$HOME/.hermes/memory.db"
if [[ -f "$DB" ]]; then
    # Mark inactive >30d as archived (Hermes schema has 'status' column?)
    sqlite3 "$DB" "UPDATE sessions SET status='archived' WHERE status='active' AND last_active < date('now', '-30 days')" 2>/dev/null || true
    # Compress archived session files if stored separately (depends on Hermes schema)
    find "$HOME/.hermes/sessions" -name "*.json" -mtime +30 -exec gzip -9 {} \; 2>/dev/null || true
    log "Session archival complete"
fi

# 8) Find pushed GitHub repos and delete local copies
log "=== Scanning for repos to delete ==="
find /home/tokisaki /tmp -name ".git" -type d 2>/dev/null | while read gitdir; do
    repo=$(dirname "$gitdir")
    case "$repo" in
        */hermes-agent) continue ;;
        */.hermes/*) continue ;;
        */_cleanup_*) continue ;;
    esac
    remote=$(cd "$repo" 2>/dev/null && git remote get-url origin 2>/dev/null || true)
    [[ "$remote" != *"github.com"* ]] && continue
    cd "$repo" 2>/dev/null || continue
    dirty=$(git status --porcelain 2>/dev/null)
    unpushed=$(git log @{u}..HEAD --oneline 2>/dev/null)
    if [[ -z "$dirty" && -z "$unpushed" ]]; then
        size=$(du -sh "$repo" 2>/dev/null | cut -f1)
        log "DELETING (on GitHub): $repo ($size)"
        rm -rf "$repo"
    else
        log "KEEPING (uncommitted/unpushed): $repo"
    fi
done

# 9) Clean up staging
rm -rf "$TMP_STAGING" 2>/dev/null

# 10) Report
AFTER=$(df / --output=used -BG | tail -1 | tr -d ' G')
FREED=$((BEFORE - AFTER))
log "=== Done: ${BEFORE}GB -> ${AFTER}GB (freed ~${FREED}GB) ==="
