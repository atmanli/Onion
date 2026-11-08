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

## Neu gebaute Cores (Welle 1, RA_SUBVERSION 1.22.2-2)

| Core | Quelle | Commit | Stand |
|---|---|---|---|
| fbneo | libretro/FBNeo | 4cdb31f | 2026-11-07 |
| fceumm | libretro/libretro-fceumm | e0f3086 | 2026-11-02 |
| gambatte | libretro/gambatte-libretro | 77f2567 | 2026-10-30 |
| genesis_plus_gx | libretro/Genesis-Plus-GX | f27655b | 2026-10-30 |
| gpsp | libretro/gpsp | 5819380 | 2026-09-19 |
| mame2003_plus | libretro/mame2003-plus-libretro | dff0ba6 | 2026-11-07 |
| mednafen_pce_fast | libretro/beetle-pce-fast-libretro | 2de1ce1 | 2026-10-30 |
| mednafen_supafaust | libretro/supafaust | 642d1d1 | 2026-08-23 |
| nestopia | libretro/nestopia | f1e02d1 | 2026-10-31 |
| pcsx_rearmed | libretro/pcsx_rearmed | 7b0e8f8 | 2026-10-29 |
| picodrive | libretro/picodrive | 1890c29 | 2026-09-26 |
| snes9x2005_plus | libretro/snes9x2005 | a79dfe9 | 2026-09-26 |

FBNeo ohne LTO gebaut (gcc 8.3 der Toolchain stürzt sonst ab). Genesis Plus GX hat kein Cortex-A7-Ziel upstream und wird generisch mit `-mtune=cortex-a7` gebaut.
