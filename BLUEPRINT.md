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
   als de eerdere twee lagen (zie punt 2). Inmiddels ook toegepast op de
   grens ná 03b (GTK3-supporting-stack, `lfs-gtk3-complete-*`) — 03a en
   03b zijn losse, apart gecachete `docker run`-stappen binnen dezelfde
   workflow-job (`SKIP_GTK3_STACK=true` resp. `SKIP_XORG=true`), zelfde
   gelaagde patroon als bootstrap→ch8-complete. Inmiddels ook toegepast
   op de grens ná 03c (XFCE-core, `lfs-xfce-core-complete-*`) — 03a,
   03b en 03c zijn nu drie losse, apart gecachete stappen (`SKIP_XORG=
   true` + `SKIP_GTK3_STACK=true` samen bij een 03c-only-build).
   Vervolg-sub-fasen (apps-laag) krijgen op dezelfde manier hun eigen
   laag zodra ze bestaan, niet pas achteraf.
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

### Fase 3c — XFCE-core: aanvullende externe dependencies (2026-09-23)
Bij het daadwerkelijk scripten van de 17 XFCE-core-pakketten (volgorde
al vastgelegd hierboven) bleek een klein aantal externe dependencies
nog niet aanwezig te zijn (GTK-3.24.50, Cairo, pcre2, shared-mime-info,
GLib+GI, dbus, gsettings-desktop-schemas en at-spi2-core waren al
gebouwd sinds 03b). Elk letterlijk tegen de officiële BLFS-pagina
nagelopen, tarball-directorynaam vooraf geverifieerd (zelfde discipline
als 03a/03b):
- **hwdata-0.398** — geen dependencies, nodig voor libdisplay-info
  (bleek zelf ook nog niet in beeld: libdisplay-info is Required voor
  libdisplay-info → **hwdata-0.398** als eigen Required-dependency, niet
  eerder opgemerkt in de eerste audit-doorgang).
- **libdisplay-info-0.3.0** — Required: hwdata. Nodig voor
  libxfce4windowing.
- **hicolor-icon-theme-0.18** — geen dependencies, runtime voor thunar.
- **startup-notification-0.12** — Required: Xorg Libraries + xcb-util
  (al aanwezig uit 03a).
- **libgudev-238** — Required: GLib (aanwezig). Nodig voor
  thunar-volman.
- **Desktop-File-Utils-0.28** — Required: GLib (aanwezig).
- **LXDE Icon Theme-0.5.1** — bewust gekozen i.p.v. gnome-icon-theme
  (BLFS-pagina hiervoor niet meer gevonden/mogelijk vervallen in 12.4;
  LXDE-variant is functioneel gelijkwaardig voor xfce4-settings'
  runtime-vereiste en past bij de minimale-footprint-lijn van dit
  project).
- **libnotify-0.8.6** — Required: GTK3 (aanwezig). Runtime heeft dit
  zelf een notificatiedaemon nodig (bv. xfce4-notifyd, onderdeel van
  "Xfce Applications" — een latere, apart te scripten apps-sub-fase,
  géén build-blokkade voor libnotify zelf).

Bewust niet gebouwd (alleen "Recommended", legacy of niet meer
vindbaar): libxklavier (grotendeels vervangen door libxkbcommon, geen
actuele BLFS 12.4-pagina gevonden), gnome-icon-theme (LXDE-alternatief
gekozen).

Vijfde CI-cache-laag (`lfs-xfce-core-complete-*`) toegevoegd, zelfde
patroon als de eerdere vier, op de grens ná 03c.

