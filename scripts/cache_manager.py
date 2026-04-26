#!/usr/bin/env python3
"""
~/.hermes/lib/cache_manager.py — Size-bounded LRU cache eviction.
Part of low-resource optimization (2026-04-26).
"""

import os
import sys
from pathlib import Path

CACHE_DIR = Path.home() / ".hermes" / "cache"
MAX_TOTAL_MB = 100  # hard cap

def enforce_lru():
    if not CACHE_DIR.exists():
        return

    entries = []
    total = 0
    for f in CACHE_DIR.iterdir():
        if f.is_file():
            size = f.stat().st_size
            mtime = f.stat().st_mtime
            entries.append((f, size, mtime))
            total += size

    if total <= MAX_TOTAL_MB * 1024 * 1024:
        return  # under limit

    # Sort by mtime ascending (oldest first)
    entries.sort(key=lambda x: x[2])

    removed = 0
    saved = 0
    while total > MAX_TOTAL_MB * 1024 * 1024 and entries:
        f, size, _ = entries.pop(0)
        try:
            f.unlink(missing_ok=True)
            total -= size
            removed += 1
            saved += size
        except Exception:
            pass

    print(f"cache_manager: removed={removed} files, reclaimed={saved/1024:.1f} KB, final_total={total/1024:.1f} KB")

if __name__ == "__main__":
    enforce_lru()
