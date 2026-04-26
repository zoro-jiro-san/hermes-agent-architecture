# Telegram Telemetry Bot Architecture

Device monitoring and alerting via Telegram bot for Raspberry Pi 5 and Hermes Agent health metrics.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   TELEGRAM TELEMETRY BOT ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐        polling / webhook        ┌─────────────────┐   │
│  │ Telegram User   │ ──────────────────────────────▶ │   Telegram      │   │
│  │ (commands)      │   (message updates)            │   Bot API       │   │
│  └────────┬────────┘                                └────────┬────────┘   │
│           │                                                    │            │
│           │ /status /htop /log /plot /fan                     │            │
│           │                                                    │            │
│           ▼                                                    ▼            │
│  ┌─────────────────┐                                ┌─────────────────┐   │
│  │ Telegram Bot    │ ────────────────────────────── │  Update webhook │   │
│  │ (python script) │   receive message               │  handler        │   │
│  │                 │                                 │  (main.py)      │   │
│  │  bin/pi-bot     │                                 └────────┬────────┘   │
│  │  main.py        │                                          │            │
│  └────────┬────────┘                                          │            │
│           │                                                   │            │
│           │ Parse command                                     │            │
│           ▼                                                   │            │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │  COMMAND ROUTER                                                 │       │
│  │  /start     → welcome_msg()                                     │       │
│  │  /status    → system_overview()  (CPU, RAM, disk, temp, fan)   │       │
│  │  /htop      → process_list()    (~20 rows, monospace)          │       │
│  │  /log [N]   → tail_syslog(N)    (default 20)                    │       │
│  │  /plot [m]  → ascii_sparkline() (temp or CPU, 24h)             │       │
│  │  /fan       → fan_details()     (PWM, RPM)                      │       │
│  │  /reboot    → reboot_system()   (admin auth)                    │       │
│  └─────────────────────────────┬───────────────────────────────────┘       │
│                                │                                          │
│      ┌─────────────────────────┼─────────────────────────────┐             │
│      │                         │                             │             │
│      ▼                         ▼                             ▼             │
│  ┌──────────┐           ┌──────────────┐             ┌──────────────┐     │
│  │ psutil   │           │ vcgencmd     │             │ systemd      │     │
│  │ library  │           │ (RPi temp)   │             │ journal      │     │
│  │          │           │              │             │ (logs)       │     │
│  │ • CPU%   │           │ • temp_core  │             │              │     │
│  │ • RAM%   │           │ • GPU temp   │             │ • tail -n    │     │
│  │ • disk%  │           │              │             │ • journalctl │     │
│  │ • net    │           │              │             │              │     │
│  │ • proc   │           │              │             │              │     │
│  └──────────┘           └──────────────┘             └──────────────┘     │
│      │                         │                             │             │
│      └─────────────────────────┴─────────────────────────────┘             │
│                                │                                          │
│                                ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │  RESPONSE FORMATTER                                             │       │
│  │  • Markdown or monospace code blocks for /htop                  │       │
│  │  • ASCII sparklines for trends                                  │       │
│  │  • Emoji status indicators (✅ ⚠️ ❌)                          │       │
│  │  • Truncate to 4096 chars (Telegram limit)                      │       │
│  └─────────────────────────────┬───────────────────────────────────┘       │
│                                │                                          │
│                                ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │  bot.send_message(chat_id, formatted_text)                       │       │
│  └─────────────────────────────┬───────────────────────────────────┘       │
│                                │                                          │
│                                ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │  Automatic Alerting (background task)                            │       │
│  │  ┌───────────────────────────────────────────────────────────┐ │       │
│  │  │ Every 30 minutes:                                          │ │       │
│  │  │   if temp > 70°C or RAM > 90%:                             │ │       │
│  │  │     → send alert: "⚠️ High temperature: 72°C"              │ │       │
│  │  │   if disk < 10% free:                                      │ │       │
│  │  │     → send alert: "❌ Disk almost full: 92% used"          │ │       │
│  │  └───────────────────────────────────────────────────────────┘ │       │
│  └─────────────────────────────────────────────────────────────────┘       │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐         │
│  │  Persistent State                                                 │         │
│  │  ~/.pi-telemetry/                                                 │         │
│  │  ├── metrics.log      (time-series JSONL)                        │         │
│  │  ├── config.yaml      (thresholds, chat IDs, auth)               │         │
│  │  └── auth_users.json  (admin user IDs for /reboot)               │         │
│  └─────────────────────────────────────────────────────────────────┘         │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐         │
│  │  Systemd Service (autostart)                                      │         │
│  │  ~/.config/systemd/user/pi-telemetry-bot.service                  │         │
│  │  • Restart=on-failure                                            │         │
│  │  • WantedBy=default.target                                       │         │
│  │  • ExecStart=python3 /home/.../pi-telemetry-bot/bin/main.py      │         │
│  └─────────────────────────────────────────────────────────────────┘         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Telemetry Metrics Collected

| Metric | Source | Frequency | Purpose |
|--------|--------|-----------|---------|
| CPU %  | `psutil.cpu_percent()` | On-demand + 30m polling | Load monitoring |
| RAM %  | `psutil.virtual_memory()` | On-demand + 30m polling | Memory pressure |
| Disk % | `psutil.disk_usage('/')` | On-demand | Storage capacity |
| Temp °C | `vcgencmd measure_temp` (RPi) | On-demand + 30m polling | Overheat prevention |
| Fan RPM | `/sys/devices/platform/.../fan` | On-demand | Cooling status |
| Processes | `psutil.process_iter()` | On-demand (/htop) | Debug resource hogs |
| Syslog | `journalctl -n` or `/var/log/syslog` | On-demand (/log) | Error investigation |

## Authentication & Security

- Admin-only commands (`/reboot`) check user ID against `auth_users.json`
- Bot token stored in environment variable `TELEGRAM_BOT_TOKEN` or config file
- No root privileges required (except for `/reboot` via `sudo`)
- Rate limiting can be added per chat_id in config

## Integration with Hermes Agent

Hermes Agent can invoke the telemetry bot as a skill:

```
/hermes-agent
  └─ skills/
     └─ system-monitoring/
        └─ SKILL.md  → defines trigger "when user asks about system status"
                       → runs: python3 ~/github/pi-telemetry-bot/bin/main.py --status --json
                       → parses JSON response → formats for chat
```

The bot can also **push proactive alerts** to a configured Hermes Telegram chat ID when thresholds breached.

## Deployment

1. **Install dependencies**: `pip install psutil python-telegram-bot`
2. **Configure**: Edit `~/.pi-telemetry/config.yaml` (bot token, thresholds, authorized users)
3. **Install systemd service**: `sudo ./install.sh` or manual systemd file
4. **Start**: `systemctl --user start pi-telemetry-bot` (or `sudo systemctl start pi-telemetry-bot` system-wide)

## Files

```
pi-telemetry-bot/
├── bin/
│   └── main.py              # Entry point, command router
├── lib/
│   ├── metrics.py           # psutil wrappers
│   ├── fan.py               # Raspberry Pi fan control
│   ├── alerts.py            # Threshold checker, scheduler
│   └── formatter.py         # Markdown/ASCII formatting
├── config/
│   └── config.yaml.example  # Template
├── systemd/
│   └── pi-telemetry-bot.service
├── install.sh               # One-command installer
└── README.md
```