### Fase 3d — Conky-HUD, window-tiling, 3 werkbladen/hotkeys (2026-09-23)
Op expliciet verzoek van Brionize: fase 3 helemaal afronden vóór fase 4
begint. Vier pakketten hier zijn NIET in BLFS 12.4 (niche
desktop-hulpprogramma's) — "Official Route First" betekent hier: elk
pakket se eigen officiële upstream-bron, tegen dezelfde precisie-
discipline (bron letterlijk gelezen, geen aannames, tarball-
directorynaam vooraf geverifieerd).

- **Lua-5.4.8** — WEL een BLFS-pagina (`general/lua.html`), met een
  vereiste patch voor een echte shared library + pkgconfig-bestand.
  Nodig voor zowel devilspie2 (Lua-scriptregels) als Conky (Lua-config
  — Conky's eigen `CMakeLists.txt` bevat een onvoorwaardelijke
  `find_package(Lua "5.3" REQUIRED)`, ontdekt door de daadwerkelijke
  broncode/CMake-bestanden te downloaden en te lezen, niet uit het
  geheugen).
- **wmctrl-1.07** — de oorspronkelijke site (tripie.sweb.cz) is dood;
  via de Wayback Machine (zelfde bewezen fallback-patroon als eerder
  bij ncurses). Standaard, klein autotools-pakket, geen nieuwe
  dependencies.
- **devilspie2-0.36** — officiële GitHub-tag van de hoofdontwikkelaar
  (gusnan/devilspie2). Eigen Makefile (geen configure/meson) las
  letterlijk uitgelezen voor de exacte pkg-config-namen: `gtk+-3.0`,
  `libwnck-3.0` (geleverd door onze libwnck-43.2), `lua`.
- **Conky-1.24.2** — officiële GitHub-tag. Zeer uitgebreid CMake-
  optiesysteem (`cmake/ConkyBuildOptions.cmake` letterlijk nagekeken);
  bewust minimaal gehouden passend bij het BLUEPRINT-doel
  ("CPU/RAM/opslag, Tailscale-status, logs"): X11+Xft aan (voor een
  leesbare HUD), Imlib2/Journal/Pulseaudio/MySQL/WLAN/Nvidia uit (geen
  extra pakketten nodig, niet relevant voor een tekst/grafieken-HUD).
  Een eigen standaard `conky.conf` (CPU/RAM/opslag/Tailscale-status/
  logs, zie `inside-chroot-03d/conky-command-center.conf`) vervangt
  Conky's eigen voorbeeldconfig vóór het bouwen — via
  `BUILD_BUILTIN_CONFIG` (boek-default aan) wordt dit ten tijde van
  bouwen in de executable ingebakken (`text2c`), dus de standaard-HUD
  voor elke gebruiker zonder losse configuratiestap. De Tailscale-
  statusregel faalt bewust stil (`2>/dev/null`) zolang Tailscale zelf
  nog niet gebouwd is (dat hoort bij fase 4) — begint vanzelf te werken
  zodra dat er is.
- **3 werkbladen + Super+1/2/3** — GEEN los pakket, systeembrede
  xfconf-standaardconfiguratie onder `/etc/xdg/xfce4/xfconf/xfce-
  perchannel-xml/` (het officiële XFCE-mechanisme voor systeembrede
  defaults die elke — ook toekomstige — gebruiker zonder eigen
  overrides erft). Schema NIET gegokt maar overgenomen uit de
  daadwerkelijke pakketbroncode: xfwm4's `src/settings.c` bevestigt
  channel "xfwm4" + `/general/`-padvoorvoegsel voor
  workspace_count/workspace_names; xfce4-panel's eigen
  `migrate/default.xml` bevestigt de xfconf-array-XML-syntax.
  `xfce4-keyboard-shortcuts.xml` wordt AL door libxfce4ui zelf
  geïnstalleerd (sinds 03c, bevestigd via libxfce4ui's eigen
  `Makefile.am`: `settingsdir = $(sysconfdir)/xdg/xfce4/xfconf/
  xfce-perchannel-xml`) — dat bestand wordt hier gericht bewerkt (3
  standaard workspace-sneltoetsen, boek-default `<Primary>F1/F2/F3`,
  vervangen door Super+1/2/3), niet vervangen; alle overige
  sneltoetsen blijven ongemoeid.

**Bewust nog niet gedaan (buiten scope van dit verzoek):** concrete
devilspie2-Lua-tegelregels (welke apps waar getegeld worden is nog een
open productkeuze, niet zomaar in te vullen), XFCE dark theme (in
BLUEPRINT's oorspronkelijke fase-3-scope genoemd maar niet expliciet
in dit verzoek gevraagd — blijft open, zie "Nog open/bekende risico's").

Zesde CI-cache-laag (`lfs-xfce-extras-complete-*`) toegevoegd, zelfde
patroon als de eerdere vijf, op de grens ná 03d. Bij het toevoegen ook
de drie bestaande fase-3a/3b/3c-workflow-stappen proactief voorzien van
`SKIP_XFCE_EXTRAS=true` (zelfde les als de eerdere scoping-bug rond
03c: elke stap moet alle LATERE sub-fasen expliciet overslaan, anders
loopt hij er ongemerkt in door).

### Fase 3d afronding — Matrix-thema + tegelregels (2026-09-23)
Brionize vulde de twee laatste open productkeuzes in: dark theme
("Matrix/cyberpunk-stijl — diepzwart met neon-groen/cyaan accenten")
en de exacte devilspie2-tegelindeling per werkblad.

**Thema — `Command-Center-Matrix` (zelf samengesteld, geen bestaand
pakket):** eerst twee bestaande GTK/XFCE-cyberpunk-thema's onderzocht:
`Roboron3042/Cyberpunk-Neon` (839 sterren) bleek bij het nalezen van de
daadwerkelijke oomox-kleurdefinities een outrun-palet (marineblauw
`#000b1e` + cyaan `#0abdc6` + MAGENTA `#ea00d9`) — geen groen, dus geen
match met "Matrix". `debarch777/WoodyCat-ctOS-Theme` heeft wél een
letterlijke "Toxic Matrix (Green) — `#00ff88`"-editie, maar is een
zware, opinionated "suite" die `apt`/`pacman`/`dnf` aanroept (wij
hebben geen package manager), zijn EIGEN Conky-config/autostart
installeert (conflicteert met onze al bestaande, bewust scoped
Conky-HUD) en qterminal/whiskermenu/fastfetch/imagemagick vereist —
niets hiervan past bij dit from-scratch-project. Gekozen: zelf een
minimaal GTK3-CSS-thema samenstellen (de coordinator se eigen
aangeboden alternatief), consistent met de hele LFS/BLFS-filosofie
("alles zelf bouwen, geen ondoorzichtige externe assets").
- Gebouwd BOVENOP GTK3's ingebakken Adwaita-dark (geen aparte
  GTK-theme-package nodig) — het resourcepad
  (`resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css`)
  en de volledige lijst @define-color-namen zijn letterlijk
  geverifieerd tegen GTK3's eigen broncode (`gtk/gen-gtk-gresources-
  xml.py` en `gtk/theme/Adwaita/_colors-public.scss`), niet gegokt.
- Kleurenpalet: bg `#050805` (bijna-zwart), base `#000000`,
  fg/tekst/accent `#00ff41` (Matrix-neon-groen), secundair/borders
  `#0abdc6` (neon-cyaan), standaard warning/error-kleuren behouden
  voor leesbaarheid.
