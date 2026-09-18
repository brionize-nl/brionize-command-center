# BLUEPRINT — Citizen Dev & AI Command Center ISO

## Doel
Een universele, geautomatiseerd gebouwde LFS/BLFS-installer-ISO. Boot vanaf USB
op willekeurige (oudere) hardware en installeert zichzelf permanent op de
interne schijf: een 24/7 "Citizen Developer & AI Command Center".

## Architectuur / Aanpak
- **Basis:** LFS/BLFS from-scratch — bewuste keuze van Brionize, ondanks het
  geadviseerde alternatief (Debian/Ubuntu-based live-build). Zie Beslislog.
- **Build-sandbox:** Docker (chroot-achtig) — uitsluitend als wegwerp-
  bouwomgeving, zowel in GitHub Actions als lokaal. Het eindproduct (de ISO)
  bevat zelf **geen** Docker.
- **Type ISO:** volledige installer-naar-schijf. Geen live-boot-only (i.v.m.
  hitte/slijtage van een persistent-USB-stick en 24/7-gebruiksdoel).
- **Kernel:** generieke, breed-compatibele configuratie (brede driver-
  modules). Geen hardware-specifieke tuning, omdat de build in een generieke
  cloud-VM draait zonder kennis van de uiteindelijke doel-pc.
- Modulaire, herstartbare bouwscripts met checkpoints per fase (niet één
  monoliet-script).

## Bouwfasen
1. `01-toolchain` — LFS hoofdstuk 5 & 6: cross-compiler (binutils, gcc,
   glibc), virtuele bestandssystemen, chroot.
2. `02-base-system` — LFS hoofdstuk 7–9: basissysteem, generieke kernel,
   GRUB-bootloader.
3. `03-blfs-desktop` — Xorg, XFCE (dark theme), 3 standaard werkbladen
   (Command Center / AI Matrix / Dev Studio, hotkeys Super+1/2/3, door
   gebruiker vrij uitbreidbaar), Conky (live systeem-HUD: CPU/RAM/opslag,
   Tailscale-status, logs), losse window-tiling scripting (bv. devilspie2 /
   wmctrl) voor live app-tegels/PiP-gevoel — dit is bewust gescheiden van
   Conky, dat alleen tekst/grafieken kan tonen en geen andere vensters kan
   embedden.
4. `04-devstack-apps` — Node.js, Bun, Python 3, PostgreSQL, SQLite,
   Supabase CLI, GitHub CLI (`gh`), n8n, Tailscale, cloudflared, PM2 +
   systemd watchdogs (zelfherstellend), PWA-snelkoppelingen voor Claude AI,
   ChatGPT, Mistral AI en Gemini met hotkeys (Super+C/G/M/A).
5. `first-boot` wizard — draait éénmalig op de doel-pc: lokale
   gebruikersaanmaak, `tailscale up`, `gh auth login`, optionele API-keys
   (Anthropic/OpenAI/Gemini/Mistral) naar `~/.env`. Schakelt zichzelf na
   afloop zelfstandig uit.

## CI-strategie (GitHub Actions)
- **Repo: PUBLIEK** — bewuste keuze voor onbeperkte, gratis Actions-minuten
  tijdens de zware, iteratieve bouwfase. Kan later bewust naar privé zodra
  het product stabiel is (dan geldt 2000 gratis min/maand).
- Fase-gewijze, aparte jobs met caching/artifacts tussen jobs, zodat elke
  job zijn eigen 6-uur-limiet krijgt (de klok reset per job).
- Disk-cleanup-stap aan het begin van elke job (standaard runner-tooling
  verwijderen voor meer vrije schijfruimte).
- **Lokale fallback:** dezelfde Docker-gebaseerde scripts draaien
  desnoods op Brionize's eigen Asus-machine wanneer een CI-job vastloopt op
  tijd of schijfruimte. Geen aparte scripts nodig — één bouwpad, twee
  omgevingen.

