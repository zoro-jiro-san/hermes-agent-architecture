# Security + Sandbox + Disk Hygiene

Operational hardening layer for low-disk autonomous agent runtime.

```
                     ┌───────────────────────────────────┐
                     │   Incoming files / scraped data   │
                     └────────────────┬──────────────────┘
                                      │
                                      ▼
                           ┌────────────────────┐
                           │ scan-file.sh       │
                           │ (ClamAV daemon)    │
                           └───────┬────────────┘
                                   │ clean                    infected
                                   │                          ▼
                                   ▼                 ┌──────────────────┐
                         ┌──────────────────┐        │ ~/.hermes/       │
                         │ Process normally │        │ quarantine/       │
                         └──────────────────┘        └──────────────────┘


┌────────────────────────────────────────────────────────────────────────────┐
│ Daily 03:45 Malware Scan                                                  │
│  - clamdscan /home,/tmp                                                   │
│  - rkhunter rootkit checks                                                │
│  - lynis quick hardening audit                                            │
│  - logs -> ~/.hermes/logs/malware-scan-YYYY-MM-DD.log                    │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│ Daily 06:30 Disk Cleanup                                                   │
│  1) Push useful /tmp artifacts to private GitHub repo                      │
│  2) Clean /tmp, npm cache, uv cache                                        │
│  3) Delete local repos only if clean + fully pushed                         │
│  4) Keep runtime essentials (hermes-agent, skills, configs)                │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│ Lightweight Sandbox for risky commands                                     │
│  bubblewrap (bwrap) via ~/.hermes/scripts/sandbox-run.sh                  │
│  - tiny footprint (~50KB package, ~189KB installed size)                  │
│  - unshare namespaces, tmpfs /tmp, isolated workdir                        │
│  - suitable for short untrusted shell/python tasks on ARM + low disk      │
└────────────────────────────────────────────────────────────────────────────┘
```

## Why this layer exists

- Device has constrained storage (29GB total), so retention must be intentional.
- Autonomous coding tools create caches, temp dirs, and cloned repos quickly.
- Security scans reduce risk from web-scraped artifacts and external code.
- Bubblewrap provides minimal-overhead containment compared to heavier VM-style sandboxes.