- Actief gezet via de bestaande `xsettings.xml` (al geïnstalleerd door
  xfce4-settings in 03c, channel "xsettings", `/Net/ThemeName` —
  bevestigd via xfsettingsd's eigen `xsettings.c`, dat elke
  `/Net/`-of-`/Gtk/`-property generiek doorgeeft aan het
  XSETTINGS-protocol) — zelfde gericht-bewerken-i.p.v.-vervangen-
  patroon als bij de keyboard-shortcuts.
- **Bewuste scope-grens:** xfwm4's eigen randdecoratie/titelbalk-thema
  (een apart, bitmap-gebaseerd systeem, los van GTK-CSS) blijft op het
  standaard "Default"-thema — eigen randgrafiek tekenen valt buiten
  wat redelijk is zonder beeldbewerkingsgereedschap. Vastgelegd als
  bekende grens, niet stilzwijgend weggelaten.

**devilspie2-tegelregels (`command-center-tiling.lua`):** devilspie2's
Lua-API (functienamen, argumenten, 1-based workspace-nummering) NIET
gegokt maar letterlijk uitgelezen uit `src/script.c` (de
`lua_register`-aanroepen) en `src/script_functions.c` (de C-
implementaties, incl. `wnck_screen_get_workspace(screen, number-1)` —
bevestigt dat `set_window_workspace(1)` echt werkblad 1 is). Matcht op
raamtitel via `string.find(name, "...", 1, true)` (plain-string-modus,
geen Lua-patroon-escaping nodig) met de productnamen (n8n, Claude,
ChatGPT, Mistral, Gemini, Supabase) plus twee vaste titels voor de
nog-niet-bestaande terminals (`Command-Center-Logs`,
`Command-Center-GitHub` — fase 4 moet deze expliciet met `--title`
starten).
- Geïnstalleerd onder `/etc/skel/.config/devilspie2/` — NIET
  `/etc/xdg/...`: devilspie2's eigen README bevestigt dat het pakket
  alleen `g_get_user_config_dir()` leest, geen systeembrede
  xfconf-achtige fallback kent. `/etc/skel` is hier het juiste
  systeembrede-standaard-mechanisme (kopieert mee naar elke nieuwe
  gebruiker via `useradd -m`).
