# HANDOFF

Korte overdracht om een nieuwe chat/sessie snel en zonder gokken te laten
starten. Zie BLUEPRINT.md voor het volledige beslislog en PROGRESS.md voor
het doorlopende reisverslag.

**Wat:** Universele, geautomatiseerd gebouwde LFS/BLFS **installer-ISO**
("Citizen Dev & AI Command Center"). Boot vanaf USB op willekeurige
(oudere) hardware, installeert permanent naar de interne schijf. XFCE
desktop (Command-Center-Matrix dark theme: diepzwart + neon-groen/
cyaan), 3 uitbreidbare werkbladen (Command Center / AI Matrix / Dev
Studio, Super+1/2/3), live Conky-HUD + devilspie2-window-tiling,
devstack (Node.js, Bun, gh, cloudflared, Supabase CLI, Tailscale,
PostgreSQL, SQLite, n8n, PM2), PWA-snelkoppelingen voor
Claude/ChatGPT/Mistral/Gemini met hotkeys (nog te bouwen).

## AUTOPILOT PAUZE — checkpoint 2026-09-26

Brionize heeft het bouwproces bewust stopgezet op een veilig punt: repo
schoon (geen uncommitted changes), laatste CI-run groen, geen lokale
build-containers actief. Dit document is het "we stoppen hier"-
checkpoint. Een nieuwe sessie herstart met **Re-entry Protocol**
(Matrix §15): eerst deze status lezen, dan BLUEPRINT.md/PROGRESS.md,
dan de laatste GitHub Actions-run controleren vóór er verder gebouwd
wordt — niet blind verdergaan op herinnering.

### Waar staan we aantoonbaar (bewezen, groen, in CI)
**Fase 1 t/m 4 zijn volledig bewezen binnen GitHub Actions**, zeven op
elkaar gestapelde cache-lagen, allemaal samen bewezen in de laatste
groene run (36047165966, ~21m13s met alle lagen hit). ~113 losse
pakketten/tools in totaal:
- **Fase 1 (`01-toolchain`)** — LFS hoofdstuk 5: cross-toolchain
  (binutils/gcc/glibc), virtuele bestandssystemen, chroot-voorbereiding.
- **Fase 2 (`02-base-system`)** — LFS hoofdstuk 6 (temporary tools),
  7 (chroot + laatste temporary tools), 8 (volledig basissysteem,
  ~100 pakketten). Cache-laag: `lfs-bootstrap-*` (fase 1+ch6+7) en
  `lfs-ch8-complete-*` (+ch8).
- **Fase 3 (`03-blfs-desktop`)**, vier sub-fasen elk met eigen
  cache-laag:
  - **03a** — Xorg-basisbibliotheken + server (54 pakketten,
    `lfs-xorg-complete-*`). Bewust Mesa/glamor-vrij (`-D glamor=false
    -D glx=false`, generieke hardware).
  - **03b** — GTK3-supporting-stack incl. het bewust minimale
    LLVM/Mesa-llvmpipe-duo (27 pakketten, `lfs-gtk3-complete-*`).
    Mesa is hier WEL nodig (via libepoxy, GTK3-vereiste) — bewust
    llvmpipe-only (software-rendering, geen GPU-vendor-drivers).
  - **03c** — XFCE-core (17 pakketten + 9 externe dependencies,
    `lfs-xfce-core-complete-*`).
  - **03d** — Conky-HUD, devilspie2/wmctrl (window-tiling), 3
    werkbladen + Super+1/2/3-hotkeys, Command-Center-Matrix-thema
    (zelf samengesteld GTK3-CSS-thema bovenop Adwaita-dark),
    autostart-entries (`lfs-xfce-extras-complete-*`).
- **Fase 4 (`04-devstack-apps`)** — Node.js, Bun, gh, cloudflared,
  Supabase CLI, Tailscale (officiële prebuilt binaries), PostgreSQL +
  SQLite (BLFS, source-build), n8n + PM2 (npm), `lfs-devstack-complete-*`.

Alle downloads via `fetch_verified()` (officiële bron → self-hosted
GitHub-Release-backup → GNU-mirror → Wayback Machine → Software
Heritage → snapshot.debian.org, elk MD5-geverifieerd). Elke fout
onderweg gevonden via de echte CI-log of de daadwerkelijke pakketbron
— nooit gegokt (zie PROGRESS.md voor de volledige, gedateerde
geschiedenis van elke fix).

