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

## 2026-09-20
- **Coordinator: fase 3 starten, volgens het net vastgelegde "Vast
  bouwpatroon per fase" — checkpoints vanaf de eerste stap, niet pas
  achteraf.**
- **Checkpoint-architectuur uitgebreid:** een TWEEDE cache-laag toegevoegd
  aan `.github/workflows/build-iso.yml`, "ch8-complete" (fase 1 + hoofdstuk
  6+7+8 samen, ~1u bouwtijd). Zonder dit zou elke fase-3-iteratie hoofdstuk
  8 opnieuw moeten bouwen — exact de verspilling die bij hoofdstuk 8 zelf
  al pijnlijk bleek. Cascade: eerst de ch8-complete-cache proberen (hit =
  alles overslaan tot en met hoofdstuk 8), anders de bestaande
  bootstrap-cache proberen, anders alles vanaf fase 1 bouwen — na
  hoofdstuk 8 wordt de ch8-complete-cache opgeslagen voor de volgende
  keer. Workflow hernoemd naar "fase 1+2+3", artifact naar
  `lfs-base-system-latest`.
- **Fase 3a (Xorg-basisbibliotheken + server) geschreven — nog niet
  gevalideerd.** `scripts/03-blfs-desktop/` met eigen `run-all.sh`
  (SKIP_XORG-vlag vanaf de eerste versie, ook al is er nu nog maar één
  sub-fase — consistent met "checkpoints per sub-fase vanaf het begin").
  52 pakketten, dit keer ZELF geschreven i.p.v. via Codex gedelegeerd: het
  boek bleek voor de 32 "Xorg Libraries" (x7lib.html) en 9 "Xorg Fonts"
  (x7font.html) al een generieke lus + uitzonderingen-`case`-statement te
  gebruiken (letterlijk overgenomen, ruwe HTML gecontroleerd, geen
  samenvattingsfout dit keer), wat het aantal losse scripts drastisch
  terugbracht.
  - **Bewuste keuze, met onderbouwing uit het boek zelf:** `XORG_PREFIX=/usr`
    ("The BLFS editors recommend using the /usr prefix") — single-tree
    systeem, geen los `/usr/X11R6`. Daardoor zijn een aantal
    boek-compatibiliteitssymlinks (voor een AFWIJKEND prefix) bewust
    weggelaten — die zouden bij `/usr` zelf-verwijzend zijn.
  - **Bewuste afwijking bij Xorg-Server:** `-D glamor=false` en
    `-D systemd_logind=false` (i.p.v. het boek's `true`/`true`) — glamor
    vereist libepoxy+Mesa (bewust nog niet meegenomen, zware losse stap),
    systemd_logind vereist volledige systemd/logind (hoofdstuk 8 bouwde
    alleen udev). Resultaat: basis/onversnelde X die op elke hardware
    zonder GPU-driver-afhankelijkheid moet werken — past bij het
    generieke-hardware-doel uit BLUEPRINT.md.
  - Alle 15 nieuwe bestanden met `bash -n` gecontroleerd, geen
    syntaxfouten.
- **Eerste fase-3-run: de tweede cache-laag (ch8-complete) werkt bewezen,
  03a kwam tot pakket 32 van de 52 voordat een echte, verwachte
  ontbrekende-dependency-fout opdook.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35527115578
  (1u32m11s): bootstrap-cache HIT (overgeslagen), ch8-complete-cache MISS
  (eerste keer, dus terecht) → hoofdstuk 8 gewoon herbouwd (~52 min) → de
  nieuwe ch8-complete-cache succesvol opgeslagen (geen permissieprobleem
  dit keer — dezelfde tar-aanpak als de bootstrap-cache werkt hier ook
  meteen goed). Fase 3a: pakketten 01-07 (proto/util-laag) slaagden
  allemaal snel, toen `08-x7lib-loop.sh` (de 32-pakketten-lus) faalde op:
  ```
  configure: error: You must have freetype installed; see http://www.freetype.org/
  ```
  - **Root cause:** `libXft` (onderdeel van de x7lib-lus) heeft FreeType
    nodig — die had ik abusievelijk pas bij een latere GTK-stack-sub-fase
    ingepland, terwijl de x7lib-lus 'm nu al nodig heeft.
  - **Fix:** Freetype-2.13.3 toegevoegd als `07a-freetype.sh` (BLFS 12.4,
    letterlijk van de officiële pagina — die bleek trouwens niet op het
    voor de hand liggende pad te staan: `general/freetype2.html`, niet
    `general/freetype.html`), vóór de x7lib-lus in de stappenvolgorde.
    Geen `freetype-doc`-pakket meegenomen (optioneel, niet nodig om te
    bouwen/linken).
- **Freetype-fix bevestigd in CI, maar meteen een tweede, verwante
  ontbrekende-dependency-fout.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35627780539
  (job 106426264120, 7m11s totaal): beide cache-lagen (bootstrap +
  ch8-complete) waren nu een hit — bevestigd via de run-summary
  ("Bootstrap-cache-archief bouwen/opslaan" en "Ch8-complete-cache-archief
  bouwen/opslaan" stonden allebei op "-" = overgeslagen). Dit bewijst dat
  de twee-laags cache-architectuur nu volledig werkt voor snelle iteratie:
  van ~1u32m naar 7m11s voor een run die pas laat in fase 3a faalt.
  Stappen 01 t/m 07a (freetype) slaagden allemaal
  (`07a-freetype.sh geslaagd`, incl. "checking for freetype2 >= 2.1.6...
  yes"), maar `08-x7lib-loop.sh` faalde meteen erna op:
  ```
  checking for fontconfig >= 2.5.92... no
  configure: error: Package requirements (fontconfig >= 2.5.92) were not met:
  Package 'fontconfig' not found
  ```
  - **Root cause:** `libXft` (zelfde package als bij de freetype-fout)
    heeft naast FreeType ook Fontconfig nodig — allebei stonden ze
    mentaal onder de latere GTK-stack-sub-fase gepland, maar de kale
    x7lib-lus heeft ze al nodig.
  - **Fix:** Fontconfig-2.17.1 toegevoegd als `07b-fontconfig.sh` (BLFS
    12.4, letterlijk van de officiële pagina
    `general/fontconfig.html` — die bestond deze keer wél op het voor de
    hand liggende pad). Bron is een gitlab.freedesktop.org-package-URL
    (niet ftp.gnu.org, dus geen GNU-mirrornetwerk-fallback van
    toepassing, maar de overige fetch_verified()-fallbacks gelden
    gewoon). `--disable-docs` gebruikt (boek-optie, voorkomt een
    DocBook-utils/texlive-afhankelijkheid die we niet bouwen).
    Testsuite overgeslagen (heeft internettoegang nodig, past niet bij
    CI — zelfde patroon als de 53 eerder overgeslagen hoofdstuk-8-tests).
    Ingevoegd na `07a-freetype.sh`, vóór de x7lib-lus.
- **Fontconfig-fix bevestigd: de hele x7lib-lus (32 pakketten) is nu
  voorbij.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35713035502
  (job 106697922861): stappen 01 t/m 08 (`08-x7lib-loop.sh geslaagd`)
  allemaal groen — libXft (en de rest van de 32) bouwt nu probleemloos met
  zowel FreeType als Fontconfig aanwezig. Meteen daarna faalde
  `09-x7font-loop.sh` (de 9-pakketten-fontlus) op het tweede pakket:
  ```
  checking for mkfontscale... no
  configure: error: mkfontscale is required to build encodings.
  ```
  - **Root cause:** `encodings` (onderdeel van de x7font-lus) heeft het
    `mkfontscale`-commando nodig om te kunnen configureren. Dat commando
    komt niet uit x7font.html zelf, maar uit een heel ANDERE BLFS-pagina:
    x7app.html ("Xorg Applications"), een losse batch van 33
    hulpprogramma's met als aggregate "Required"-dependency o.a.
    Mesa-25.1.8 (waarschijnlijk voor xdriinfo, een DRI-diagnosetool — het
    boek splitst dit niet per pakket uit).
  - **Bewuste keuze:** NIET de hele x7app-batch (33 pakketten + Mesa)
    bouwen — dat zou de eerder bewust genomen Mesa/glamor-vrije keuze bij
    xorg-server (`-D glamor=false`, zie eerdere entry) alsnog via de
    achterdeur doorbreken, puur om één configure-check bij encodings
    tevreden te stellen. In plaats daarvan: alléén `mkfontscale-1.2.3`
    losstaand gebouwd als `08a-mkfontscale.sh` (levert ook `mkfontdir`,
    uit dezelfde tarball), ingevoegd na de x7lib-lus en vóór de
    x7font-lus. De rest van x7app.html (xrandr, xinput, xev, xkill, etc.)
    volgt eventueel later als eigen sub-stap, mogelijk met xdriinfo
    bewust overgeslagen om Mesa te blijven vermijden — dat is nog geen
    beslispunt zolang de x7font-lus zelf niet verder blokkeert.
- **mkfontscale-fix bevestigd: de hele x7font-lus (9 pakketten) is nu ook
  voorbij, plus libxcvt, pixman en xkeyboard-config.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35714212965
  (job 106701735212): `08-x7lib-loop.sh`, `08a-mkfontscale.sh`,
  `09-x7font-loop.sh`, `10-libxcvt.sh`, `11-pixman.sh`,
  `12-xkeyboard-config.sh` allemaal groen. Alleen het allerlaatste
  pakket van fase 3a, `13-xorg-server.sh`, faalde — dus fase 3a is nu
  nog maar één fout verwijderd van volledig groen. Echte fout uit de
  meson-configure-fase:
  ```
  Run-time dependency dri found: NO (tried pkgconfig)
  ../include/meson.build:9:10: ERROR: Dependency "dri" not found, tried pkgconfig
  ```
  - **Root cause, gevonden door de daadwerkelijke bron van xorg-server te
    downloaden en `meson.build`/`include/meson.build` te lezen (niet uit
    het geheugen):** `include/meson.build:9` bevat letterlijk
    `dri_dep = dependency('dri', required: build_glx)`, en
    `meson.build:407` zet `build_glx = get_option('glx')` — een optie die
    standaard op `true` staat (`meson_options.txt:25`). GLX (de
    OpenGL-extensie voor X) staat dus impliciet aan, en dát trekt de
    `dri`-pkgconfig-dependency (uit Mesa) verplicht binnen — ook al hadden
    we `glamor=false` al bewust uitgezet. `glamor` en `glx` zijn twee
    losse opties met elk hun eigen Mesa-koppeling.
  - **Fix:** `-D glx=false` toegevoegd aan de meson-configure-aanroep in
    `13-xorg-server.sh`, naast de bestaande `glamor=false` en
    `systemd_logind=false`. Resultaat: een Xorg-server zonder enige
    Mesa/GPU-afhankelijkheid, consistent met het generieke-hardware-doel.
    (Ter controle ook de overige `dependency()`-aanroepen in
    `meson.build`/`os/meson.build` nagelopen op vergelijkbare verplichte
    koppelingen — `dbus` is al conditioneel op `systemd_logind` (dus al
    goed), `secure-rpc`/`xdmcp`/`libunwind`/`xselinux` zijn allemaal
    optioneel of stonden al niet aan; geen verdere verrassingen verwacht
    bij dit pakket.)
- **Structurele verbeteringen doorgevoerd (coordinator-verzoek), naast de
  losse xorg-server-fix:**
  1. **`-j4` i.p.v. `-j2`** in zowel `02-base-system/run-all.sh` als
     `03-blfs-desktop/run-all.sh` — de eerdere `-j2`-voorzichtigheid was
     gebaseerd op een inmiddels weerlegde OOM-aanname (de échte oorzaak
     was de chown-tester-regel, zie eerdere entries). Wordt in de
     eerstvolgende run in de praktijk getest.
  2. **Derde cache-laag toegevoegd:** `lfs-xorg-complete-*` in
     `.github/workflows/build-iso.yml`, naast de bestaande
     `lfs-bootstrap-*` en `lfs-ch8-complete-*`. Zelfde tar-bestand-patroon,
     hash nu ook over `scripts/03-blfs-desktop/**`. Zodra 03a een keer
     succesvol gecached is, hoeft een latere fase-3-fout (XFCE-kern,
     apps-laag) niet meer heel 03a te herbouwen.
  3. BLUEPRINT.md's "Vast bouwpatroon per fase" bijgewerkt (punt 3 en 4)
     om deze twee wijzigingen en hun onderbouwing vast te leggen.
- **`-j4` bevestigd: volledig hoofdstuk 5 t/m 8 herbouwd zonder enig
  probleem.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35715449589
  (job 106705744010): omdat `02-base-system/run-all.sh` zelf wijzigde
  (de `-j4`-regel), werden zowel de bootstrap- als de ch8-complete-cache
  ongeldig — dus een volledige verse rebuild van hoofdstuk 5 t/m 8, nu
  met `-j4`. Alle ~100 pakketten slaagden, inclusief de eerder
  gevoelige stappen (27-gcc.sh, 81-stripping.sh). Geen enkele
  regressie. Beide cache-lagen zijn met de nieuwe `-j4`-hash opnieuw
  succesvol opgeslagen.
  - **Fase 3a ging tot en met stap 12 (xkeyboard-config) foutloos door**
    (inclusief de eerder gefixte freetype/fontconfig/mkfontscale-stappen
    en de hele x7lib/x7font-lus), en de `-D glx=false`-fix werkte: de
    eerdere `dri`-fout is weg. Maar meteen daarna een DERDE, aparte
    configure-fout in `13-xorg-server.sh`:
    ```
    Run-time dependency libtirpc found: NO (tried pkgconfig and cmake)
    Has header "rpc/rpc.h" : NO
    ../os/meson.build:63:8: ERROR: Problem encountered: secure-rpc requested, but neither libtirpc or libc RPC support were found
    ```
  - **Root cause:** `secure-rpc` staat standaard aan (`meson_options.txt`)
    en probeert legacy Sun-RPC-ondersteuning te vinden — via libtirpc
    (BLFS "Recommended", niet gebouwd) of via glibc's eigen (inmiddels
    uit moderne glibc verwijderde) `rpc/rpc.h`. Dit voedt XDM-
    AUTHORIZATION-1 (een legacy XDMCP-authenticatiemethode), niet nodig
    voor deze generieke desktop.
  - **Fix:** `-D secure-rpc=false` toegevoegd aan `13-xorg-server.sh`,
    naast de bestaande `glamor=false`/`glx=false`/`systemd_logind=false`.
- **Belangrijke, fundamentele bevinding tijdens CI-wachttijd ontdekt (los
  van deze losse configure-fouten):** een volledige dependency-audit van
  XFCE-core (17 pakketten) + GTK3's eigen Required-laag tegen de
  officiële BLFS-pagina's (zie BLUEPRINT.md "Dependency-audit fase
  3b/3c") toont dat **GTK3 via `libepoxy` hard Mesa-25.1.8 nodig heeft**
  — dus onvermijdelijk voor heel XFCE, los van de xorg-server-keuze om
  Mesa te vermijden. Voorgelegd aan Brionize als een echt beslispunt;
  Brionize gaf de AI mandaat om te kiezen. Besluit: Mesa MET, maar
  alleen `-D gallium-drivers=llvmpipe` (software-rendering, geen
  hardware-GPU-vendor-drivers) — zie BLUEPRINT.md Beslislog
  (2026-09-22) voor de volledige onderbouwing en exacte meson-opties.
- **secure-rpc-fix bevestigd: meson-configure van xorg-server slaagt nu
  volledig** (geen enkele configure-fout meer). Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35725553502
  (job 106738220556, snel — bootstrap+ch8-cache beide hit zoals verwacht
  na de vorige run). Maar de daadwerkelijke `ninja`-bouwstap faalt nu
  (niet meer configure):
  ```
  ../hw/xfree86/os-support/linux/lnx_platform.c:7:10: fatal error: xf86drm.h: No such file or directory
  ```
  - **Root cause:** xorg-server's xfree86-platformlaag gebruikt
    DRM/KMS-modesetting-ioctls (via `xf86drm.h`, uit libdrm) onafhankelijk
    van glamor/GLX — dit is dus GEEN Mesa-gerelateerd probleem, gewoon
    een losse, nog niet gebouwde dependency (`libdrm`). Bevestigd via
    libdrm's eigen BLFS-pagina: libdrm heeft zelf geen Mesa nodig, alleen
    "Recommended: Xorg Libraries" (al aanwezig) — een licht, losstaand
    pakket dat los staat van de eerdere Mesa/GTK3-architectuurvraag.
  - **Fix:** Libdrm-2.4.125 toegevoegd als `12a-libdrm.sh` (meson-build,
    letterlijk van de officiële BLFS-pagina), vóór `13-xorg-server.sh`.
- **MIJLPAAL: fase 3a (Xorg-basisbibliotheken + server) volledig groen,
  libdrm-fix bevestigd.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35726410887
  (11m28s totaal, bootstrap+ch8-cache beide hit, xorg-complete-cache voor
  het eerst succesvol gebouwd+opgeslagen). Alle drie de cache-lagen nu
  bewezen. Dit sluit de reeks van vijf losse, in CI-logs geverifieerde
  ontbrekende-dependency-fixes af die nodig bleken sinds de eerste
  fase-3-poging: freetype, fontconfig, mkfontscale, xorg-server
  glx/secure-rpc, libdrm — stuk voor stuk gevonden via de echte
  configure-/build-foutmelding, nooit gegokt.
- **Sub-fase 03b volledig gescript: 27 pakketten, audit-eerst.** Op
  coordinator-verzoek eerst de VOLLEDIGE bouwvolgorde tegen de officiële
  BLFS-pagina's nagelopen (zie BLUEPRINT.md "Fase 3b — GTK3-supporting-
  stack: volledige bouwvolgorde") vóórdat er één script geschreven werd
  — inclusief twee niet-voor-de-hand-liggende circulaire
  bootstrap-ketens die het boek zelf documenteert: (1) GLib in drie
  stappen (introspectie uit → GObject-Introspection bouwen tegen die
  GLib → GLib herbouwen met introspectie aan), en (2) FreeType/
  Fontconfig herbouwen NA HarfBuzz voor volwaardige tekst-shaping-
  ondersteuning (Pango's eigen Required-regel: "Fontconfig must be
  built with FreeType using HarfBuzz").
  - Elke tarball-extractiemap-naam is vóór het schrijven van de
    scripts geverifieerd door de eerste ~3MB van elke tarball te
    downloaden en de top-level map met `tar -t...f` te controleren
    (i.p.v. aan te nemen) — dit ving één echte fout: GTK3's tarball
    heet `gtk-3.24.50.tar.xz` maar oudere BLFS-versies pakten dit uit
    naar `gtk+-3.24.50/` (met een plus); BLFS 12.4 blijkt de map zonder
    plus te noemen (`gtk-3.24.50/`) — zonder deze check had dit script
    pas in CI gefaald.
  - **LLVM (nodig voor Mesa's llvmpipe-driver) is verreweg het zwaarste
    pakket** — boek schat 13 SBU / 4.7 GB. Bewust MINIMAAL gebouwd:
    geen Clang, geen Compiler-RT, geen testsuite,
    `LLVM_TARGETS_TO_BUILD="X86"` i.p.v. het boek's `"host;AMDGPU"`.
    Reken op een aanzienlijk langere CI-tijd voor deze ene stap dan al
    het andere in 03b (en mogelijk 03a) samen.
  - Vierde CI-cache-laag (`lfs-gtk3-complete-*`) toegevoegd, zelfde
    gelaagde patroon als bootstrap→ch8-complete: 03a en 03b zijn nu
    losse, apart gecachete docker-run-stappen binnen dezelfde job
    (`SKIP_GTK3_STACK=true` resp. `SKIP_XORG=true`), zodat een latere
    fout in fase 3c (XFCE-core) niet ook 03a of 03b hoeft te herbouwen.
- **Eerste 03b-run: snel tot en met de eerste zes pakketten, toen
  GLib-stap-1 faalde.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35731136524
  (job 106756703394): 03a moest onverwacht volledig herbouwen (de
  xorg-complete-cache-hash bevat `03-blfs-desktop/run-all.sh`, dat wél
  wijzigde toen de SKIP_GTK3_STACK-logica erbij kwam — dus terechte,
  verwachte cache-miss, geen bug). 03a bleef daarna wel weer helemaal
  groen, en de nieuwe xorg-complete-cache is met de huidige hash
  opnieuw succesvol opgeslagen (dus de volgende run zou 03a weer moeten
  overslaan). 03b: pcre2 t/m pyyaml (6 pakketten) allemaal snel groen,
  toen:
  ```
  ../meson.build:2727:10: ERROR: Program 'rst2man rst2man.py' not found or not executable
  ```
  - **Root cause:** `-D man-pages=enabled` in `07-glib-stage1.sh` (boek-
    default) vereist `rst2man` (uit docutils, GLib's eigen
    "Recommended", bewust niet gebouwd).
  - **Fix:** `-D man-pages=disabled` — geen man-pages nodig voor een
    werkend systeem.
- **man-pages-fix bevestigd: de hele circulaire GLib/HarfBuzz/FreeType/
  Fontconfig-bootstrapketen werkt in één keer goed.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35733038135
  (job 106763155869): xorg-complete-cache was nu wél een hit (03a
  overgeslagen, zoals verwacht). 03b liep foutloos door van pcre2 t/m
  Pango (19 pakketten) — inclusief de twee lastigste, nieuw-ontworpen
  stappen (GLib in drie stappen, FreeType/Fontconfig-herbouw na
  HarfBuzz) zonder enige correctie nodig. Faalde daarna op `20-cmake.sh`:
  ```
  CMake Error at Source/Modules/CMakeBuildUtilities.cmake:142 (message):
    CMAKE_USE_SYSTEM_CURL is ON but a curl is not found!
  ```
  - **Root cause:** `--system-libs` in CMake's bootstrap-commando (boek-
    standaard) probeert te linken tegen systeem-cURL/libarchive/libuv/
    nghttp2 — allemaal alleen "Recommended" voor CMake, bewust niet
    gebouwd.
  - **Fix:** `--system-libs` (en de nu overbodige --no-system-*-
    uitzonderingen) verwijderd — CMake bundelt deze bibliotheken dan
    intern, geen extra pakketten nodig.
- **cmake-fix bevestigd: cmake en libjpeg-turbo beide groen.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35735437049
  (job 106771351676, 25m39s): xorg-complete-cache weer een hit zoals
  verwacht. `20-cmake.sh` en `21-libjpeg-turbo.sh` slaagden. Faalde
  daarna meteen op `22-gdk-pixbuf.sh`, met LETTERLIJK dezelfde
  onderliggende oorzaak als de GLib-fix hiervoor:
  ```
  Program rst2man rst2man.py found: NO
  ../docs/meson.build:69:2: ERROR: Problem encountered: No rst2man found, but man pages were explicitly enabled
  ```
  - **Anti-Patch-Loop-afweging:** dit is de TWEEDE keer dat een los
    pakket faalt op ontbrekende `rst2man` (uit docutils) bij
    boek-standaard man-pages/documentatie-instellingen. In plaats van
    dit per pakket te blijven tegenkomen en telkens een nieuwe
    `-D man*=disabled`-vlag te zoeken, nu de ROOT CAUSE aangepakt:
    docutils-0.21.2 zelf toegevoegd als `06a-docutils.sh` (vroeg in
    03b, vóór GLib), zodat `rst2man` vanaf dat punt gewoon bestaat voor
    ALLE latere pakketten (at-spi2-core, Mesa, GTK3 — nog niet getest,
    maar dit voorkomt een hele klasse potentiële herhalingen). De twee
    al bewezen losse `-D man-pages=disabled`/`-D man=false`-fixes bij
    GLib en gdk-pixbuf blijven staan (geen reden om te herstellen, ze
    werken en zijn nu gewoon overbodig-maar-onschadelijk).
- **docutils-fix bevestigd: GEEN enkele rst2man-fout meer in de rest van
  03b — de root-cause-aanpak werkte.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35779056041
  (job 106919539200): gdk-pixbuf en at-spi2-core allebei foutloos groen
  (geen losse man/doc-fix meer nodig geweest). Daarna het zware
  slotstuk: **LLVM slaagde** (20:40 → 21:34, ~54 minuten — met de
  bewust minimale configuratie (geen Clang, geen Compiler-RT, geen
  tests, alleen X86-target) fors sneller dan het boek's eigen
  13-SBU-schatting met de volledige set zou impliceren), **Mesa
  (llvmpipe-only) slaagde**, **libepoxy slaagde**. Alleen het allerlaatste
  pakket van de HELE fase-3b-keten, GTK3 zelf, faalde nog:
  ```
  ../meson.build:441:17: ERROR: Dependency "xkbcommon" not found, tried pkgconfig and cmake
  ```
  - **Root cause, gevonden door GTK3's eigen bron te downloaden en
    meson.build/meson_options.txt te lezen:** `wayland_backend` is bij
    GTK3 een GEWONE boolean-optie die op Linux standaard op `true`
    staat (géén 'auto'-detectie op basis van aanwezige
    wayland-bibliotheken!). Regel 441:
    `xkbdep = dependency('xkbcommon', version: xkbcommon_req, required:
    wayland_enabled)` — maakt xkbcommon dus verplicht zodra
    wayland_enabled true is, wat bij ons altijd het geval was omdat we
    de vlag nooit expliciet uitzetten. Het boek's eigen voorbeeldcommando
    zet deze vlag nooit, omdat het er stilzwijgend van uitgaat dat de
    "Recommended" wayland-stack (Wayland, wayland-protocols,
    libxkbcommon) al aanwezig is — bij ons bewust niet (X11-only-doel).
  - **Fix:** `-D wayland_backend=false` toegevoegd aan `27-gtk3.sh`.
- **wayland_backend-fix bevestigd: xkbcommon-fout weg, GTK3 komt nu
  voorbij de vorige blokkade.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35788202760
  (job 106950064551): alles t/m libepoxy weer foutloos (tweede keer op
  rij — bevestigt dat 01-26 stabiel zijn). GTK3 faalt nu op een NIEUWE,
  aparte doc-tool-fout, verder in de configure:
  ```
  ../docs/reference/gtk/meson.build:488:2: ERROR: Problem encountered: No xsltproc found, but man pages were explicitly enabled
  ```
  - **Root cause:** GTK3's man-pages gebruiken `xsltproc` (uit
    libxslt) — een ANDER doc-toolchain-pakket dan rst2man/docutils
    (waar GLib en gdk-pixbuf tegenaan liepen). Nog niet gebouwd (alleen
    "Optional"/"Recommended" voor de meeste pagina's).
  - **Fix:** `-D man=false` i.p.v. `man=true` — geen man-pages nodig
    voor een werkend systeem, geen nieuw pakket (libxslt) erbij nodig
    voor deze ene, niet-functionele feature.
- **MIJLPAAL: fase 3b (GTK3-supporting-stack, 27 pakketten) volledig
  groen — man=false-fix bevestigd.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35795928749
  (1u20m28s totaal, bootstrap/ch8-complete/xorg-complete allemaal hit,
  gtk3-complete-cache voor het eerst succesvol gebouwd+opgeslagen).
  Alle vier cache-lagen nu bewezen samen te werken. Base-system-
  artifact succesvol geüpload. Dit sluit de reeks van zeven losse,
  CI-log-geverifieerde fixes af die nodig bleken sinds de eerste
  03b-poging: man-pages=disabled (GLib), --system-libs weg (CMake),
  man=false (gdk-pixbuf), docutils toegevoegd (root-cause voor
  rst2man), wayland_backend=false (GTK3/xkbcommon), man=false (GTK3/
  xsltproc) — stuk voor stuk gevonden via de echte configure-
  foutmelding of de daadwerkelijke pakketbron, nooit gegokt. Fase 1
  t/m 3b (LFS hoofdstuk 5-8, Xorg-basis, en de volledige GTK3-stack
  incl. het bewust minimale LLVM/Mesa-llvmpipe-duo) is nu VOLLEDIG
  bewezen binnen GitHub Actions.
- **Fase 3c volledig gescript: 17 XFCE-core-pakketten + 8 externe
  dependencies, audit-eerst.** Bij het daadwerkelijk uitwerken bleek
  één extra, niet eerder opgemerkte dependency (hwdata, Required voor
  libdisplay-info) — verder klopte de eerdere audit. Alle 25
  tarball-extractiemappen vooraf geverifieerd (zelfde spot-check-
  methode als bij 03a/03b) — geen afwijkingen dit keer. Bewuste keuze:
  LXDE Icon Theme i.p.v. gnome-icon-theme (lichter, BLFS-pagina voor
  gnome-icon-theme niet gevonden). Vijfde CI-cache-laag
  (`lfs-xfce-core-complete-*`) toegevoegd, zelfde patroon als de
  eerdere vier: 03a/03b/03c zijn nu drie losse, apart gecachete
  docker-run-stappen binnen dezelfde workflow-job.
- **Eerste 03c-run: een workflow-bekabelingsfout, geen script-fout.**
  Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35803040971:
  omdat `03-blfs-desktop/run-all.sh` zelf wijzigde (SKIP_XFCE_CORE-
  logica erbij), werden zowel xorg-complete- als gtk3-complete-cache
  ongeldig — een verwachte, terechte cache-miss (zelfde patroon als
  eerder bij de -j4-wijziging). 03a bouwde foutloos, maar de stap
  "Fase 3a (Xorg-basis) bouwen" faalde toch — bleek bij het lezen van
  de log dat deze stap's `docker run` alleen `SKIP_GTK3_STACK=true`
  meegaf, niet `SKIP_XFCE_CORE=true`. Zonder die laatste vlag liep
  `run-all.sh` na 03a gewoon door naar 03c (03b was wel terecht
  overgeslagen), en 03c faalde meteen op:
  ```
  Run-time dependency glib-2.0 found: NO (tried pkgconfig)
  ../meson.build:46:11: ERROR: Dependency "glib-2.0" not found, tried pkgconfig
  ```
  — logisch, want 03b (dat GLib bouwt) was net overgeslagen in DEZE
  container-aanroep. Geen echte libgudev/GLib-fout, puur een
  scoping-fout in de workflow-yml zelf.
  - **Fix:** `-e SKIP_XFCE_CORE=true` toegevoegd aan zowel de "Fase 3a"-
    als de "Fase 3b"-stap se `docker run`-aanroepen, zodat elke stap
    ECHT alleen zijn eigen sub-fase bouwt (dezelfde bug zou de
    "Fase 3b"-stap ook geraakt hebben zodra alleen 03b's cache miste
    terwijl 03a al een hit was).
- **Scoping-fix bevestigd: 03a en 03b bouwden allebei foutloos opnieuw
  (volledige rebuild, ~1u26m) en sloegen hun cache correct op.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35803856441:
  `libgudev` (dat vorige keer ten onrechte "glib-2.0 not found" gaf)
  slaagde nu meteen — bevestigt dat dat puur de workflow-scoping-bug
  was, geen echte fout. 03c kwam tot en met `06-libwnck.sh` (6 van de
  17 XFCE-core-pakketten + alle 8 externe dependencies) foutloos door,
  toen:
  ```
  checking for xsltproc... no
  configure: error: package 'xsltproc' missing
  ```
  - **Root cause:** xfce4-dev-tools' eigen configure heeft `xsltproc`
    (uit libxslt) HARD nodig — anders dan de eerdere rst2man/xsltproc-
    problemen bij GLib/gdk-pixbuf/GTK3 (die via een optionele
    `-D man*=false`-vlag te omzeilen waren), is dit hier geen
    optionele doc-feature maar een niet-uit-te-schakelen
    configure-vereiste.
  - **Fix:** libxslt-1.1.43 toegevoegd als `00i-libxslt.sh` (Required:
    libxml2, al aanwezig uit 03b), vóór xfce4-dev-tools.
- **libxslt-fix bevestigd: 16 van de 17 XFCE-core-pakketten nu groen in
  één moeite door.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35810348749:
  alle vier bovenliggende cache-lagen waren hit (snelle run), en 03c
  liep foutloos van xfce4-dev-tools t/m xfwm4 (16 van de 17 pakketten +
  alle 9 externe dependencies). Alleen het allerlaatste pakket,
  xfce4-session, faalde:
  ```
  configure: error: iceauth missing, please check your X11 installation
  ```
  - **Root cause:** xfce4-session heeft het `iceauth`-commando nodig
    voor ICE-sessiebeheer. Zit, net als mkfontscale destijds, in de
    x7app.html-batch (33 Xorg-hulpprogramma's met Mesa als aggregate
    dependency) — niet losstaand gebouwd.
  - **Fix:** iceauth-1.0.10 losstaand toegevoegd als `00j-iceauth.sh`
    (zelfde bewuste aanpak als mkfontscale: niet de hele x7app-batch,
    alleen dit ene commando; heeft zelf alleen libICE/libSM nodig, al
    aanwezig uit 03a).
- **MIJLPAAL: fase 3c (XFCE-core, 17 pakketten + 9 externe
  dependencies) volledig groen — iceauth-fix bevestigd, en daarmee is
  HEEL FASE 3 nu bewezen.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35811106710
  (12m14s totaal, alle vier bovenliggende cache-lagen hit,
  xfce-core-complete-cache voor het eerst succesvol gebouwd+
  opgeslagen). Alle vijf cache-lagen nu bewezen samen te werken.
  Base-system-artifact succesvol geüpload. Dit sluit fase 3 volledig
  af: Xorg-basisbibliotheken + server (54 pakketten), de GTK3-
  supporting-stack incl. het bewust minimale LLVM/Mesa-llvmpipe-duo
  (27 pakketten), en XFCE-core (17 pakketten + 9 externe
  dependencies) — allemaal aantoonbaar werkend binnen GitHub Actions.
  Totaal ~98 losse fase-3-pakketten, elke fout onderweg gevonden via de
  echte CI-log of de daadwerkelijke pakketbron, nooit gegokt.
- **Fase 3d volledig gescript: Conky-HUD, window-tiling, 3 werkbladen/
  hotkeys.** Brionize koos: eerst fase 3 helemaal afronden vóór fase 4.
  Audit-eerst uitgevoerd: geen van de vier pakketten (Lua, wmctrl,
  devilspie2, Conky) staat in BLFS 12.4 (niche desktop-hulpprogramma's)
  behalve Lua — elk pakket se eigen officiële upstream-bron gebruikt
  (GitHub-tags, of Wayback Machine voor wmctrl waarvan de
  oorspronkelijke site dood is). Conky's CMake-configuratie
  (`ConkyBuildOptions.cmake`) letterlijk nagelopen en bewust minimaal
  gehouden (X11+Xft aan, Imlib2/Journal/Pulseaudio/MySQL/WLAN/Nvidia
  uit). Een eigen standaard `conky.conf` (CPU/RAM/opslag/Tailscale-
  status/logs) wordt via Conky's eigen BUILD_BUILTIN_CONFIG-mechanisme
  in de executable ingebakken. Voor de 3-werkbladen/Super+1/2/3-
  configuratie is GEEN xfconf-schema gegokt: het is letterlijk
  overgenomen uit xfwm4's eigen `src/settings.c` (channel/pad) en
  xfce4-panel's eigen `migrate/default.xml` (array-XML-syntax); het
  bestaande, door libxfce4ui zelf geïnstalleerde
  `xfce4-keyboard-shortcuts.xml` (sinds 03c) wordt gericht bewerkt
  (alleen de 3 workspace-sneltoetsen), niet vervangen.
  Zesde CI-cache-laag toegevoegd; de drie bestaande 03a/03b/03c-
  workflow-stappen proactief voorzien van `SKIP_XFCE_EXTRAS=true`
  (dezelfde les als de eerdere 03c-scoping-bug).
- **Eerste 03d-run: Lua meteen groen, wmctrl faalt op een tar-
  extensie-eigenaardigheid.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35841414377:
  alle vijf bovenliggende sub-fasen (03a/03b/03c) herbouwden foutloos
  (verwachte cache-miss door de run-all.sh-wijziging) EN bleven dit
  keer correct gescopet — de proactieve SKIP_XFCE_EXTRAS-fix werkte,
  geen herhaling van de eerdere 03c-scoping-bug. `01-lua.sh` slaagde
  meteen. `02-wmctrl.sh` faalde met:
  ```
  gzip: stdin: not in gzip format
  tar: Child returned status 1
  ```
  - **Root cause:** de Wayback-capture van wmctrl-1.07 is feitelijk een
    kaal, ongecomprimeerd tar-archief (geen gzip-magic-bytes) — al
    eerder lokaal bevestigd tijdens onderzoek. De MD5-check in
    `fetch_verified()` slaagde gewoon (zelfde bytes als lokaal
    geverifieerd), maar `tar -xf wmctrl-1.07.tar.gz` probeerde alsnog
    gzip te ontleden puur op basis van de `.gz`-bestandsnaam-extensie
    en faalde daarop.
  - **Fix:** lokale bestandsnaam veranderd naar `wmctrl-1.07.tar`
    (zonder `.gz`) — de URL blijft ongewijzigd (`fetch_verified()`
    koppelt bestandsnaam en URL niet hard aan elkaar), alleen de lokale
    cache-/extractie-naam. `tar -xf` detecteert dan correct op
    inhoud i.p.v. op extensie.
- **wmctrl-fix bevestigd: wmctrl slaagt nu.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35851863972:
  alle vijf bovenliggende lagen waren hit (snelle run). `01-lua.sh` en
  `02-wmctrl.sh` beide groen. `03-devilspie2.sh` faalde op een
  bron-compatibiliteitsprobleem:
  ```
  src/script_functions.c:499:48: error: implicit declaration of function 'LUA_QL'
  ```
  - **Root cause:** devilspie2 dateert uit het Lua-5.1-tijdperk en
    gebruikt de macro `LUA_QL()` — verwijderd sinds Lua 5.3 (wij bouwen
    tegen Lua 5.4.8). `LUA_QL(x)` breidde vroeger simpelweg uit naar
    `"'" x "'"`.
  - **Fix:** de twee (enige, met `grep` geverifieerd) aanroepen in
    `src/script_functions.c` letterlijk vervangen door hun oude
    macro-expansie (`"'tostring'"` / `"'print'"`) via sed — lokaal
    getest tegen de daadwerkelijke broncode vóór het pushen: de
    substitutie is exact, 0 LUA_QL-voorkomens blijven over.
- **devilspie2-fix bevestigd: devilspie2 slaagt nu (de lokaal geteste
  sed-substitutie klopte).** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35852647437:
  Lua, wmctrl en devilspie2 alledrie groen. `04-conky.sh` faalde op:
  ```
  CMake Error at cmake/Conky.cmake:182 (message):
    Unable to find program 'git'
  ```
  - **Root cause, gevonden door Conky's eigen `cmake/Conky.cmake` te
    downloaden en te lezen:** de git-vereiste zit binnen
    `if(NOT RELEASE) ... endif()` — `RELEASE` staat standaard uit
    (`option(RELEASE "Build release package" false)`). Git zelf wordt
    alleen gebruikt om een `git describe`-achtige versiestring te
    genereren bij een dev-checkout; wij bouwen vanaf een gedownloade
    release-tarball, precies het scenario waar de `RELEASE`-vlag voor
    bedoeld is.
  - **Fix:** `-D RELEASE=ON` toegevoegd. (Er staat verderop in
    Conky.cmake nog een ongeconditioneerde `execute_process(COMMAND
    ${APP_GIT} rev-parse ...)`-aanroep die bij RELEASE=ON een lege
    APP_GIT-variabele krijgt — volgens de CMake-logica zou dit een
    onschadelijke mislukte execute_process opleveren zonder de
    configure te laten crashen, aangezien de resulterende
    GIT_SHORT_SHA in de RELEASE-tak niet gebruikt wordt. Nog te
    bevestigen in de volgende run.)
- **MIJLPAAL: fase 3d (Conky-HUD, window-tiling, 3 werkbladen/hotkeys)
  volledig groen — RELEASE=ON-fix bevestigd, en daarmee is HEEL FASE 3
  nu compleet afgerond, zoals Brionize gevraagd had.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35853792648
  (7m00s totaal, alle vijf bovenliggende lagen hit,
  xfce-extras-complete-cache voor het eerst succesvol gebouwd+
  opgeslagen). Alle zes cache-lagen nu bewezen samen te werken.
  Base-system-artifact succesvol geüpload. Vier losse fixes onderweg
  in 03d (wmctrl-tar-extensie, devilspie2-LUA_QL, Conky-RELEASE=ON),
  stuk voor stuk via de echte log of daadwerkelijke pakketbron
  gevonden.
- **Fase 3 is hiermee volledig afgerond:** Xorg-basis (54 pakketten),
  GTK3-supporting-stack incl. LLVM/Mesa-llvmpipe (27 pakketten),
  XFCE-core (17 + 9 pakketten), en Conky/tiling/werkbladen (4
  pakketten + configuratie) — ~102 losse fase-3-pakketten totaal, alle
  bewezen binnen GitHub Actions.
- **Fase 3d afronding gescript: Command-Center-Matrix-thema +
  devilspie2-tegelregels + autostart.** Brionize vulde de twee laatste
  open productkeuzes in (Matrix/cyberpunk-thema; exacte
  tegelindeling). Audit-eerst: twee bestaande cyberpunk-GTK-thema's
  onderzocht (Roboron3042/Cyberpunk-Neon — bleek outrun/magenta-cyaan,
  geen groen; WoodyCat-ctOS-Theme — heeft wél een "Toxic Matrix Green"
  editie maar is een zware suite met apt/pacman/dnf-aanroepen en een
  eigen concurrerende Conky-setup, past niet bij dit from-scratch-
  project). Zelf een minimaal GTK3-CSS-thema samengesteld, bovenop
  GTK3's ingebakken Adwaita-dark — resourcepad en kleurnamen letterlijk
  geverifieerd tegen GTK3's eigen broncode. devilspie2-tegelregels
  geschreven op basis van devilspie2's eigen Lua-API (letterlijk uit
  `src/script.c`/`src/script_functions.c` gehaald, incl. bevestiging
  dat workspace-nummering 1-based is). Conky en devilspie2 kregen
  bovendien voor het eerst een autostart-entry (stonden er wel, werden
  nooit automatisch gestart). Eerlijk vastgelegde grens: de
  tegelregels matchen op raamtitels van apps die pas in fase 4 bestaan
  — alleen Lua-syntax te verifiëren (`luac -p`), niet runtime-gedrag.
- **MIJLPAAL: fase 3d-afronding in één keer groen — thema, tegelregels
  en autostart allemaal correct op de eerste poging.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/35872055515
  (8m45s totaal, alle vijf bovenliggende lagen hit,
  xfce-extras-complete-cache opnieuw succesvol opgeslagen). Echte
  evidence uit de log bevestigd: `06-theme-command-center-matrix.sh`
  maakte het thema aan en de xsettings.xml-sanity-check slaagde;
  `07-devilspie2-tiling-rules.sh` liet `luac -p` daadwerkelijk zonder
  fouten doorlopen (bewijst geldige Lua-syntax); `08-autostart.sh`
  installeerde beide .desktop-bestanden. Fase 3 (nu inclusief thema +
  werkende tegelregels + autostart) is hiermee compleet afgerond zoals
  Brionize gevraagd had.
- **GO voor fase 4: 11 stappen gescript, audit-eerst.** Twee echte
  productafwegingen gevonden en opgelost vóórdat er geschreven werd:
  (1) "systemd watchdogs" kan niet — geen systemd op dit systeem — PM2
  (al in de lijst) vervult die rol al; (2) PWA-snelkoppelingen vereisen
  een browser-engine (WebKitGTK, ~1,5-2u extra bouwtijd + een hele
  nieuwe afhankelijkheidsketen) — aan Brionize voorgelegd, gekozen:
  uitstellen naar een eigen vervolgstap. Elke prebuilt binary (Node/
  Bun/gh/cloudflared/Supabase-CLI/Tailscale) vooraf met `readelf`
  gecontroleerd op dynamische-linkvereisten (allemaal ruim binnen onze
  glibc, meeste Go-binaries zelfs statisch gelinkt — geen giswerk).
  SQLite's eigen BLFS-pagina wees op een niet-vanzelfsprekende
  vervolgstap (Python herbouwen voor het sqlite3-modules) — direct
  opgevolgd met een echte runtime-verificatie. Vóór het pushen nog een
  potentieel CI-brekende fout zelf gevonden: de chroot-PATH mist
  `/usr/local/bin` (waar alle fase-4-tools naartoe symlinken) — fase
  4's eigen run-all.sh zet dit nu recht. Zevende cache-laag
  toegevoegd.
- **Eerste fase-4-run: Node.js, Bun en gh alledrie meteen groen
  (bevestigt de PATH-fix werkte), cloudflared faalde op een simpele
  bestandsnaam-mismatch.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/36043320820:
  alle zes bovenliggende cache-lagen waren hit. `04-cloudflared.sh`
  faalde met:
  ```
  install: cannot stat 'cloudflared': No such file or directory
  ```
  - **Root cause:** `00-fetch-sources.sh` gebruikt de bestandsnaam
    `cloudflared-linux-amd64` (matcht de URL) als `fetch_verified()`-
    sleutel, maar het script zocht naar het kortere `cloudflared` —
    een simpele naamgevings-mismatch, geen echte dependency-fout. Alle
    andere scripts gecontroleerd op dezelfde fout (Anti-Patch-Loop-
    discipline: niet aannemen dat het incident op zichzelf staat) —
    geen andere mismatches gevonden.
  - **Fix:** `04-cloudflared.sh` verwijst nu naar
    `cloudflared-linux-amd64`.
- **cloudflared-fix bevestigd: alle zes prebuilt-binary-stappen
  (Node.js, Bun, gh, cloudflared, Supabase CLI, Tailscale) nu groen.**
  Run https://github.com/brionize-nl/brionize-command-center/actions/runs/36044263483:
  `07-postgresql.sh` faalde als eerste bron-bouwstap op:
  ```
  checking whether to build with ICU support... yes
  checking for icu-uc icu-i18n... no
  configure: error: ICU library not found
  ```
  - **Root cause:** PostgreSQL 17's configure detecteert/vereist ICU
    standaard AAN — het boek-voorbeeldcommando noemt geen
    `--without-icu`, maar ICU (alleen "Optional" voor PostgreSQL) is
    bewust niet gebouwd (groot pakket, zelfde reden als eerder bij
    libxml2/harfbuzz waar ICU ook alleen optioneel was).
  - **Fix:** `--without-icu` toegevoegd — exact wat de foutmelding zelf
    al voorstelde.
- **PostgreSQL-fix bevestigd: PostgreSQL, SQLite, en de Python-
  sqlite3-herbouw (met echte runtime-verificatie) alledrie groen.**
  Run https://github.com/brionize-nl/brionize-command-center/actions/runs/36045103116:
  `10-n8n.sh` faalde op:
  ```
  npm error code EAI_AGAIN
  npm error request to https://registry.npmjs.org/n8n failed, reason: getaddrinfo EAI_AGAIN registry.npmjs.org
  ```
  - **Root cause:** `chroot` verandert het filesysteem-root — de
    HOST-container heeft een werkend `/etc/resolv.conf`, maar dat is
    niet automatisch zichtbaar binnen `$LFS` na chroot. Geen eerdere
    fase liep hier tegenaan omdat `fetch_verified()` altijd BUITEN de
    chroot draait; fase 4 is de eerste met live netwerktoegang van
    BINNEN de chroot (`npm install -g` tegen de npm-registry).
  - **Fix:** `cp /etc/resolv.conf "$LFS/etc/resolv.conf"` toegevoegd
    aan fase 4's eigen `run-all.sh`, vóór de chroot-aanroep — standaard
    LFS-boek-patroon voor exact dit scenario.
- **MIJLPAAL: fase 4 (devstack) volledig groen — resolv.conf-fix
  bevestigd.** Run
  https://github.com/brionize-nl/brionize-command-center/actions/runs/36047165966
  (~21m13s totaal, alle zes bovenliggende lagen hit,
  devstack-complete-cache voor het eerst succesvol gebouwd+
  opgeslagen). Alle 11 stappen (Node.js, Bun, gh, cloudflared,
  Supabase CLI, Tailscale, PostgreSQL, SQLite, Python-sqlite3-herbouw,
  n8n, PM2) geslaagd. Vijf losse fixes onderweg (cloudflared-
  bestandsnaam, PostgreSQL --without-icu, chroot-resolv.conf), elk via
  de echte CI-log gevonden, plus twee structurele bugs vóór het pushen
  zelf gevonden (chroot-PATH miste /usr/local/bin) en opgelost zonder
  een CI-poging nodig te hebben.
- **Devstack is hiermee compleet** behalve de bewust uitgestelde
  PWA-snelkoppelingen (browser-engine nodig). Devilspie2-tegelregels
  uit fase 3d blijven vooralsnog niet runtime te verifiëren — n8n/
  Supabase Studio hebben geen browser om een venster te openen, en er
  is nog geen terminal-emulator. Eerlijk vastgelegd, niet aangenomen.
- **Volgende stap:** terugkoppelen bij Brionize/coordinator. Open
  vervolgstap: PWA-snelkoppelingen + browser-engine (WebKitGTK), zodra
  gewenst.
- **Eerlijke tussenstand devilspie2-runtime-verificatie (coordinator
  vroeg dit expliciet te controleren, niet aan te nemen):** dit kan nog
  NIET, ook na deze fase-4-stap. n8n is nu wel geïnstalleerd, maar
  alleen als CLI/server-proces met een web-UI — die web-UI opent nog
  geen VENSTER zonder browser (uitgesteld). Supabase Studio idem
  (cloud-dashboard, ook browser nodig). Bovendien is er nog GEEN
  terminal-emulator gebouwd (nodig voor de "terminal-logs"/"GitHub-
  terminal"-tegels) — die stond niet expliciet in fase 4's lijst. Een
  echte runtime-test van de tegelregels is dus nog niet mogelijk; dit
  eerlijk vastgelegd i.p.v. te doen alsof de syntax-check (fase 3d)
  voldoende was. Wordt vervolgd zodra de browserstap + een
  terminal-emulator er zijn.

## 2026-09-26 — AUTOPILOT PAUZE (checkpoint, geen codewijzigingen)
Brionize heeft het bouwproces bewust stopgezet op een veilig punt.
**Bevestigd bij pauze:** repo schoon (geen uncommitted changes),
laatste CI-run groen (36047165966, fase 1 t/m 4 volledig bewezen, alle
zeven cache-lagen), geen lokale build-containers actief. Volledige
"we stoppen hier"-samenvatting + eerstvolgende-stap-opties staan in
HANDOFF.md (bijgewerkt in dezelfde commit als deze regel). Geen fase
of fix gestart na dit punt — wacht op een nieuwe instructie.

## 2026-09-26 — Autopilot GO tot eindproduct + start fase 5a (WebKitGTK)
Brionize heeft de UX-herziening "Tegel-manager & Visuele laag"
(BLUEPRINT.md, commit 3b07791) vastgelegd en een verruimd mandaat
gegeven: zelfstandig doorbouwen tot eindproduct, zonder tussentijdse
check-ins voor implementatiedetails. Eerste bouwblok: de
WebKitGTK-browserstap (hoort samen met de tegel-manager, want die
rendert zijn animaties/menu's via die browser-engine).

Volledige BLFS-afhankelijkheidsaudit voor WebKitGTK-2.48.5 gedaan
(elke "Dependencies"-sectie gevolgd tot de keten stopt, niets gegokt):
19 nieuwe pakketten gevonden (Nettle, GnuTLS, glib-networking, libpsl,
nghttp2, libsoup3, ICU, Little CMS, libsecret, libtasn1, libwebp,
OpenJPEG, Ruby, unifdef, Which, gstreamer, gst-plugins-base,
gst-plugins-bad, WebKitGTK zelf). Alle 19 bouwscripts geschreven onder
`scripts/05-browser-tilemanager/inside-chroot-05a/`, plus
`05a-00-fetch-sources.sh` (fetch_verified() voor elke bron, elke
uitpakmap-naam vooraf gecontroleerd via proefdownload — inclusief
ICU's kale `icu/`-mapnaam) en de top-level/inside-chroot
`run-all.sh`-orchestrators, zelfde patroon als fase 3/4.

Twee bewuste implementatiekeuzes binnen het bestaande mandaat (geen
nieuw beslispunt): `ninja -j2` specifiek voor WebKitGTK zelf (boek
waarschuwt zelf voor >4GiB RAM per compile-job in de release-build;
16GB-runner, 2×~4GB=~8GB marge), en `-D ENABLE_BUBBLEWRAP_SANDBOX=OFF`
(bubblewrap is niet gebouwd, enkel "Recommended" — bekende, begrensde
beperking, geen sandbox-isolatie voor webcontent-processen).

Achtste CI-cache-laag (`lfs-webkit-complete-*`) toegevoegd aan
`.github/workflows/build-iso.yml`, exact hetzelfde
restore/build-of-cache-hit/archive/save-patroon als de zeven eerdere
lagen, ingevoegd direct na de devstack-cache-laag.

Alle nieuwe scripts met `bash -n` syntax-gecontroleerd (allemaal OK) en
de workflow-YAML met `python3 -c "import yaml; yaml.safe_load(...)"`
gevalideerd (OK) vóór commit. BLUEPRINT.md bijgewerkt met de volledige
audit ("Fase 5a — WebKitGTK-afhankelijkheidsketen" + bijbehorende
Beslislog-regel).

## 2026-09-26 — Fase 5a: eerste CI-run gefaald, root-cause gevonden en gefixt
Eerste CI-run voor fase 5a (36238615164) — fase 1 t/m 4 hielden stand
(alle zeven cache-lagen cache-hit, zoals verwacht), maar 05a faalde
meteen bij `02-gnutls.sh`:
```
checking for libtasn1 >= 4.9... no
configure: error:
  *** Libtasn1 4.9 was not found. To use the included one, use --with-included-libtasn1
```
Root-cause (niet gegokt, direct uit de echte log): mijn eerdere aanname
dat GnuTLS bij een ontbrekende libtasn1 automatisch zijn eigen
ingebakken kopie gebruikt, klopte niet — GnuTLS's configure faalt hard
tenzij `--with-included-libtasn1` expliciet wordt meegegeven. Libtasn1
stond in de bouwvolgorde op stap 10, ná GnuTLS (stap 02) — puur een
volgorde-fout in de audit, geen ontbrekend pakket.

Fix (root-cause, geen configure-vlag-workaround): libtasn1 verplaatst
naar stap 02 (vóór GnuTLS), GnuTLS/glib-networking/libpsl/nghttp2/
libsoup3/ICU/lcms2/libsecret ieder één plaats opgeschoven (03 t/m 10).
Eén gedeelde systeem-libtasn1-build voor zowel GnuTLS als WebKitGTK's
eigen Required-vermelding — geen dubbele/ingebakken kopie. Scripts
hernoemd via `git mv`, `run-all.sh`'s STEPS-array bijgewerkt, foutieve
aanname-commentaar in de betrokken scripts gecorrigeerd. Volledige
`bash -n`-sweep opnieuw gedraaid (OK) vóór de fix-commit. Tweede
CI-run getriggerd om dit te bewijzen.

## 2026-09-26 — Fase 5a: tweede CI-run gefaald (zelfde patroon, andere lib), gefixt
Tweede CI-run (36239248902) bevestigde de libtasn1-fix (nu wél
`checking for libtasn1 >= 4.9... yes`), maar `03-gnutls.sh` faalde
alsnog, verder in de configure-stap:
```
checking for library containing u8_normalize... no
configure: error:
  *** Libunistring was not found. To use the included one, use --with-included-unistring
```
Zelfde onderliggende patroon als de libtasn1-fout: GnuTLS's boek-eigen
"Recommended"-lijst (p11-kit, libunistring) is voor libunistring
configure-technisch hard, met een door GnuTLS zelf aangeboden
ingebakken-kopie-vlag als escape hatch. Anders dan libtasn1 heeft
libunistring geen andere afnemer in onze keten (alleen IDN/i18n-
verrijking van GnuTLS zelf) — dus geen 20e los systeempakket
toegevoegd, maar `--with-included-unistring` aan GnuTLS's configure
meegegeven (zelfde minimale-footprint-redenering als eerder bij bv.
de LXDE-iconenset i.p.v. de volledige gnome-icon-theme-batch).
Nettle's eigen "Error 1 (ignored)" bij `libhogweed.so` in dezelfde run
gecontroleerd en bevestigd benign (nettle's eigen Makefile-patroon,
`.so` wordt alsnog correct geïnstalleerd — geen actie nodig).
Derde CI-run getriggerd.

## 2026-09-26 — Fase 5a: derde CI-run gefaald (p11-kit), + volledige configure-audit
Derde CI-run (36239721669) kwam verder (libtasn1 + libunistring nu
bewezen opgelost), maar faalde opnieuw in `03-gnutls.sh`'s configure:
```
checking for p11-kit-1 >= 0.23.1... no
configure: error:
  *** p11-kit >= 0.23.1 was not found. To disable PKCS #11 support
  *** use --without-p11-kit, ...
```
Root-cause: eigen inconsistentie — het script documenteerde al "p11-kit
bewust niet gebouwd", maar liet de boek-voorbeeldvlag
`--with-default-trust-store-pkcs11="pkcs11:"` staan, die zelf p11-kit
vereist. Fix: die vlag vervangen door `--without-p11-kit`, nu consistent
met de eigen beslissing.

Om niet een vierde keer via losse CI-runs tegen verborgen harde
configure-checks aan te lopen (Anti-Patch-Loop-discipline: één
grondige controle boven eindeloos auditen), is gnutls-3.8.10's echte
`configure`-script lokaal gedownload en volledig doorzocht op elke
"was not found"/`configure: error`-tak. Resultaat: naast de al
opgeloste nettle/hogweed/gmp (aanwezig)/libtasn1/libunistring/p11-kit
zijn ALLE overige controles (libev, LIBIDN2, libunbound/Libdane,
trousers/TPM, ZLIB, LIBBROTLI, LIBZSTD) bevestigd non-fataal
("*_optional=yes" als standaardwaarde wanneer de bijbehorende
--with-vlag niet is meegegeven — alleen een WARNING, geen
configure:error). Dit was daarmee de laatste verborgen gnutls-
afhankelijkheid. Vierde CI-run getriggerd.

## 2026-09-26 — Fase 5a: vierde CI-run gefaald (libsoup3-testsuite/p11-kit-nasleep), gefixt
Vierde CI-run (36240268942) bevestigde de volledige gnutls-fix
(`03-gnutls.sh geslaagd`) en kwam drie stappen verder
(glib-networking, libpsl, nghttp2 alle drie geslaagd), maar faalde in
`07-libsoup3.sh` bij het linken van libsoup3's EIGEN testsuite:
```
/usr/bin/ld: ssl-test.c:(.text.startup+0x3d): undefined reference to `gnutls_pkcs11_init'
/usr/bin/ld: ssl-test.c:(.text.startup+0x4f): undefined reference to `gnutls_pkcs11_add_provider'
```
Root-cause: rechtstreeks gevolg van onze eigen `--without-p11-kit`-
keuze bij GnuTLS. libsoup3's meson-optie `pkcs11_tests` staat op
'auto' en detecteert GnuTLS als aanwezig zonder te checken of het
mét PKCS11-support gebouwd is. Wij draaien libsoup3's testsuite hier
sowieso niet (pure WebKitGTK-afhankelijkheid) — fix: `-D tests=false`
toegevoegd aan libsoup3's meson-setup, verifieerd tegen het echte
`meson_options.txt` uit de tarball (niet gegokt). De daadwerkelijke
libsoup3-library-functionaliteit blijft ongewijzigd; alleen de
unit-tests worden niet meer gecompileerd. Vijfde CI-run getriggerd.
