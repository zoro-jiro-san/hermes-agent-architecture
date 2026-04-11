# Lightweight Sandboxing for Low-Disk Agent Runtime (ARM)

## Context
Host constraints:
- ARM64 Debian
- 29GB total disk
- agent performs autonomous coding, web scraping, and script execution

Goal: choose the lightest practical sandbox that still works for AI agent command execution.

## Candidate Comparison

| Option | Disk footprint | AI-agent compatibility | Isolation model | ARM support | Verdict |
|---|---:|---|---|---|---|
| bubblewrap (`bwrap`) | ~50KB package, ~189KB installed | Excellent for short shell/python command isolation via wrapper script | Linux namespaces + controlled bind mounts + tmpfs | Yes | Best fit |
| Firejail | ~2.6MB installed (+profiles/config overhead) | Good UX, but larger attack surface and setuid model | Namespace/seccomp profiles | Yes | Optional fallback |
| OpenSandbox | Much heavier (Docker/K8s control plane + images) | Excellent for production multi-tenant sandboxes | Container runtime/API platform | Yes (depends on infra) | Too heavy for this host |
| gVisor/Kata | Heavy runtime and ops burden | Better for cloud workloads | User-space kernel / microVM | Mixed | Not suitable for low-disk local |
| nsjail | Lightweight but less packaged on this distro | Good for CTF/server style workloads | Namespaces/seccomp/cgroups | Usually yes | Viable but packaging friction |

## Recommendation

Use **bubblewrap** as default local sandbox primitive.

Why:
1. Minimal disk overhead
2. Strong enough isolation for one-off risky commands
3. Easy scriptable integration with Hermes task flows
4. Works well on ARM without Docker/K8s dependency

## Implementation

Installed:
- `bubblewrap 0.11.0`

Wrapper script:
- `~/.hermes/scripts/sandbox-run.sh`

Usage:
```bash
bash ~/.hermes/scripts/sandbox-run.sh "python3 -c 'print(123)'"
```

## Guardrails

- Use sandbox for untrusted snippets, unknown installers, and quick tests.
- Keep sandbox ephemeral (tmpfs + temp workdir).
- Do not use sandbox for tasks that require persistent state unless explicitly needed.
- Layer with malware scanning for downloaded artifacts.