- **Evidence-grens, expliciet benoemd:** gevalideerd met `luac -p`
  tijdens het bouwen (bewijst geldige Lua-SYNTAX) — dit bewijst NIET
  dat de titelpatronen runtime kloppen tegen de daadwerkelijke apps,
  wat onmogelijk te testen is zonder een live X-sessie met die apps
  open (bestaan pas na fase 4). Expliciet vastgelegd als bekende
  beperking, niet als "klaar en getest" voorgesteld.

**Autostart:** Conky en devilspie2 hadden voorheen GEEN autostart-
mechanisme (alleen gebouwd, nooit gestart) — nu toegevoegd als
`/etc/xdg/autostart/*.desktop`-bestanden, letterlijk in hetzelfde
formaat en op hetzelfde pad als xfce4-settings' eigen
`xfsettingsd.desktop.in` (freedesktop-autostart, door xfce4-session
voor elke gebruiker doorlopen).

## Fase 4 — devstack: voorbereidend onderzoek (2026-09-22)
Uitgevoerd tijdens CI-wachttijd (fase 3b), op coordinator-verzoek —
puur onderzoek, nog geen scripts. Officiële bronnen/versies vandaag
geverifieerd (GitHub Releases-API's, npm-registry, officiële
downloadpagina's — niet uit het geheugen; versienummers zullen tegen
de tijd dat fase 4 echt gebouwd wordt opnieuw geverifieerd moeten
worden, dit is een momentopname). Voorkeur "Official Route First"
(§8.6 Matrix): prebuilt officiële Linux-x86_64-binaries/tarballs boven
zelf compileren, waar dat de normale distributievorm is.

- **Node.js** — huidige LTS: **v24.21.0** ("Krypton"), via
  `nodejs.org/dist/index.json`. Officiële prebuilt tarball:
  `https://nodejs.org/dist/v24.21.0/node-v24.21.0-linux-x64.tar.xz`
  (bevestigd bereikbaar, HTTP 200) — uitpakken en op PATH zetten, geen
  package manager nodig.
- **Bun** — huidige versie: **v1.4.2**, via GitHub Releases
  (`oven-sh/bun`). Prebuilt: `bun-linux-x64.zip` (ook musl/baseline-
  varianten beschikbaar voor oudere CPU's).
- **Python** — al aanwezig (hoofdstuk 8, Python 3.13.7 uit LFS zelf) —
  geen aparte fase-4-stap nodig.
- **PostgreSQL** — huidige versie: **17.6**. Twee routes onderzocht:
  (a) BLFS's eigen bouwpagina (`server/postgresql.html`, bron
  `https://ftp.postgresql.org/pub/source/v17.6/postgresql-17.6.tar.bz2`)
  — consistent met de rest van dit LFS-systeem (geen package manager,
  eigen user/group-conventies, geen systemd-afhankelijkheid); (b)
  EnterpriseDB's prebuilt generic-Linux-binaries — bestaan, maar de
  exacte downloadpad/bestandsnaam moet bij het echte bouwmoment opnieuw
  opgezocht worden (een geraden pad gaf een 403, dus niet zomaar
  hardcoden). **Voorlopige voorkeur: BLFS-bouwpagina**, zelfde
  discipline als fase 2/3.
- **Supabase CLI** — huidige versie: **v2.117.0**, via GitHub Releases
  (`supabase/cli`). Prebuilt: `supabase_2.117.0_linux_amd64.tar.gz`.
- **gh (GitHub CLI)** — huidige versie: **v2.101.0**, via GitHub
  Releases (`cli/cli`). Prebuilt: `gh_2.101.0_linux_amd64.tar.gz`.
