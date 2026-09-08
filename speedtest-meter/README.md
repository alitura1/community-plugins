# Speedtest Meter

Run an internet speed test with a live speedometer and detailed results.

## What it does

Speedtest Meter runs a network speed test using the Ookla Speedtest CLI or
`speedtest-cli`, displaying real-time results with a live speedometer
gauge. It measures:

- Download speed (Mbps)
- Upload speed (Mbps)
- Ping (ms)
- Jitter (ms)
- Packet loss (%)
- Server details (name, host, location, country, IP)
- Connection details (ISP, external IP, city, region, country, organization)

The panel shows a visual speedometer during the test and displays full
technical results upon completion.

## Plugin

| Field | Value |
| --- | --- |
| ID | `nilsonlinux/speedtest-meter` |
| Entries | Bar widget: `speedtest-widget`; Panel: `speedtest` |

**Entries:**
- **Widget:** `speedtest-widget` - Shows an icon in the bar; click to open the panel
- **Panel:** `speedtest` - Runs the speed test and displays the results

## Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `glyph` (widget) | `glyph` | `brand-speedtest` | Icon shown in the bar for the `speedtest-widget` widget. |

## Requirements

At least one of the following must be installed and on PATH:

- **`speedtest`** (Ookla CLI) - preferred backend; gives a truly live gauge
  with per-phase progress. `speedtest --version` is checked for the string
  "Ookla" before it's trusted, since some distros' `speedtest-cli` package
  also installs a same-named `speedtest` binary.
- **`speedtest-cli`** (Python implementation) - fallback backend. No
  incremental progress, so the gauge pulses instead of tracking real
  numbers while it runs — the final result is still complete either way.
- **`stdbuf`** (coreutils) - used, when present, to force line-buffered
  output from the Ookla CLI so the live gauge updates in real time instead
  of only at the end. Present on virtually every Linux system.

Install the Ookla Speedtest CLI (recommended) or the Python fallback:

```bash
# Arch Linux (AUR) — package name varies, check `yay -Ss speedtest` first
yay -S speedtest-bin

# Ubuntu/Debian
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest

# Fedora
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
sudo dnf install speedtest

# Or the Python fallback (also in most distros' official repos, e.g.
# Arch: pacman -S speedtest-cli, plus Debian/Ubuntu, Fedora, openSUSE, Alpine)
pip install speedtest-cli
```

`stdbuf` ships as part of coreutils and is already installed on virtually
every Linux system — no separate install step needed.

If neither speedtest tool is found, the error screen shows the right
install command for the detected package manager (pacman/apt/dnf/zypper/apk)
automatically.

## External dependencies

### Third-party services

- **ipapi.co** - After every successful test, the panel sends one request
  to `https://ipapi.co/json/` to resolve the client's public IP into
  geolocation data (city, region, country, organization) shown alongside
  the test server's own location. No data is stored or transmitted beyond
  that single request.

## Installation

Install via Noctalia Plugin Store.

## Usage

1. Click the widget in the bar to open the panel
2. Click "Start test" to run a speed test
3. Watch the gauge while it runs (live numbers with the Ookla backend, a
   pulse with the legacy backend)
4. Review the results: download/upload, ping, jitter, packet loss, test
   server details, your ISP and external IP

## Panel IPC Command

To toggle the panel from outside the plugin:

```
noctalia msg panel-toggle nilsonlinux/speedtest-meter:speedtest
```

## Notes for further development

- `[[panel]]` field names (`width`/`height`) in `plugin.toml` are still
  unconfirmed against Noctalia's real schema; `[[widget]]` /
  `[[widget.setting]]` are confirmed against a working `rss-notifier`
  plugin.
- Icon names (`brand-speedtest`, `arrow-down`, `arrow-up`, `clock`,
  `activity`, `shield-check`, etc.) are Tabler Icons names, confirmed
  rendering correctly in testing.
- Color/style props (`fill`, `radius`, `color` role names like
  `primary`/`secondary`/`on_surface_variant`, and the `"role/opacity"`
  shorthand like `"primary/0.12"`) are confirmed working.

## License

MIT