### Wat nog niet gedaan is (bewust uitgesteld, geen losse taken vergeten)
1. **PWA-snelkoppelingen + browser-engine (WebKitGTK)** — NOG NIET
   GESTART. Chromium/Firefox staan niet in BLFS; WebKitGTK is de enige
   haalbare optie (~21 SBU bouwtijd, 1,5GB schijfruimte, nieuwe
   afhankelijkheidsketen: ICU, Ruby, GStreamer base+bad — vergelijkbaar
   met het eerdere LLVM/Mesa-duo qua impact). Geen kant-en-klare
   browser-toepassing bestaat in BLFS — een minimale WebKitGTK-kiosk-
   shell (C, ~100 regels) zou zelf geschreven moeten worden. Aan
   Brionize voorgelegd als echt beslispunt (2026-09-24); gekozen om
   dit uit te stellen naar een eigen vervolgstap. Zie BLUEPRINT.md
   "Fase 4 — implementatie" voor de volledige afweging.
2. **devilspie2-tegelregels (fase 3d) zijn NOG NIET runtime getest** —
   alleen Lua-SYNTAX gevalideerd (`luac -p`, echt gedraaid in CI).
   Kan niet runtime getest worden zolang er geen browser (punt 1) EN
   geen terminal-emulator bestaan — n8n/Supabase Studio hebben alleen
   een web-UI, geen los venster zonder browser. Coordinator vroeg
   hier expliciet niet van uit te gaan dat de syntax-check genoeg was
   — dit is dus een bewust open, niet vergeten punt.
3. **ISO-verpakking** (squashfs + bootloader) — nog niet gestart.
4. **Installer-naar-schijf-mechanisme** — nog niet gestart.
5. **First-boot-wizard** (lokale gebruikersaanmaak, `tailscale up`,
   `gh auth login`, API-keys naar `~/.env`, PostgreSQL `initdb`, PM2-
   procesdefinities voor n8n/cloudflared-tunnel) — bewust nog niet
   gebouwd; deze per-machine-taken zijn expliciet gescheiden gehouden
   van de generieke image-build (zie BLUEPRINT.md "Architectuur/
   Aanpak" en de PostgreSQL/PM2-scope-grens in "Fase 4 — implementatie").
6. **Terminal-emulator** (bv. xfce4-terminal) — nog niet gebouwd, ook
   niet expliciet in een fase-lijst opgenomen; nodig voor punt 2 en
   voor "GitHub-terminal"/"terminal-logs" uit de tegelindeling.
7. **XFCE dark theme was al gedaan** (Command-Center-Matrix, zie fase
   3d) — geen open punt meer, alleen xfwm4's eigen randdecoratie/
   titelbalk-thema bleef bewust op het standaard "Default"-thema
   (bitmap-gebaseerd, buiten scope zonder beeldbewerkingsgereedschap).

**Belangrijke, al genomen beslissingen (niet opnieuw ter discussie
stellen zonder goede reden — zie Sunk Cost/Anti-Patch-Loop-regels in
de Matrix als dat toch nodig lijkt):**
- LFS/BLFS bewust gekozen boven een pragmatischer Debian/Ubuntu-based
  live-build.
- Docker mag als wegwerp-bouwsandbox (CI + lokaal), niet in het
  eindproduct.
- Installer-naar-schijf, geen live-boot-only.
- Repo **publiek** (niet privé) voor onbeperkte Actions-minuten tijdens de
  bouwfase; kan later bewust naar privé.
- Grondregel: **nooit hardcoded secrets** — alles via `.env.example` +
  first-boot wizard.
- Git-commit-identiteit voor dit project lokaal op
  `Brionize <brionize.nl@gmail.com>`.
- Mesa: llvmpipe-only (software-rendering, geen GPU-vendor-drivers) —
  zowel bij xorg-server (glamor uit) als bij de GTK3-stack (Mesa via
  libepoxy, wel nodig, maar minimaal geconfigureerd).
- PWA/browser-engine: uitgesteld, WebKitGTK is de voorziene route
  zodra die stap wordt opgepakt (geen Chromium/Firefox, staan niet in
  BLFS).
- "systemd watchdogs" (oorspronkelijke fase-4-omschrijving) bestaat
  niet op dit systeem — PM2 vervult die rol, geen aparte oplossing
  nodig.

**Bekend, nu WEERLEGD risico:** de 6-uur/14GB-limiet van één GitHub
Actions-job bleek geen probleem — de zeven-laags-cache-architectuur
houdt elke losse iteratie ruim binnen enkele minuten tot ~1,5 uur
(alleen bij een cache-miss op een zware laag als 03b/LLVM), en de
losse fase-runs (1-4) blijven elk ruim onder de limiet.

**Eerstvolgende stap (wanneer Autopilot hervat wordt):** kiezen tussen
(a) PWA/browser-engine (WebKitGTK) oppakken, of (b) eerst ISO-
verpakking/installer-naar-schijf/first-boot-wizard, aangezien die niet
van de browserstap afhangen. Zie BLUEPRINT.md "Nog open / bekende
risico's" voor de volledige, actuele lijst.
