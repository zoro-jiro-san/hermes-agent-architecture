# Iteration Log — 2026-04-11 (Ops Hardening)

## Summary
Added operational hardening for security and low-disk reliability:

1) Daily malware scanning pipeline
2) Daily post-push disk cleanup pipeline
3) Lightweight bubblewrap sandbox for risky tasks
4) Architecture docs/diagrams updated to reflect new stages

## Changes made

### Security
- Installed and configured:
  - ClamAV + freshclam + clamd daemon
  - rkhunter
  - Lynis
- Added scripts:
  - `~/.hermes/scripts/malware-scan.sh`
  - `~/.hermes/scripts/scan-file.sh`
- Added cron job:
  - 03:45 AM `Daily Malware Scan`

### Disk Management
- Added script:
  - `~/.hermes/scripts/disk-cleanup.sh`
- Cleanup policy:
  - Push useful temp artifacts to private repo first
  - Delete local temp/cache/repos only when safely pushed
- Added cron job:
  - 06:30 AM `Disk Cleanup`

### Sandboxing
- Installed `bubblewrap` (very lightweight)
- Added runner:
  - `~/.hermes/scripts/sandbox-run.sh`
- Intended use:
  - run short untrusted shell/python commands in isolated namespace/tmpfs

## Architecture docs updated
- `diagrams/nightly-pipeline.md` (added malware + cleanup stages)
- `diagrams/security-ops.md` (new diagram)
- `README.md` (linked new diagram)

## Notes
- This update is optimized for constrained hardware/disk.
- Security and disk hygiene are now first-class architecture components, not ad-hoc scripts.
