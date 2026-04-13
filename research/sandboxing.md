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

## TEE (Trusted Execution Environment) — Production Isolation

*Added 2026-04-13 from TEE deep research*

For production agent deployments where sandboxing is insufficient (agents managing wallets, handling private keys, executing trades), TEEs provide hardware-enforced isolation.

### When to Escalate from Sandboxing to TEE

| Scenario | Sandboxing | TEE |
|---|---|---|
| Running untrusted code snippets | ✅ bubblewrap | Overkill |
| Agent manages crypto wallets | Insufficient | ✅ Required |
| Agent handles user PII | Partial | ✅ Recommended |
| Multi-agent coordination with shared secrets | Insufficient | ✅ Required |
| Autonomous financial transactions | Insufficient | ✅ Required |

### TEE Stack for Agent Deployment

- **dstack** — Docker Compose-native TEE deployment (Intel TDX + NVIDIA GPU CC). No code changes. Open source.
- **Phala Cloud** — Managed TEE infrastructure for AI agents. SOC 2 Type I, HIPAA compliant.
- **NVIDIA H100 GPU CC** — Hardware-level TEE for AI inference, <7% overhead.
- **ERC-8004** — On-chain identity + TEE attestation for verifiable agents.

### Key Insight

Sandboxing (bubblewrap) isolates *processes from the host*. TEEs isolate *computation from everyone* — including the cloud provider, the host OS, and even the developer. For agents that operate autonomously with financial authority, TEEs shift trust from "I trust the operator" to "I trust the hardware + cryptography."

### Resources
- dstack: https://github.com/Dstack-TEE/dstack
- Phala Cloud: https://cloud.phala.com
- ERC-8004: https://github.com/Phala-Network/erc-8004-tee-agent
- Proof-of-Guardrail paper: arXiv:2603.05786
