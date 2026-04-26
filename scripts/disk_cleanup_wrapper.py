#!/usr/bin/env python3
"""
~/.hermes/scripts/disk_cleanup_wrapper.py — Standalone wrapper for disk-cleanup plugin.
Loads disk_cleanup.py via importlib (bypasses package naming issues) and exposes
quick/deep/status as CLI subcommands.

Used by ~/.hermes/scripts/disk-monitor.sh for reactive cleanup.
"""

import json
import sys
import os
from pathlib import Path

# ---------------------------------------------------------------------------
# Locate and load disk_cleanup.py as a standalone module
# ---------------------------------------------------------------------------

AGENT_ROOT = Path(__file__).resolve().parent.parent / "hermes-agent"
PLUGIN_DIR = AGENT_ROOT / "plugins" / "disk-cleanup"
MODULE_PATH = PLUGIN_DIR / "disk_cleanup.py"

if not MODULE_PATH.exists():
    print(f"ERROR: Plugin module not found at {MODULE_PATH}", file=sys.stderr)
    sys.exit(1)

# Add AGENT_ROOT to path so that `from hermes_constants import get_hermes_home` works
sys.path.insert(0, str(AGENT_ROOT))

# Import via spec to avoid hyphen-in-dirname package issues
import importlib.util
spec = importlib.util.spec_from_file_location("disk_cleanup_standalone", MODULE_PATH)
dg = importlib.util.module_from_spec(spec)
try:
    spec.loader.exec_module(dg)
except Exception as e:
    print(f"ERROR loading plugin module: {e}", file=sys.stderr)
    sys.exit(1)

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def run_quick():
    result = dg.quick()
    # Print JSON for machine parsing (monitor script uses it)
    print(json.dumps(result, indent=2, default=str))
    return 0

def run_deep():
    # Auto-confirm conservative items: size < 100MB, old temp/research, tests
    def confirm(item):
        size_mb = item["size"] / (1024*1024)
        if size_mb < 100:
            return True
        # Age-based auto-confirm for non-critical categories
        if item["category"] in ("test", "temp", "cron-output"):
            return True
        return False
    result = dg.deep(confirm=confirm)
    print(json.dumps(result, indent=2, default=str))
    return 0

def run_status():
    s = dg.status()
    print(dg.format_status(s))
    return 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: disk_cleanup_wrapper.py {quick|deep|status}")
        sys.exit(2)
    cmd = sys.argv[1]
    if cmd == "quick":
        sys.exit(run_quick())
    elif cmd == "deep":
        sys.exit(run_deep())
    elif cmd == "status":
        sys.exit(run_status())
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(2)
