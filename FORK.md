# atmanli/Onion – Fork-Notizen

Basis: OnionUI/Onion `main` (v4.4.0-beta-20260120) + `v4.5-dev` (Mini-Flip-Unterstützung).

## Von alvin-000/Onion übernommen

| Änderung | Quelle |
|---|---|
| Gesamtes Projekt mit `-O2` bauen (`OPT_LEVEL`, mit `OPT_LEVEL=-O0` abschaltbar) | 2396ea6 |
| Pufferüberläufe in batteryMonitorUI und `list_updateStickyNote` behoben | 232082f |
| Makefile: `build`/`dist` als `.PHONY`, alte Pakete vor dem Packen löschen | Makefile-Fixes |
| Netzwerkzeit nur noch per NTP (tote/falsche Zeit-APIs entfernt) | 72bf07f |
| Scraper: „Exit“ startet nicht mehr das ausgewählte Spiel | 2b67a04 |
| GLO: Mini Flip (285) gilt als WLAN-fähig | 72bf07f |

Bewusst **nicht** übernommen: native 560p-Skalierung (libuiscale/libfbpin), OTA auf alvins Repo,
SearchFilter-Fork, Lade-Bildschirm-Fix (betrifft nur alvins Display-Umbau).

## Cores neu bauen

1. Core-Namen in `.github/cores/wave.txt` eintragen (Bauanleitung je Core in `build_core.sh`).
2. Pushen → Workflow „Build cores“ baut mit der Miyoo-Toolchain und committet die `.so`-Dateien.
   Gebaute Versionen stehen in `.github/core-manifest.tsv`.
3. `RA_SUBVERSION` im Makefile erhöhen (z. B. `1.22.2-1` → `1.22.2-2`), sonst installiert das
   Gerät das neue RetroArch-Paket nicht.
4. Workflow „Pre-release“ manuell starten → ZIP unter Releases (`latest`).