- **n8n** — huidige versie: **2.40.5**, via npm-registry. Geen
  losstaande generic-Linux-binary — normale distributie is
  `npm install -g n8n` (heeft dus Node.js nodig, hierboven).
- **Tailscale** — huidige versie: **1.102.4**, via
  `pkgs.tailscale.com/stable/?mode=json` (officiële JSON-feed, geen
  giswerk nodig). Prebuilt: `tailscale_1.102.4_amd64.tgz`.
- **cloudflared** — huidige versie: **2026.9.1**, via GitHub Releases
  (`cloudflare/cloudflared`). Prebuilt: `cloudflared-linux-amd64`
  (los binary, geen tarball).
- **PM2** — huidige versie: **7.0.4**, via npm-registry. Net als n8n:
  `npm install -g pm2`, heeft Node.js nodig.

**Nog niet gedaan (bewust, hoort bij het echte fase-4-bouwmoment):**
MD5/checksum-verificatie per bestand (voor `fetch_verified()`), exacte
installatiescripts, PWA-snelkoppelingen-onderzoek, en een her-check van
alle versienummers hierboven (kunnen tegen die tijd alweer verouderd
zijn — dit is nadrukkelijk een momentopname, geen bevroren besluit).

## Security / Secrets (grondregel, niet-onderhandelbaar)
- **Nooit hardcoded secrets, accounts of persoonlijke data in de repo** —
  ook niet tijdens de publieke periode.
- `.env.example` bevat alleen placeholders; echte waarden komen uitsluitend
  via de first-boot wizard op de doel-pc, in een lokale `.env` (uitgesloten
  via `.gitignore`).
- Geen API-keys of tokens in de workflow-yml.

## Nog open / bekende risico's
- **HEEL FASE 3 (fase 2 + Xorg-basis + GTK3-supporting-stack +
  XFCE-core + Conky/tiling/werkbladen) is nu volledig bewezen binnen
  GitHub Actions**, met zes op elkaar gestapelde cache-lagen, allemaal
  samen bewezen in run 35853792648 (7m00s met alle lagen hit). ~102
  losse pakketten in totaal. Fase 4 (devstack) is nog niet bewezen.
  Mitigatie (checkpoints/cache al VANAF de eerste stap, niet pas
  achteraf) staat en werkt aantoonbaar goed (zie "Vast bouwpatroon per
  fase"), wordt per fase opnieuw getoetst.
- **Dark theme (Command-Center-Matrix) en devilspie2-tegelregels zijn
  nu uitgewerkt** (zie "Fase 3d afronding" hierboven), maar nog niet in
  CI gevalideerd — moeten nog een eerste keer draaien.
- devilspie2-tegelregels matchen op raamtitels van apps die pas in
  fase 4 gebouwd worden (n8n, AI-webapps, Supabase Studio) — kunnen
  daarom alleen op Lua-SYNTAX gevalideerd worden, niet op runtime-
  gedrag. Moet geverifieerd/bijgesteld worden zodra fase 4 de
  daadwerkelijke apps opzet. De twee terminals (Command-Center-Logs/
  -GitHub) moeten in fase 4 expliciet met een matchende `--title`
  gestart worden.
- xfwm4's eigen randdecoratie-/titelbalk-thema (bitmap-gebaseerd, los
  van GTK-CSS) is bewust NIET herontworpen — blijft op het standaard
  "Default"-thema.

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
- **2026-09-23 — Dark theme en devilspie2-tegelindeling ingevuld.**
  Matrix/cyberpunk-stijl (diepzwart + neon-groen/cyaan) gekozen;
  zelf samengesteld als `Command-Center-Matrix` GTK3-CSS-thema
  (bovenop Adwaita-dark) na te hebben vastgesteld dat geen van de
  onderzochte bestaande cyberpunk-thema's goed paste (zie "Fase 3d
  afronding" hierboven voor de volledige afweging). Tegelindeling:
  werkblad 1 = n8n-canvas + Conky-HUD + terminal-logs, werkblad 2 = 4
  AI-webapps in een 2x2-grid, werkblad 3 = Supabase Studio +
  GitHub-terminal — vastgelegd in devilspie2-Lua-regels die raamtitels
  matchen (nog te verifiëren zodra fase 4 de apps daadwerkelijk
  opzet).
