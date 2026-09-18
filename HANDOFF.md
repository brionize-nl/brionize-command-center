# HANDOFF

Korte overdracht om een nieuwe chat/sessie snel en zonder gokken te laten
starten. Zie BLUEPRINT.md voor het volledige beslislog en PROGRESS.md voor
het doorlopende reisverslag.

**Wat:** Universele, geautomatiseerd gebouwde LFS/BLFS **installer-ISO**
("Citizen Dev & AI Command Center"). Boot vanaf USB op willekeurige
(oudere) hardware, installeert permanent naar de interne schijf. XFCE
desktop (dark theme), 3 uitbreidbare werkbladen (Command Center / AI
Matrix / Dev Studio), live Conky-HUD + apart window-tiling-mechanisme voor
live app-tegels, devstack (n8n, Tailscale, cloudflared, Node/Bun/Python,
PostgreSQL/SQLite, Supabase CLI, gh, PM2), PWA-snelkoppelingen voor
Claude/ChatGPT/Mistral/Gemini met hotkeys.

**Status (2026-09-18):** GO gegeven. Projectdocumenten net opgezet, repo
nog aan te maken. Nog **niets** gebouwd of getest. Bouwmodus (Samen Bouwen
vs. Autopilot) nog niet gekozen.

**Belangrijke, al genomen beslissingen (niet opnieuw ter discussie stellen
zonder goede reden — zie Sunk Cost/Anti-Patch-Loop-regels in de Matrix als
dat toch nodig lijkt):**
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

**Bekend, nog niet opgelost risico:** onduidelijk of een volledige
LFS+BLFS+XFCE+devstack-compile binnen de 6-uur/14GB-limiet van één GitHub
Actions-job past. Mitigatie is ontworpen (fase-chaining + lokale fallback
op Brionize's Asus), maar nog niet getest.

**Eerstvolgende stap:** bouwmodus kiezen, publieke GitHub-repo aanmaken en
pushen, starten met fase 1 (`01-toolchain`-scripts).
