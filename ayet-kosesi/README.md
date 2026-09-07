# Ayet Köşesi

Ayet Köşesi is a Noctalia desktop widget powered by Akıl Kuran's public **Günün Ayeti** API.

## Plugin

- **ID:** `alitura1/ayet-kosesi`
- **Entry:** `ayet`
- **License:** MIT

## Requirements

- `curl` must be installed and available on `PATH`; it is used only to refresh the Akıl Kuran logo.

## Usage

Add the `ayet` desktop widget from Noctalia's desktop widget settings.

The plugin polls `https://akilkuran.com/api/daily-verse` once per minute. The API is the single source of truth for Akıl Kuran's current automatic/manual Günün Ayeti.

The optional `author` query parameter is used to request the same daily verse in a selected public translation. The plugin first checks `~/.config/ayet-kosesi/meal-id`; if absent, it executes `~/.local/bin/akilkuran-meal-id`. If no local meal is available, it falls back to a language-based default (Turkish 105, English 32).

The plugin stores only its own verse/logo cache under Noctalia's plugin data directory. It does not access Akıl Kuran user accounts, browser storage, cookies, Firebase credentials, or private source code.
