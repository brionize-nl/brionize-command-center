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
- **Fase 1 geverifieerd in GitHub Actions — geslaagd.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35390915855
  (getriggerd door de push), job `toolchain` groen in **26m15s**. Dat is
  ruim binnen de 6-uur-limiet — het belangrijkste openstaande risico uit
  BLUEPRINT.md ("past de compile wel binnen 6u/14GB?") is voor fase 1
  beantwoord: ja, met grote marge. Artifacts geüpload:
  `lfs-tools-phase1` (751MB, het gecompileerde `$LFS/tools`) en
  `phase1-toolchain-logs` (612KB). Twee informationele annotaties (Node.js
  20-deprecation in actions/checkout@v4 / upload-artifact@v4, en de
  toekomstige ubuntu-latest→Ubuntu 26-migratie) — geen van beide
  blokkerend, geen actie nodig.
- **Fase 2 geschreven (nog niet gevalideerd):** `scripts/02-base-system/`
  — LFS 12.4 hoofdstuk 6 (17 temporary-tools-pakketten: M4, Ncurses, Bash,
  Coreutils, Diffutils, File, Findutils, Gawk, Grep, Gzip, Make, Patch,
  Sed, Tar, Xz, Binutils/GCC pass 2) en hoofdstuk 7 (chown, virtuele
  kernel-bestandssystemen mounten, chroot binnengaan, Gettext/Bison/Perl/
  Python/Texinfo/Util-linux, cleanup). Commando's/versies/checksums weer
  letterlijk van de officiële LFS 12.4-boekpagina's.
  - **Scopingbeslissing:** hoofdstuk 8 (~85 pakketten, het volledige
    basissysteem) en hoofdstuk 10 (kernel + GRUB-bootloader) zijn bewust
    NIET in deze increment meegenomen — te groot om in één keer blind te
    scripten zonder tussentijds bewijs. Dat wordt de volgende increment,
    na een groene run van hoofdstuk 6+7.
  - **Codex-review (tweede blik, zoals gevraagd):** vond een echte fout —
    de `/etc/hosts`-heredoc had `::1 localhost` per ongeluk op dezelfde
    regel als `127.0.0.1`. Bij het verifiëren tegen de ruwe HTML (niet de
    samengevatte fetch) bleek er ook een eerdere eigen fout te zitten:
    de `/etc/group`-regel voor `bin` was `bin:x:1:` i.p.v. het correcte
    `bin:x:1:daemon` (WebFetch's samenvatting had dat stilzwijgend
    weggelaten). Beide gecorrigeerd vóór er iets richting CI ging.
  - GitHub Actions-workflow uitgebreid: fase 1+2 draaien nu bewust in
    ÉÉN `docker run`-aanroep (de `lfs`-gebruiker/directorylayout van
    fase 1 leeft in de containerlaag, niet in het `$LFS`-volume, dus een
    nieuwe `docker run` zou opnieuw vanaf fase 1 moeten beginnen — dit is
    dus geen dubbel werk maar noodzakelijk), met `--privileged` erbij
    (nodig voor mount/chroot in hoofdstuk 7).
  - `scripts/build-local.sh` in dezelfde lijn bijgewerkt voor later
    gebruik — **niet uitgevoerd**, blijft een bewuste latere keuze van
    Brionize (zie incident hierboven).
- **Fase 1+2-run getriggerd — fase 1 opnieuw geslaagd, fase 2 vastgelopen
  op een dode download-URL (geen tijd/schijf-limiet).** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35394699042
  — hoofdstuk 5 (fase 1) liep binnen dezelfde job weer volledig en foutloos
  door ("Fase 1 (toolchain) volledig doorlopen"). Hoofdstuk 6 begon met
  downloaden; 5 van de ~21 bronnen (perl, gettext, coreutils, findutils,
  util-linux) kwamen binnen, toen brak `ch6-00-fetch-sources.sh` af op:
  ```
  https://invisible-mirror.net/archives/ncurses/current/ncurses-6.5-20250809.tgz
  ERROR 404: Not Found
  ```
  **Root cause geverifieerd (niet uit het geheugen):** die mirror bewaart
  alleen een rollend venster recente dagelijkse ncurses-snapshots onder
  `current/`; de door LFS 12.4's officiële wget-list/md5sums vastgepinde
  snapshot (20250809) is daar inmiddels uitgerold. Ook gecontroleerd en
  NIET aanwezig op `anduin.linuxfromscratch.org`, `ftp.gnu.org` en
  `invisible-island.net` — de exacte gevalideerde tarball lijkt nergens
  meer te vinden. Nieuwste beschikbare snapshot op dezelfde mirror:
  `ncurses-6.6-20260912.tgz` (een echte versiebump t.o.v. de door het boek
  gevalideerde 6.5, geen garantie dat de rest van hoofdstuk 6/7 daarmee
  identiek gedraagt).
  - Dit is dus **geen** resource-limiet (tijd/schijf) — de job faalde
    binnen enkele minuten, ruim vóór enige limiet in beeld kwam.
  - **Openstaande keuze (niet zelf doorgedrukt):** ofwel bewust overstappen
    op de nieuwste beschikbare ncurses-snapshot (6.6) met het geaccepteerde
    risico van versie-afwijking t.o.v. wat LFS 12.4 valideerde, ofwel eerst
    dieper zoeken naar een archiefkopie van de exact gepinde 6.5-build
    (bv. Debian/Arch source-pool, Wayback Machine) voordat we verder gaan.
- **Volgende stap:** deze keuze laten maken, dan `ch6-00-fetch-sources.sh`
  aanpassen en de fase-1+2-run herhalen via GitHub Actions.
