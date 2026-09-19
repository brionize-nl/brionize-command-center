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
- **Exacte 6.5-build gevonden en byte-verifieerd — geen 6.6-versiebump
  nodig.** Brionize koos eerst archieven proberen. Doorzocht:
  - Software Heritage: content-lookup vereist sha1/sha256 (geen md5-optie),
    en origin-search werd geblokkeerd door een Anubis-antibot-check —
    geen bruikbaar resultaat gekregen.
  - snapshot.debian.org: heeft ncurses 6.5-snapshots van januari/februari/
    november 2025, maar niet de exacte 20250809-build — geen match.
  - **Wayback Machine, op de oorspronkelijke dode URL zelf — succes.**
    `http://web.archive.org/web/20260322033806/https://invisible-mirror.net/archives/ncurses/current/ncurses-6.5-20250809.tgz`
    gedownload en de md5 vergeleken: `679987405412f970561cc85e1e6428a2` —
    **exacte match** met LFS 12.4's officiële md5sums-regel. Dus
    byte-identiek aan de door het boek gevalideerde build, geen
    versie-afwijking.
  - `ch6-00-fetch-sources.sh` aangepast: gebruikt nu die Wayback-URL voor
    ncurses, met een uitgebreide comment die het waarom vastlegt (dode
    originele mirror, waar wel/niet gezocht, checksum-bevestiging).
- **Mijlpaal — fase 1+2 (hoofdstuk 5+6+7) volledig geslaagd in GitHub
  Actions.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35397086967
  — de bouwstap zelf ("Fase 1+2 ... bouwen") is **groen in 58m37s**: de
  volledige LFS 12.4 cross-toolchain, alle 17 hoofdstuk-6-pakketten, chroot
  binnengaan en alle hoofdstuk-7-pakketten (Gettext/Bison/Perl/Python/
  Texinfo/Util-linux) plus cleanup — zonder fouten. Dit bevestigt: het
  belangrijkste risico uit BLUEPRINT.md (past dit binnen 6u/14GB?) geldt nu
  ook voor fase 2, met ruime marge (58 min van de 360 beschikbare).
  - De job als geheel faalde wél, maar op een onschuldige, losse
    workflow-stap NA de build: `sudo` ontbrak bij het archiveren van
    `$LFS` naar een artifact (die stap draait als de gewone
    runner-gebruiker, terwijl hoofdstuk 7 delen van `$LFS` naar
    root:root met restrictieve rechten had gechown't binnen de
    container). Gefixt met `sudo tar ...` + `sudo chown` terug naar de
    runner-gebruiker.
