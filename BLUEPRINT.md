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
2. `02-base-system` — LFS hoofdstuk 7 (chroot binnengaan + laatste
   temporary tools), hoofdstuk 8 (het volledige basissysteem, ~80
   pakketten) en later hoofdstuk 10 (generieke kernel + GRUB-package).
   Correctie t.o.v. eerdere aanname: kernel/GRUB zitten in hoofdstuk 10,
   niet 9 — hoofdstuk 9 is "systeemconfiguratie" (bootscripts/locale/
   netwerk/udev) en hoort grotendeels bij de installer/first-boot-stap op
   de doel-pc, niet bij de generieke image-build.
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
- **Bootstrap-cache (structurele verbetering, geen eenmalige hack):** elke
  push herbouwde eerst fase 1 + hoofdstuk 6+7 (~1u aan al bewezen werk)
  vóórdat het nieuwe/gewijzigde deel (bv. hoofdstuk 8) begon — bij het
  itereren op hoofdstuk 8 kostte dat meerdere keren een volledige,
  overbodige herbouw. Opgelost met `actions/cache/restore` +
  `actions/cache/save` in `.github/workflows/build-iso.yml`, met als
  cache-key een hash van alles dat fase 1 + hoofdstuk 6+7 bepaalt
  (`docker/Dockerfile.build`, `scripts/01-toolchain/**`,
  `scripts/02-base-system/run-all.sh` + `ch6-*.sh` + `ch7-*.sh` +
  `inside-chroot/**`, `scripts/lib/**`):
  - **Hash ongewijzigd → cache-hit:** die hele bouw wordt overgeslagen, de
    workflow gaat direct door met alleen het nieuwe/gewijzigde deel
    (momenteel hoofdstuk 8). Duidelijk gelogd in de workflow-run.
  - **Hash gewijzigd (of geen cache) → cache-miss:** fase 1 + hoofdstuk 6+7
    bouwen gewoon opnieuw vanaf source, met de reden in de log — nooit
    stilzwijgend een verouderd checkpoint hergebruiken als die scripts
    zelf zijn aangepast.
  - De cache wordt als checkpoint opgeslagen precies op de fasegrens (na
    hoofdstuk 7, vóór hoofdstuk 8 het `$LFS`-volume verder aanpast) — twee
    losse `docker run`-aanroepen i.p.v. één, met de `lfs`-gebruiker
    inmiddels in `docker/Dockerfile.build` zelf gebakken (niet meer
    runtime aangemaakt) zodat beide containers 'm meteen hebben.
    `scripts/02-base-system/run-all.sh` ondersteunt dit via de env-vars
    `SKIP_BOOTSTRAP` en `SKIP_CH8`.
  - Dit patroon is bedoeld om herbruikt te worden voor elke volgende
    fasegrens, niet alleen hier — inmiddels ook toegepast tussen hoofdstuk
    8 en fase 3 ("ch8-complete"-cache, zelfde opzet, tweede cache-laag in
    `.github/workflows/build-iso.yml`) en bedoeld voor elke volgende
    sub-fasegrens binnen fase 3/4 zelf (bv. tussen 03a en 03b).

## Bronbeschikbaarheid & fallback-beleid (vaste bouw-aanpak)
LFS-mirrors — vooral dated snapshots zoals ncurses' `current/`-map — rollen
geregeld bestanden weg (ervaring van Brionize, bevestigd op 2026-09-18 toen
`ncurses-6.5-20250809.tgz` van invisible-mirror.net verdween). Dit wordt niet
telkens als losse onderbreking behandeld, maar is standaardgedrag van elke
`fetch`-stap in elke fase, via de herbruikbare functie `fetch_verified()` in
`scripts/lib/fetch-verified.sh` (gebruikt door `01-toolchain` en
`02-base-system`, en straks ook `03-blfs-desktop`/`04-devstack-apps`):

