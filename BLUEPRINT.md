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

## Dependency-audit fase 3b/3c — XFCE-core + GTK3-stack (2026-09-22)
Uitgevoerd op coordinator-verzoek: niet langer één ontbrekende dependency
per CI-run ontdekken (zoals bij freetype/fontconfig/mkfontscale in 03a),
maar eerst de volledige resterende pakketlijst tegen de officiële BLFS
12.4 Required/Recommended-tabellen naleggen. Bronnen: alle 17 individuele
XFCE-core-paginas (`xfce/*.html`, letterlijk gedownload en geparsed, niet
uit het geheugen) plus de directe GTK3-supporting-stack-paginas.

**XFCE-core (17 pakketten, exacte volgorde volgt uit de onderlinge
Required-afhankelijkheden hieronder):**
libxfce4util-4.20.1 → xfconf-4.20.0 → libxfce4ui-4.20.2 → exo-4.20.0 →
garcon-4.20.0 → libwnck-43.2 → xfce4-dev-tools-4.20.0 →
libxfce4windowing-4.20.4 → xfce4-panel-4.20.5 → thunar-4.20.4 →
thunar-volman-4.20.0 → tumbler-4.20.0 → xfce4-appfinder-4.20.0 →
xfce4-settings-4.20.2 → xfdesktop-4.20.1 → xfwm4-4.20.0 →
xfce4-session-4.20.3. Alle onderlinge Required-koppelingen (bv.
libxfce4ui vereist Xfconf, Exo vereist libxfce4ui, xfce4-panel vereist
Exo+Garcon+libwnck+libxfce4windowing) al opgezocht en consistent met
deze volgorde.

**Externe (niet-Xfce) Required/Recommended-pakketten die XFCE-core als
geheel nodig heeft, nog niet gebouwd:** GTK-3.24.50, Cairo-1.18.4 (voor
xfce4-panel), libdisplay-info-0.3.0 (voor libxfce4windowing),
hicolor-icon-theme-0.18 (runtime, thunar), startup-notification-0.12
(aanbevolen bij libxfce4ui/libwnck/xfwm4/xfdesktop), pcre2-10.45
(aanbevolen, thunar), libgudev-238 (vereist door thunar-volman),
libnotify-0.8.6 (aanbevolen, meerdere), gnome-icon-theme-3.12.0 of
lxde-icon-theme-0.5.1 (vereist runtime, xfce4-settings),
libxklavier-5.4 (aanbevolen, xfce4-settings), desktop-file-utils-0.28 en
shared-mime-info-2.4 (aanbevolen, xfce4-session).

**GTK3's eigen Required-laag (opgezocht via de officiële GTK3-pagina):**
at-spi2-core-2.56.4, gdk-pixbuf-2.42.12, libepoxy-1.5.10, Pango-1.56.4,
en (effectief ook verplicht voor ons, ondanks de boek-tekst
"Recommended (Required if building GNOME)") GLib-2.84.4 met GObject
Introspection — XFCE-core zelf vereist GLib al rechtstreeks
(libxfce4util, xfce4-dev-tools, tumbler).

### KRITIEKE BEVINDING — echt beslispunt, teruggelegd bij Brionize
**`libepoxy-1.5.10` (een Required-dependency van GTK3 zelf, dus van
elke GTK3-toepassing incl. heel XFCE) heeft op zijn beurt Mesa-25.1.8
als Required-dependency** — letterlijk van libepoxy's eigen officiële
BLFS-pagina, geen uitzondering of build-flag om dit te omzeilen
gevonden op de GTK3- of libepoxy-pagina zelf.