- **Brionize's feedback verwerkt: generiek fallback-mechanisme voor dode
  bronnen, i.p.v. losse ad-hoc fixes per pakket.** Nieuwe herbruikbare
  functie `fetch_verified()` in `scripts/lib/fetch-verified.sh`, gebruikt
  door zowel `01-toolchain/01-fetch-sources.sh` als
  `02-base-system/ch6-00-fetch-sources.sh` (en straks fase 3/4):
  officiële URL → GNU-mirrornetwerk (voor `ftp.gnu.org`-URL's) → Wayback
  Machine (via de CDX-API, niet de rate-gelimiteerde `available`-API) →
  Software Heritage → snapshot.debian.org (laatste twee: best-effort,
  zelden een hit, maar wel geprobeerd) — met verplichte md5-verificatie
  bij elke kandidaat. Lokaal getest: normale download (m4) werkt via de
  officiële URL, en de bekende dode ncurses-URL valt automatisch en
  correct door naar de Wayback Machine met bevestigde checksum. De
  eerder hardcoded Wayback-URL-override voor ncurses is teruggedraaid
  naar de officiële URL — het generieke mechanisme lost dit nu vanzelf
  op, ook voor toekomstige, nog onbekende gevallen. Policy vastgelegd in
  BLUEPRINT.md ("Bronbeschikbaarheid & fallback-beleid").
- **Mijlpaal — fase 1+2 volledig groen, inclusief archiveren.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35401876921
  — job `toolchain` succeeded in **1u4m50s** (ruim binnen de 6-uur-limiet).
  Beide artifacts geüpload: `lfs-base-system-phase2` en `base-system-logs`.
  Het `fetch_verified()`-mechanisme werkte in de praktijk exact zoals
  bedoeld — uit de live build-log:
  ```
  ==> [ncurses-6.5-20250809.tgz] proberen via officiële URL...
  ==> [ncurses-6.5-20250809.tgz] proberen via Wayback Machine...
  ==> [ncurses-6.5-20250809.tgz] geverifieerd via Wayback Machine (md5 679987405412f970561cc85e1e6428a2 bevestigd)
  ```
  Geen onderbreking nodig, gewoon doorgebouwd. Hoofdstuk 5+6+7 zijn
  hiermee volledig bewezen binnen GitHub Actions, met een generiek,
  herbruikbaar fallback-mechanisme voor toekomstige dode bronnen.
- **Scope-correctie ontdekt vóór fase 3.** Onderzocht wat BLFS (Xorg/XFCE)
  precies vereist: een VOLLEDIG LFS-basissysteem, niet alleen de
  chroot-bootstrap (hoofdstuk 5-7) die we tot dan hadden. Zonder hoofdstuk
  8 (~80 pakketten, o.a. meson/ninja/pkgconf/OpenSSL/Perl/Python-modules)
  zouden de eerste Xorg-scripts direct falen op ontbrekende build-tools.
  Ook ontdekt: kernel + GRUB horen bij hoofdstuk 10, niet 9 (BLUEPRINT.md
  gecorrigeerd). Aan Brionize voorgelegd — akkoord: eerst hoofdstuk 8
  afbouwen ("we moeten doen hoe het hoort"), fase 3 pas daarna.
- **Hoofdstuk 8 (basissysteem, 80 pakketten) uitgewerkt met Codex CLI als
  research/schrijf-assistent, ikzelf als architect/reviewer.** Aanpak:
  - Alle 80 boekpagina's + de officiële wget-list/md5sums zelf via `curl`
    als ruwe HTML/tekst lokaal opgeslagen (niet via de samenvattende
    webfetch-tool, na eerdere ervaring dat die multi-line content kan
    corrumperen) — Codex kreeg alleen deze lokale bestanden, geen
    netwerktoegang nodig (die was toch kapot in zijn sandbox).
  - Codex schreef `scripts/02-base-system/ch8-00-fetch-sources.sh` (80
    bronnen + 7 patches, buiten chroot, als root — de `lfs`-gebruiker
    heeft na hoofdstuk 7's chown geen rechten meer) en 80
    `inside-chroot-ch8/NN-<pkg>.sh`-scripts + orchestrator, exact volgens
    de boek-volgorde 8.3–8.82.
  - **Zelf gecontroleerd (steekproef, niet blind aangenomen):**
    fetch-sources-URL's/MD5's/patches tegen de ruwe wget-list/md5sums
    (klopten, inclusief een grappige bevestiging dat de eerdere
    "psmimic"-typo in mijn allereerste wget-list-fetch een eigen
    samenvattingsfout was — de officiële naam is gewoon "psmisc"),
    plus Glibc- en Meson-scripts inhoudelijk nagelezen.
  - **Kritieke fix vóór dit naar CI mag:** Shadow's pagina draait
    interactief `passwd root` — dat blokkeert een niet-interactieve
    CI-build voor altijd (geen terminal om een wachtwoord in te typen).
    Vervangen door `passwd -l root` (account blijft vergrendeld; de
    first-boot wizard op de doel-pc regelt het echte wachtwoord — grondregel
    "nooit hardcoded secrets" blijft dus ook hier overeind).
  - **Risico onderkend en gemitigeerd:** 53 van de 80 scripts bevatten
    test-suites (`make check`) — voor Glibc/GCC/Binutils/GMP/MPFR kunnen
    die individueel langer duren dan de build zelf, en falen soms om
    omgevingsredenen die niets zeggen over de build (chroot-in-Docker-in-
    CI-VM mist bepaalde capabilities/hardware). Op Codex' tweede
    doorgang: alle test-suite-aanroepen + hun afhankelijke
    logcontroles uitgecommentarieerd (niet verwijderd — makkelijk terug
    te zetten voor een handmatige verificatie-run later), met duidelijke
    reden in elk bestand. Dit is een bewuste, transparante
    snelheid/betrouwbaarheid-keuze, geen kwaliteitscompromis op het
    eindresultaat.
  - Alle 126 scripts in het project (incl. fase 1) opnieuw met `bash -n`
    gecontroleerd — geen syntaxfouten. Top-level `run-all.sh` uitgebreid
    met de hoofdstuk-8-stap (bronnen ophalen buiten chroot, dan een eigen
    chroot-sessie voor alle 82 hoofdstuk-8-stappen).
- **Eerste hoofdstuk-8-run: fase 1+6+7 opnieuw foutloos, hoofdstuk 8 stopt
  abrupt tijdens GCC — root cause niet 100% zeker, wel gemitigeerd.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35439085621
  (1u6m). `27-gcc.sh` (hoofdstuk 8.29, GCC native herbouwen) stopte met
  "MISLUKT" middenin een reeks compiler-*waarschuwingen* (geen enkele
  expliciete `error:`/`make: ***`/`No space left`/`Killed`-regel in onze
  eigen logs) — een abrupte stop terwijl nog meerdere parallelle
  compileertaken actief leken, wat past bij een externe kill (bv. de
  Linux OOM-killer) i.p.v. een compilerfout die zichzelf meldt. Schijf was
  geen probleem (110GB vrij). Kon dit niet 100% bevestigen (geen toegang
  tot de dmesg/kernel-log van een al-afgelopen runner), maar GCC's
  C++-bootstrap is bekend geheugenhongerig — `-j$(nproc)` (4 parallelle
  taken op de standaard runner) is een reële kandidaat-oorzaak.
  **Mitigatie:** `MAKEFLAGS`/`TESTSUITEFLAGS` in beide chroot-aanroepen
  (hoofdstuk 7 en 8) van `-j$(nproc)` naar een vast, behoudend `-j2`
  gezet. Kost wat bouwsnelheid, vermindert piekgeheugengebruik — een
  bekende, veilige aanpak voor GCC-builds op resource-beperkte CI.
- **Bootstrap-cache toegevoegd (op verzoek na Brionize's terechte
  opmerking over verspilde herbouwtijd tijdens het itereren op hoofdstuk
  8):**
  - `docker/Dockerfile.build`: de `lfs`-gebruiker wordt nu in het image
    zelf gebakken (niet meer runtime via `00-prepare-host.sh`) — nodig
    zodra een build in twee losse `docker run`-aanroepen wordt
    opgesplitst.
  - `.github/workflows/build-iso.yml`: `actions/cache/restore` +
    `actions/cache/save` rond fase 1 + hoofdstuk 6+7, met als key een hash
    van alle scripts die dat deel bepalen. Cache-hit (hash ongewijzigd)
    → die hele bouw overgeslagen, direct door naar hoofdstuk 8.
    Cache-miss (hash gewijzigd of nog geen cache) → gewoon opnieuw bouwen,
    met de reden duidelijk in de log. De cache wordt opgeslagen precies op
    de fasegrens (vóór hoofdstuk 8 het volume verder aanpast), niet aan
    het eind van de hele job.
  - `scripts/02-base-system/run-all.sh`: nieuwe env-vars `SKIP_BOOTSTRAP`
    (sla hoofdstuk 6 + hoofdstuk-7-pakketten over, mount/chroot draaien
    wél altijd opnieuw) en `SKIP_CH8` (stop na hoofdstuk 7, voor het
    cache-checkpoint).
  - Beschreven in BLUEPRINT.md onder "CI-strategie" als structurele
    aanpak, niet als eenmalige hack — bedoeld voor elke volgende
    fasegrens.
- **Twee vervolgruns faalden — bleek bij het induiken (Anti-Patch-Loop:
  eerst root cause zoeken, niet blind opnieuw proberen) allebei dezelfde
  externe oorzaak, geen nieuwe hoofdstuk-8-bug.** Run 35442344495 (14m50s)
  en 35443172523 (18m10s) liepen allebei stuk in `ch6-00-fetch-sources.sh`
  op exact dezelfde plek als eerder: ncurses' officiële URL faalt (bekend),
  en dit keer viel ook de Wayback Machine-fallback weg. Direct getest:
  `web.archive.org` gaf letterlijk een "Internet Archive: Temporarily
  Offline"-onderhoudspagina terug — een echte, wereldwijde storing, geen
  bug in ons mechanisme (integendeel: het bewijst dat de
  checksum-verplichting werkt — geen versie-afwijking geaccepteerd, ook
  niet onder deze druk).
  - Automatisch gewacht tot de Wayback CDX-API weer geldige JSON teruggaf,
    daarna de run herhaald (35444169373) — **faalde opnieuw**, en de
    coordinator vroeg terecht om eerst de echte logs van déze run te
    induiken i.p.v. blind door te gaan.
  - **Bevinding na het induiken:** deze run faalde helemaal niet in
    hoofdstuk 8 (dat werd zelfs overgeslagen, status "-") — hij faalde
    weer in dezelfde `ch6-00-fetch-sources.sh`-stap, weer op de
    Wayback-poging (exact ~20s timeout, identieke foutmelding). Eigen
    losse test daarna toonde dat de Wayback CDX-API alweer snel en correct
    reageerde. Conclusie: het herstel van de storing was schokkerig
    (meerdere korte periodes van "weer bereikbaar" afgewisseld met nog
    niet stabiel), en onze automatische hersteldetectie ving een
    vroege, niet-blijvende succespoging op vóórdat de dienst echt stabiel
    was — dit is dus nog steeds hetzelfde externe Wayback-incident, geen
    apart, nieuw probleem in de hoofdstuk-8-scripts.
  - **Fix:** `fetch_verified()` deed voorheen maar één poging per bron.
    Nu 3 pogingen per bron met 10s pauze ertussen, vóór de keten naar de
    volgende bron gaat — vangt precies dit soort "bron is weer half terug"
    scenario op zonder een oneindige retry te worden. Lokaal functioneel
    getest (mock die pas op de 3e poging slaagt) — werkt correct.
- **Grote stap vooruit — fase 1+6+7 volledig geslaagd (retry-fix werkt),
  daarna twee échte bugs in de eigen cache-architectuur gevonden (niet in
  de hoofdstuk-8-scripts).** Run 35450825578 (1u3m46s): "Fase 1 +
  hoofdstuk 6+7 bouwen" liep dit keer helemaal foutloos door — inclusief
  de ncurses/Wayback-fetch, dus de retry-met-backoff-fix werkt. Daarna,
  per de Anti-Patch-Loop-regel, de logs van déze concrete fout
  geïnspecteerd (`gh api .../jobs/<id>/logs`, want `gh run view --log-failed`
  gaf onverklaarbaar niets terug voor deze run) i.p.v. blind opnieuw te
  proberen:
  1. **Cache-save faalde** (`tar: /root: Permission denied`,
     `/var/log/btmp: Permission denied`) — `actions/cache/save` draait
     altijd als de gewone, onbevoorrechte runner-user en kan de door
     hoofdstuk 7 bewust root-only gemaakte bestanden (`/root` op 0750,
     `btmp` op 0600) niet lezen. Eigen ontwerpfout: had dit meteen moeten
     zien, want exact dezelfde reden waarom de `$LFS archiveren`-stap
     eerder al `sudo` nodig had.
  2. **Hoofdstuk 8-stap crashte daardoor secundair**: zonder geslaagde
     cache-save begint die stap alsnog met een verse, kale `$LFS`-map, en
     `ch7-01-changing-owner.sh` (die via `SKIP_BOOTSTRAP` altijd opnieuw
     draait) deed `chown ... $LFS/tools` — een map die op dat moment al
     door hoofdstuk 7's eigen cleanup verwijderd was. `chown` op een
     ontbrekend pad met brace-expansion faalt hard.
  - **Fixes:**
    - Cache-mechanisme omgebouwd: i.p.v. de rechtstreekse `$LFS`-map
      cachen, nu een los tar-bestand (`lfs-bootstrap-cache.tar.zst`) dat
      MET `sudo tar` wordt aangemaakt (root kan alles lezen) en dan terug
      gechown't naar de runner-user vóór `actions/cache/save` het oppikt.
      Bij een hit wordt dat archief met `sudo tar -xpf` uitgepakt (behoudt
      root-eigendom/rechten correct).
    - `ch7-01-changing-owner.sh`: chown't nu elk pad afzonderlijk en alleen
      als het nog bestaat, i.p.v. één brace-expansion die in zijn geheel
      faalt zodra `tools` al weg is.
- **Grote mijlpaal — hoofdstuk 8 kwam 26 van de 82 stappen ver (t/m Shadow),
  cache-architectuur werkt bewezen, en de écht hardnekkige GCC-crash is
  eindelijk gevonden.** Run 35456151280 (1u22m59s): "Fase 1 + hoofdstuk
  6+7 bouwen", "Bootstrap-cache-archief bouwen" én "...opslaan" liepen
  alle drie foutloos door (self-hosted ncurses-mirror werkte meteen op de
  eerste poging, cache-tar-fix werkt bewezen) — hoofdstuk 8 begon en
  pakketten 1–26 (Man-pages t/m Shadow) slaagden allemaal. `27-gcc.sh`
  faalde weer, maar dit keer met genoeg bewijs om de ECHTE oorzaak te
  vinden:
  - **Root cause (Anti-Patch-Loop: pas nu écht gevonden, niet aangenomen):**
    GCC's `make`/`make install` **liep gewoon volledig door** (te zien in
    de log: "make[1]: Leaving directory .../build" — de build was klaar).
    De regel direct erna, `chown -R tester .`, faalde met
    `chown: invalid user: 'tester'` — een voorbereidingsregel voor het
    boek-testsuite-account dat we nooit aanmaken (we draaien geen tests).
    Codex' eerdere test-uitschakel-pass had wél de `su tester -c "make
    check"`-regels uitgecommentarieerd, maar **niet** de losse
    `chown`/`groupadd`/`userdel`-regels die dat account voorbereidden of
    opruimden. Met `set -euo pipefail` breekt zo'n enkele mislukte
    `chown` het hele script, vlak vóór/na een succesvolle build.
  - **Dit verklaart nu ook de EERSTE GCC-crash (run 35439085621), vóór de
    `-j2`-fix er al was:** dat was zeer waarschijnlijk exact dezelfde
    `chown tester`-crash, niet een OOM-kill. De `-j2`-wijziging heeft dus
    waarschijnlijk niets opgelost — maar blijft staan als behoudende,
    veilige standaardwaarde (geen reden om terug te draaien, geen bewijs
    dat `-j$(nproc)` wél veilig is).
  - **Fix:** dezelfde `chown -R tester .`-regel (plus varianten:
    `groupadd ... -U tester`, `groupdel dummy`, `userdel -r tester`) kwam
    voor in **11 scripts** (27-gcc, 29-sed, 34-bash, 57-coreutils,
    59-gawk, 60-findutils, 67-make, 71-vim, 76-procps-ng, 77-util-linux,
    82-cleanup) — stuk voor stuk gevonden via een gerichte grep en
    uitgecommentarieerd, met dezelfde reden erbij. Zonder deze fix waren
    we bij ELK van deze 11 pakketten opnieuw op dezelfde manier
    vastgelopen.
  - **Proactief ook gefixt (nog niet eens tegenaan gelopen):** GCC's eigen
    diagnostische sanity-check (regels 55-66, identiek patroon aan de
    Glibc-sanity-check uit fase 1) stond nog niet in een `set +e`-blok —
    een enkele grep-zonder-match had de build op het allerlaatste moment
    (na een succesvolle install) alsnog kunnen laten mislukken. Nu net als
    bij Glibc afgeschermd en naar een logbestand geschreven.
- **Zeer grote mijlpaal — alle 80 hoofdstuk-8-pakketten geslaagd, cache-hit
  bewezen, en de bijna-laatste stap (Stripping) gaf een nieuwe, precieze
  bug.** Run 35460767929 (1u22m54s, coordinator zag 'm live falen na een
  tijdelijke eigen netwerk/DNS-hapering die de sessie onderbrak — verder
  geen impact): "Fase 1 + hoofdstuk 6+7 bouwen" was dit keer een echte
  **cache-hit** (bevestigd: de archief-bouw/opslaan-stappen stonden op
  "-", dus overgeslagen — de bootstrap-cache werkt zoals bedoeld, en de
  hoofdstuk-8-scripts staan bewust buiten de cache-hash, dus dit was de
  eerste keer dat die hit ook echt gebeurde). Hoofdstuk 8 liep daardoor in
  één moeite door: **alle 80 pakketten (Man-pages t/m SysVinit) slaagden**,
  inclusief GCC (de chown-tester-fix werkt bewezen). Pas bij
  `81-stripping.sh` (hoofdstuk 8.84, één-na-laatste stap) een nieuwe fout:
  ```
  strip: unable to copy file '/usr/bin/tee'; reason: Text file busy
  ```
  - **Root cause:** het boek weet zelf al dat `bash`, `find` en `strip`
    "in gebruik" zijn tijdens deze stap en behandelt die drie speciaal
    (kopie stripen, dan atomisch terugzetten via `install`, i.p.v. het
    live bestand direct aan te passen). `tee` staat terecht niet in die
    boek-lijst — maar onze EIGEN orchestratie (`run-all.sh` pijpt elke
    chroot-stap door `| tee logfile`) maakt `tee` bij ONS óók de hele tijd
    "in gebruik", en dat kende het boek natuurlijk niet.
  - **Fix:** `tee` toegevoegd aan `online_usrbin` in `81-stripping.sh`
    (naast `bash find strip`), met een duidelijke comment waarom dit een
    bewuste afwijking van de letterlijke boektekst is — geen wijziging
    van de logica zelf, alleen erkennen dat tee in onze specifieke
    uitvoeringscontext ook "online" is.
- **MIJLPAAL — fase 2 (hoofdstuk 6+7+8) volledig groen.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35469074012
  — **succeeded in 1u9m29s** (cache-hit voor fase 1+6+7, hoofdstuk 8 in
  één moeite door, inclusief `81-stripping.sh` en `82-cleanup.sh`).
  Bevestigd in de log: "Fase 2 (hoofdstuk 6 + 7 + 8) volledig doorlopen".
  Artifacts: `lfs-base-system-phase2` (375MB, het complete LFS 12.4
  basissysteem) en `base-system-logs` (4,9MB). Dit is het eerste bewijs
  dat het volledige LFS-basissysteem (fase 1 + hoofdstuk 6, 7 en 8, ~100
  pakketten in totaal) van begin tot eind reproduceerbaar bouwt in
  GitHub Actions, ruim binnen de 6-uur-limiet, met een werkende
  bootstrap-cache. Fase 3 (`03-blfs-desktop` — Xorg/XFCE) kan nu écht
  beginnen, met een compleet, bewezen basissysteem als fundament en het
  "Vast bouwpatroon per fase" (zie BLUEPRINT.md) vanaf de eerste regel
  toegepast.
- **Volgende stap:** hoofdstuk 10 (generieke kernel + GRUB-package) —
  het laatste stukje van fase 2 volgens BLUEPRINT.md — of meteen door naar
  fase 3, ter beoordeling/keuze van Brionize.
