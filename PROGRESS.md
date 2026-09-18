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
