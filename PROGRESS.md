# PROGRESS — reisverslag

## 2026-09-18
- Project gestart: `brionize-command-center` (map was leeg, geen git-repo).
- Sparsessie (Stap 2): LFS/BLFS vs. Debian/Ubuntu-based live-build
  afgewogen. AI adviseerde Debian-based (haalbaarder in CI); Brionize kiest
  bewust voor LFS/BLFS, met lokale build op eigen Asus als fallback als
  GitHub Actions het qua tijd/schijfruimte niet aankan.
- Gedeelde Gemini-conversatie doorgenomen en kritisch nagelopen. Gevonden en
  opgelost:
  - Docker-in-CI-tegenspraak (Brionize's "geen Docker"-wens gold voor het
    proces zelf, niet voor de wegwerp-CI-sandbox) → Docker toegestaan als
    build-sandbox, niet in eindproduct.
  - Hardware-specifieke kernel-tegenspraak → generieke kernelconfig.
  - Conky ≠ live app-tegels → apart window-tiling-mechanisme nodig.
  - Live-boot vs. installer-naar-schijf onduidelijk → installer-naar-schijf
    gekozen (stick-hitte/slijtage-overweging van Brionize).
  - Publiek-repo-advies van Gemini vs. Matrix-standaard (privé) → bewust
    publiek gekozen voor onbeperkte Actions-minuten.
- **GO gegeven.**
- Git-identiteit: lokaal (niet globaal) gezet op
  `Brionize <brionize.nl@gmail.com>`, omdat de globale git-config op een
  ander account (dweedledo-wq) stond terwijl het actieve `gh`-account
  brionize-nl is.
- Projectdocumenten opgezet: BLUEPRINT.md, PROGRESS.md, SETUP.md,
  HANDOFF.md, `.env.example`, `.gitignore`.
- **Volgende stap:** bouwmodus kiezen (Samen Bouwen / Autopilot), publieke
  GitHub-repo aanmaken en pushen, daarna starten met fase 1
  (`01-toolchain`-scripts).
- Bouwmodus gekozen: **Autopilot** (met toestemming om Codex CLI erbij te
  betrekken indien nuttig — beide staan lokaal geïnstalleerd/ingelogd).
- Publieke repo aangemaakt en gepusht:
  https://github.com/brionize-nl/brionize-command-center
- Fase 1 (`01-toolchain`) geschreven: Docker-sandbox
  (`docker/Dockerfile.build`) + modulaire scripts voor LFS 12.4 hoofdstuk
  4.2/4.3 (directory-layout, lfs-gebruiker) en hoofdstuk 5
  (Binutils/GCC pass 1, Linux API headers, Glibc, Libstdc++ pass 1).
  Commando's en pakketversies/checksums letterlijk overgenomen van de
  officiële LFS 12.4-boekpagina's (niet uit het geheugen), zie commit
  `3d5b26b`.
- **Incident:** de fase 1-build is per ongeluk lokaal gedraaid (Docker op
  Brionize's eigen Asus) om te valideren dat de scripts kloppen. Dat is
  fout — deze machine draait al 24/7 productie (n8n, een bot) en de
  GCC-compile trok de load naar 10+. Brionize heeft dit terecht
  gecorrigeerd; de container is handmatig gestopt (`docker stop`, exit
  code 137/SIGKILL) en de partiële build-artifacts (~2GB onder `build/`)
  zijn opgeruimd. **Les:** lokaal draaien op Brionize's machine is en
  blijft een bewuste, latere fallback-keuze van Brionize zelf — niet iets
  wat automatisch of "even ter validatie" gebeurt. Zie ook HANDOFF.md.
  - Wat er wél uit dat afgebroken lokale run bleek (nuttig bewijs, geen
    verspilde moeite): host-voorbereiding, source-download+checksums en
    Binutils Pass 1 liepen zonder fouten door; GCC Pass 1 was middenin het
    compileren (nog geen fout gezien) toen de container gestopt werd.
- Validatie verplaatst naar **GitHub Actions**: `.github/workflows/build-iso.yml`
  toegevoegd — draait dezelfde Docker-sandbox/scripts als
  `scripts/build-local.sh` (één bouwpad, twee omgevingen), met een
  disk-cleanup-stap en een 350-minuten job-timeout (marge onder de harde
  6-uur-limiet). Logs en (bij succes) het `$LFS/tools`-archief worden als
  workflow-artifact geüpload (retentie 1 dag).