Dit raakt de eerder BEWUST genomen keuze bij xorg-server
(`-D glamor=false -D glx=false`, zie eerdere PROGRESS.md-entries) —
die keuze werkte om Mesa buiten de kale Xorg-server te houden, maar
zodra XFCE (elke GTK3-toepassing) in beeld komt, is Mesa via libepoxy
onvermijdelijk, ongeacht wat we bij xorg-server zelf instellen. De
oorspronkelijke onderbouwing ("generieke hardware, geen
GPU-driver-afhankelijkheid") staat dus op losse schroeven voor de
GTK3/XFCE-laag — dit is precies het soort fundamentele
architectuurbeslissing die volgens de Matrix (Autopilot Decision
Boundary) niet zelfstandig door de AI genomen wordt, ook niet onder
Autopilot. Aan Brionize voorgelegd via een aparte vraag in dezelfde
beurt als deze BLUEPRINT-update.

### Fase 3b — GTK3-supporting-stack: volledige bouwvolgorde (audit, 2026-09-22)
Alle 27 pakketten hieronder zijn tegen hun eigen officiële BLFS 12.4-
pagina nagelopen (URL/MD5/Required-lijst letterlijk opgezocht, niet uit
het geheugen) vóórdat er één script geschreven werd — zelfde discipline
als bij 03a hierboven. Volgorde is bepalend en volgt uit de onderlinge
Required-koppelingen, inclusief een paar niet-voor-de-hand-liggende
CIRCULAIRE afhankelijkheden die het boek zelf expliciet benoemt:

1. **pcre2-10.45** — los, door GLib "Recommended" aangeraden (anders
   downloadt GLib 'm zelf tijdens de build — niet gewenst, alle
   downloads via `fetch_verified()`).
2. **libpng-1.6.50** — los, nodig voor Cairo + gdk-pixbuf.
3. **libyaml (yaml-0.2.5)** — los, nodig voor de PyYAML-Python-module.
4. **Mako-1.3.10** (Python-module, `pip3 wheel`+`pip3 install`-patroon
   uit BLFS' algemene "Python Modules"-pagina) — nodig voor Mesa.
5. **Cython-3.1.3** (Python-module) — nodig voor PyYAML.
6. **PyYAML-6.0.2** (Python-module, Required: Cython + libyaml) — nodig
   voor Mesa.
7. **GLib-2.84.4, stap 1/3** — bouwen met `-D introspection=disabled`,
   installeren.
8. **GObject-Introspection-1.84.0** — bouwen tegen de zojuist
   geïnstalleerde GLib, installeren. (Dit is GEEN eigen BLFS-pagina; de
   instructies staan letterlijk IN GLib's eigen paginatekst als
   "Additional Downloads".)
9. **GLib-2.84.4, stap 2/3** — `meson configure -D introspection=enabled`
   in dezelfde build-map, herbouwen, opnieuw installeren. Reden voor
   deze twee-staps-bootstrap (letterlijk uit het boek): GObject-
   Introspection zelf heeft GLib nodig om te bouwen, maar GLib's eigen
   introspectiedata heeft GObject-Introspection nodig om te genereren.
10. **libxml2-2.14.5** — los, nodig voor shared-mime-info.
11. **shared-mime-info-2.4** (Required: GLib + libxml2) — nodig voor
    gdk-pixbuf.
12. **dbus-1.16.2** — los, nodig voor at-spi2-core.
13. **gsettings-desktop-schemas-48.0** (Required: GLib) — runtime-dep
    van at-spi2-core.
14. **HarfBuzz-11.4.1** (Recommended: GLib, FreeType — FreeType komt uit
    03a, nog zonder harfbuzz-ondersteuning; dat is voor deze eerste
    HarfBuzz-build geen probleem).
15. **FreeType-2.13.3 — HERBOUW** (boek, letterlijk bij HarfBuzz's eigen
    Recommended-regel: "after harfbuzz is installed, reinstall
    freetype"). FreeType's configure detecteert HarfBuzz nu automatisch
    via pkgconfig en voegt subpixel-hinting-ondersteuning toe.
16. **Fontconfig-2.17.1 — HERBOUW** (boek, letterlijk bij Pango's eigen
    Required-regel: "must be built with FreeType using HarfBuzz").
    Linkt nu tegen de zojuist herbouwde, HarfBuzz-bewuste FreeType.
17. **FriBidi-1.0.16** — los (geen dependencies), nodig voor Pango.
18. **Cairo-1.18.4** (Required: libpng, Pixman-uit-03a; Recommended:
    Fontconfig-herbouwd, GLib, Xorg Libraries-uit-03a). Boek-note:
    circulaire relatie met HarfBuzz ("indien Cairo vóór HarfBuzz gebouwd
    wordt, Cairo herbouwen na HarfBuzz om Pango te kunnen bouwen") — bij
    ons al vanzelf goed omdat HarfBuzz (stap 14) al vóór Cairo gebouwd
    wordt, dus geen aparte Cairo-herbouw nodig.
19. **Pango-1.56.4** (Required: Fontconfig-herbouwd, FriBidi, GLib;
    Recommended: Cairo-gebouwd-na-HarfBuzz — voldaan door de volgorde
    hierboven).
20. **CMake-4.1.0** — los (geen harde dependencies buiten wat we al
    hebben), nodig voor libjpeg-turbo én later LLVM.
21. **libjpeg-turbo-3.0.1** (Required: CMake) — nodig voor gdk-pixbuf.
22. **gdk-pixbuf-2.42.12** (Required: GLib, libjpeg-turbo, libpng,
    shared-mime-info).
23. **At-Spi2 Core-2.56.4** (Required: dbus, GLib, Xorg Libraries;
    Runtime: gsettings-desktop-schemas).
24. **LLVM-20.1.8** (Required: CMake) — **bewust MINIMAAL**: alleen de
    kernbibliotheken die llvmpipe nodig heeft, GEEN Clang (boek: "Recommended
    Download", niet nodig voor Mesa), GEEN Compiler-RT (Optional), GEEN
    testsuite. Dit is verreweg het zwaarste pakket in heel fase 3b (boek
    schat 13 SBU met parallelism=8, 4.7 GB schijfruimte) — reken op een
    aanzienlijk langere CI-tijd voor deze ene stap dan al het andere in
    03b samen. `CMAKE_BUILD_TYPE=Release` en een beperkte
    `LLVM_TARGETS_TO_BUILD=X86` houden dit zo klein als voor llvmpipe
    nodig is.
25. **Mesa-25.1.8** (Required: Xorg Libraries-uit-03a, libdrm-uit-03a,
    Mako, PyYAML; effectief vereist: LLVM voor llvmpipe specifiek) — zie
    Beslislog (2026-09-22): `-D gallium-drivers=llvmpipe -D
    platforms=x11 -D vulkan-drivers=` (leeg).
26. **libepoxy-1.5.10** (Required: Mesa).
27. **GTK3-3.24.50** (Required: at-spi2-core, gdk-pixbuf, libepoxy,
    Pango; effectief vereist: GLib-met-introspectie).

Niet meegenomen (bewust, "Recommended"/"Optional" en niet nodig om te
bouwen): ICU, Graphite2, Wayland/wayland-protocols/libxkbcommon
(X11-only-doel), adwaita-icon-theme (runtime-thema, geen bouwblokkering),
libtiff/librsvg (gdk-pixbuf runtime-loaders), NASM/yasm (libjpeg-turbo
optimalisatie).

Vierde CI-cache-laag (`lfs-gtk3-complete-*`) volgens hetzelfde patroon
als de eerdere drie, op de grens ná 03b — zodat een latere fout in
XFCE-core (fase 3c) niet ook deze hele, zware stack (met name LLVM)
opnieuw laat bouwen.

## Security / Secrets (grondregel, niet-onderhandelbaar)
- **Nooit hardcoded secrets, accounts of persoonlijke data in de repo** —
  ook niet tijdens de publieke periode.
- `.env.example` bevat alleen placeholders; echte waarden komen uitsluitend
  via de first-boot wizard op de doel-pc, in een lokale `.env` (uitgesloten
  via `.gitignore`).
- Geen API-keys of tokens in de workflow-yml.

## Nog open / bekende risico's
- **Fase 2 (LFS hoofdstuk 6, 7 én 8) en fase 3a (Xorg-basisbibliotheken +
  server, 54 pakketten) zijn beide volledig bewezen binnen GitHub
  Actions**, elk met een eigen cache-laag (bootstrap/ch8-complete/
  xorg-complete). Laatste volledige groene run met alle drie de lagen
  bewezen: 11m28s (run 35726410887). Voor fase 3b/3c (Mesa/GTK3-stack,
  XFCE-core) en fase 4 (devstack) is dit nog niet bewezen — die zijn
  zwaarder. Mitigatie (checkpoints/cache al VANAF de eerste stap, niet
  pas achteraf) staat en werkt aantoonbaar goed (zie "Vast bouwpatroon
  per fase"), wordt per fase opnieuw getoetst.
- Exacte pakketlijst/versies voor XFCE-core + GTK3-supporting-stack zijn
  nu wel uitgewerkt (zie "Dependency-audit fase 3b/3c" hierboven), maar
  nog niet omgezet naar daadwerkelijke bouwscripts.
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
- **2026-09-22 — Mesa-vraagstuk (GTK3/XFCE-laag) opgelost: Mesa MET, maar
  alleen llvmpipe (software-rendering).** Zie "Dependency-audit fase
  3b/3c" hierboven voor de volledige onderbouwing (libepoxy → Mesa is een
  harde, niet te omzeilen GTK3-afhankelijkheid). Voorgelegd aan Brionize
  als een echt beslispunt; Brionize gaf expliciet mandaat aan de AI om de
  knoop door te hakken ("ik vertrouw op jou keuze... zolang alles straks
  maar werkt en niet corrupt is"). Gekozen aanpak, met onderbouwing:
  - Mesa-25.1.8 bouwen met `-D gallium-drivers=llvmpipe` (alleen de
    CPU-software-rasterizer, geen hardware-GPU-vendor-drivers) i.p.v. het
    boek's standaard `auto` (bouwt ALLE drivers voor alle GPU-merken).
    Houdt de oorspronkelijke "generieke hardware, geen
    GPU-driver-afhankelijkheid"-doelstelling overeind voor de
    GTK3/XFCE-laag, tegen een kleinere bouw-/tijdsimpact dan de volledige
    driver-set.
  - `-D platforms=x11` (geen wayland — XFCE gebruikt hier X11, dus de
    wayland-protocols-afhankelijkheidsketen is overbodig).
  - `-D vulkan-drivers=` (leeg — geen Vulkan nodig voor een
    software-only, X11-only desktop).
  - xorg-server's eigen `-D glamor=false -D glx=false` (eerder al bewezen
    in CI) blijft ONGEWIJZIGD — Mesa komt er via GTK3/libepoxy bij, niet
    om alsnog GPU-versnelde Xorg-compositing te activeren. Twee losse,
    bewuste keuzes die elkaar niet hoeven te raken.
  - Vereist zelf nog LLVM-20.1.8 (nodig voor llvmpipe specifiek, boek
    noemt dit als "Recommended" maar is voor ons effectief verplicht),
    libdrm-2.4.125, en de Python-modules Mako en PyYAML (installatiepad
    nog niet exact uitgezocht — vermoedelijk `pip3 install`, nog te
    bevestigen bij het schrijven van de daadwerkelijke Mesa-bouwscripts).
