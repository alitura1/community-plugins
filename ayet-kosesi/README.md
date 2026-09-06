# Ayet Köşesi

A small Noctalia desktop widget that shows one daily verse from the public Akıl Kuran API.

## Plugin

| Field | Value |
|---|---|
| ID | `alitura1/ayet-kosesi` |
| Widget | `ayet` |
| License | MIT |
| Noctalia plugin API | 24 |

## Features

- Deterministic daily verse selection, so everyone gets a stable verse for the day.
- Optional translation/meal author selection.
- Akıl Kuran link for the displayed verse.
- Akıl Kuran logo inside the widget header.
- Logo cache with at most one refresh per day.
- Existing cached logo remains available when the network is unavailable.
- No account, token, or site source code is required.

## Installation

Install it through the Noctalia community plugin source when the plugin is published there.

For local development, place the plugin directory under your Noctalia plugin data directory and reload Noctalia.

## Optional meal selection

By default the public API determines the translation. To select a specific Akıl Kuran translation, create:

```text
~/.config/ayet-kosesi/meal-id
```

and put the numeric author/meal ID in that file, for example:

```text
14
```

The plugin rereads this value every minute. Removing the file returns to the API default.

## Requirements

- Noctalia v5+
- `curl` for the daily logo refresh

The plugin uses `curl` only to download the public Akıl Kuran logo. The plugin never downloads or executes remote code.

## Network and privacy

The widget makes requests only to:

- `https://akilkuran.com/api/quran/surah/<surah>` for verse data.
- `https://akilkuran.com/apple-touch-icon.png?v=3` for the cached logo.

No user account information, browser data, Firebase credentials, cookies, or private site files are read by the plugin.

## Cache

Noctalia's plugin data directory stores the current verse cache and the logo cache. Network failures do not delete existing cached data.

## Credits

Built by `alitura` for Noctalia and Akıl Kuran users.