1. Probeer eerst de officiële/gepinde URL uit de LFS wget-list.
2. Bij falen: automatisch, in volgorde, **eigen back-up** (GitHub Release
   `build-deps` in deze repo — alleen voor bestanden die al eens bewezen
   onbetrouwbaar bleken via alle onderstaande bronnen, per geval
   toegevoegd aan `_FV_SELF_HOSTED` in `fetch-verified.sh`, vooraf
   handmatig gedownload/geverifieerd), GNU-mirrornetwerk
   (`ftpmirror.gnu.org`, alleen relevant voor `ftp.gnu.org`-URL's), Wayback
   Machine (via de CDX-API, niet de rate-gelimiteerde `available`-API —
   bleek in de praktijk vanuit GitHub Actions-IP-reeksen minder
   betrouwbaar dan vanuit een gewone machine, vermoedelijk rate-limiting
   van cloud-CI door Internet Archive), Software Heritage en
   snapshot.debian.org (beide laatste zijn best-effort — geen generieke
   bestandsnaam-lookup mogelijk zonder vooraf bekende hash/pakketversie, dus
   leveren in de praktijk zelden een hit, maar staan wel in de keten).
3. **Verplichte checksum-verificatie** tegen de officiële LFS md5sums, hoe dan
   ook — dit is de enige reden dat dit zonder mens/AI-tussenkomst mag: bij een
   match is het bewijsbaar exact hetzelfde bestand, ongeacht de bron.
4. Bij match: doorgaan, met een duidelijke logregel (bestand, gebruikte bron,
   bevestigde checksum) in de build-logs — geen onderbreking. Elke bron
   krijgt bovendien 3 pogingen met 10s pauze ertussen vóór de keten naar de
   volgende bron gaat (een storing kan een schokkerige, niet-blijvende
   herstelfase hebben).
5. Bij falen van alle bronnen, of als nergens een checksum matcht: **stoppen
   en escaleren** als een echt beslispunt (mogelijke versie-afwijking) — dit
   wordt nooit stilzwijgend doorgedrukt naar een andere versie.

## Vast bouwpatroon per fase (vanaf het begin toepassen, niet pas na fouten)
Hoofdstuk 8 kostte meerdere iteraties om deze lessen te leren. Fase 3
(`03-blfs-desktop`) en fase 4 (`04-devstack-apps`) beginnen er **vanaf hun
allereerste script** mee — dit is geen checklist om achteraf toe te passen
als iets al misgaat, maar het standaard vertrekpunt:

1. **Altijd `fetch_verified()`** (`scripts/lib/fetch-verified.sh`) voor elke
   download, nooit losse `wget`/`curl`-logica per pakket. Zie
   "Bronbeschikbaarheid & fallback-beleid" hierboven.
2. **Checkpoints altijd als los tar-bestand cachen, nooit de ruwe map.**
   Geleerde les uit hoofdstuk 8: `actions/cache` draait zelf altijd als de
   onbevoorrechte runner-user en kan geen root-only/restrictieve bestanden
   lezen die een fase bewust zo instelt (bv. `/root` op 0750). Patroon:
   `sudo tar --zstd -cpf checkpoint.tar.zst -C <map> .` → chown terug naar de
   runner-user → `actions/cache/save` op dat éne bestand. Terugzetten met
   `sudo tar --zstd -xpf` (behoudt eigenaarschap/rechten correct).
3. **Checkpoints ook BINNEN een zware fase, niet alleen op de fasegrens.**
   Hoofdstuk 8 (~80 pakketten) had geen tussentijds checkpoint, waardoor
   elke mislukte poging weer bij pakket 1 van die fase begon. Fase 3 (Xorg
   alléén al ~54 pakketten) en fase 4 splitsen zichzelf op in meerdere
   sub-checkpoints (bv. per logisch blok van 10-20 pakketten), niet pas
   achteraf wanneer blijkt dat één blok te groot is. Toegepast: een derde
   cache-laag (`lfs-xorg-complete-*`, naast `lfs-bootstrap-*` en
   `lfs-ch8-complete-*`) op de grens ná 03a (Xorg-basisbibliotheken +
   server), zodat een fout dieper in fase 3 (XFCE-kern, apps-laag) niet
   ook 03a opnieuw laat bouwen. Zelfde tar-bestand-i.p.v.-ruwe-map-patroon
   als de eerdere twee lagen (zie punt 2). Vervolg-sub-fasen (GTK3/glib-
   stack, XFCE-core, apps-laag) krijgen op dezelfde manier hun eigen laag
   zodra ze bestaan, niet pas achteraf.
4. **`-j4` als standaard `MAKEFLAGS`/`TESTSUITEFLAGS`** (de CI-runner heeft 4
   cores). Was tijdelijk op `-j2` gezet na een onverklaarde GCC-crash die
   destijds op een OOM-kill leek — de échte oorzaak bleek achteraf een
   vergeten `chown -R tester .` (zie punt 6), niet parallelliteit. Met die
   root cause bevestigd en gefixed, teruggezet naar `-j4` (2026-09-22,
   `scripts/02-base-system/run-all.sh` en `scripts/03-blfs-desktop/run-all.sh`)
   en in CI getest i.p.v. uit voorzorg laag te houden zonder bewijs. Blijkt
   het alsnog problemen te geven, dan is dat een nieuw, apart te
   onderzoeken feit — niet terugvallen op de oude aanname.
5. **Workflow-trigger breed, niet per submap.** `on.push.paths` triggert nu
   op `scripts/**` (i.p.v. elke submap losse te noemen) — het "een submap
   vergeten toe te voegen"-probleem (`scripts/lib/**` ontbrak eerder) kan
   zo structureel niet meer terugkomen.
6. **Let op "online" binaries bij elke stap die levende systeembestanden
   herschrijft (zoals Stripping).** Het LFS-boek weet zelf al welke
   binaries (`bash find strip`) tijdens zo'n stap "in gebruik" zijn en
   behandelt die speciaal (kopie bewerken, dan atomisch terugzetten). Onze
   EIGEN orchestratie voegt daar zelf nog een "online" proces aan toe:
   `tee`, omdat elke stap door `| tee logfile` wordt gepijpt voor logging.
   Bij een toekomstige, vergelijkbare stap (of bij fase 3/4) eerst checken
   of zo'n boek-eigen "online"-lijst bestaat en `tee` daar proactief aan
   toevoegen, i.p.v. te wachten op "Text file busy".
7. **Vergeet niet de losse `chown`/`groupadd`/`userdel`-regels rond een
   uitgeschakelde test-suite.** Het uitcommentariëren van `su tester -c
   "make check"` is niet genoeg — de voorbereidings-/opruimregels ervoor
   (`chown -R tester .`, `groupadd ... -U tester`, `groupdel dummy`,
   `userdel -r tester`) verwijzen naar een gebruiker die nooit bestaat in
   deze pipeline en falen dan zelf, ook al draait er geen test meer. Bij
   het schrijven van nieuwe pakketscripts (fase 3/4) hier direct op
   controleren, niet pas na een mislukte run.

## Security / Secrets (grondregel, niet-onderhandelbaar)
- **Nooit hardcoded secrets, accounts of persoonlijke data in de repo** —
  ook niet tijdens de publieke periode.
- `.env.example` bevat alleen placeholders; echte waarden komen uitsluitend
  via de first-boot wizard op de doel-pc, in een lokale `.env` (uitgesloten
  via `.gitignore`).
- Geen API-keys of tokens in de workflow-yml.

## Nog open / bekende risico's
- **Fase 2 (LFS hoofdstuk 6, 7 én 8 — temporary tools, chroot, het volledige
  basissysteem van ~100 pakketten) is volledig bewezen binnen GitHub
  Actions:** 1u9m29s met bootstrap-cache-hit (zie PROGRESS.md, run
  35469074012) — ruim binnen de 6-uur-limiet. Voor fase 3-4 (XFCE-desktop,
  devstack) is dit nog niet bewezen; die zijn zwaarder (Xorg alleen al
  ~40+ pakketten, XFCE-core 18, plus GTK3/glib-stack). Mitigatie
  (checkpoints/cache al VANAF de eerste fase-3-stap, niet pas achteraf —
  zie "Vast bouwpatroon per fase") staat, wordt per fase opnieuw getoetst.
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