## Bronbeschikbaarheid & fallback-beleid (vaste bouw-aanpak)
LFS-mirrors — vooral dated snapshots zoals ncurses' `current/`-map — rollen
geregeld bestanden weg (ervaring van Brionize, bevestigd op 2026-09-18 toen
`ncurses-6.5-20250809.tgz` van invisible-mirror.net verdween). Dit wordt niet
telkens als losse onderbreking behandeld, maar is standaardgedrag van elke
`fetch`-stap in elke fase, via de herbruikbare functie `fetch_verified()` in
`scripts/lib/fetch-verified.sh` (gebruikt door `01-toolchain` en
`02-base-system`, en straks ook `03-blfs-desktop`/`04-devstack-apps`):

1. Probeer eerst de officiële/gepinde URL uit de LFS wget-list.
2. Bij falen: automatisch, in volgorde, GNU-mirrornetwerk (`ftpmirror.gnu.org`,
   alleen relevant voor `ftp.gnu.org`-URL's), Wayback Machine (via de CDX-API,
   niet de rate-gelimiteerde `available`-API), Software Heritage en
   snapshot.debian.org (beide laatste zijn best-effort — geen generieke
   bestandsnaam-lookup mogelijk zonder vooraf bekende hash/pakketversie, dus
   leveren in de praktijk zelden een hit, maar staan wel in de keten).
3. **Verplichte checksum-verificatie** tegen de officiële LFS md5sums, hoe dan
   ook — dit is de enige reden dat dit zonder mens/AI-tussenkomst mag: bij een
   match is het bewijsbaar exact hetzelfde bestand, ongeacht de bron.
4. Bij match: doorgaan, met een duidelijke logregel (bestand, gebruikte bron,
   bevestigde checksum) in de build-logs — geen onderbreking.
5. Bij falen van alle bronnen, of als nergens een checksum matcht: **stoppen
   en escaleren** als een echt beslispunt (mogelijke versie-afwijking) — dit
   wordt nooit stilzwijgend doorgedrukt naar een andere versie.

## Security / Secrets (grondregel, niet-onderhandelbaar)
- **Nooit hardcoded secrets, accounts of persoonlijke data in de repo** —
  ook niet tijdens de publieke periode.
- `.env.example` bevat alleen placeholders; echte waarden komen uitsluitend
  via de first-boot wizard op de doel-pc, in een lokale `.env` (uitgesloten
  via `.gitignore`).
- Geen API-keys of tokens in de workflow-yml.

## Nog open / bekende risico's
- Fase 1 (LFS-toolchain, hoofdstuk 5) is **bewezen** binnen GitHub Actions:
  26m15s op een standaard `ubuntu-latest`-runner (zie PROGRESS.md,
  run 35390915855) — ruim binnen de 6-uur-limiet. Voor fase 2-4 (basissysteem,
  XFCE-desktop, devstack) is dit nog niet bewezen; die zijn zwaarder. Mitigatie
  (fase-chaining + lokale fallback) staat, wordt per fase opnieuw getoetst.
- Exacte pakketlijst/versies voor de BLFS-desktopstack nog niet in detail
  uitgewerkt.
- Window-tiling-implementatie (devilspie2/wmctrl) voor de live app-tegels
  nog niet in detail uitgewerkt.

## Beslislog
- **2026-09-18 — GO gegeven.**
  - LFS/BLFS gekozen i.p.v. Debian/Ubuntu-based live-build (bewust, ondanks
    geadviseerd alternatief vanwege CI-tijd/schijfruimte-risico).
  - Docker toegestaan als CI/lokale bouwsandbox, niet in het eindproduct.
  - Installer-to-disk gekozen i.p.v. live-boot-only.
  - Repo **publiek** (niet privé) voor onbeperkte Actions-minuten, met
    optie om later bewust naar privé te gaan.
  - Git-commit-identiteit voor dit project lokaal gezet op
    `Brionize <brionize.nl@gmail.com>` (afwijkend van de globale
    git-config, die op een ander account stond).
