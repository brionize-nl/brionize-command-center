# LFS 12.4 hoofdstuk 8

Deze scripts draaien als root **binnen de hoofdstuk-7-chroot**, met de virtuele
bestandssystemen gemount en de gebruiker `tester` nog aanwezig. Start
`bash /pad/naar/inside-chroot-ch8/run-all.sh` vanaf een terminal. De fetch-stap
`../ch8-00-fetch-sources.sh` draait vooraf als root **buiten** chroot.

De volgorde is 01–80 voor de pakketten, daarna 81 (Stripping) en 82 (Cleaning
Up). Elke stap schrijft naar `/sources/log-chroot-ch8-<scriptnaam>.txt`.
Een fout in een commando, test of logging stopt de orchestrator. De bronmap
blijft bij een fout staan voor onderzoek; verwijder of herstel die map voordat
je de betreffende pakketstap opnieuw start. Dit is geen hervatbare installer.

De commando's zijn rechtstreeks uit de lokale LFS 12.4-HTML gelezen, uit de
`kbd.command`-blokken binnen `pre`, met HTML-entiteiten gedecodeerd en behoud
van witruimte en here-documents. De Python-bronpagina heet `Python.html`.
De bron-URL's en MD5's komen letterlijk uit de aangeleverde `wget-list.txt`
en `md5sums.txt`. De fetch-lijst bevat ook de twee eerder geschreven pakketten,
alle zeven voorgeschreven patches, tijdzonedata en aanvullende documentatie.

## Keuzes voor uitvoering als scripts

- Testsuites staan standaard uit wegens het CI-tijdbudget en de betrouwbaarheid;
  verwijder de commentaartekens bij de testblokken voor een eenmalige handmatige verificatiebuild.

- Glibc: de normale nieuwe installatie, zonder de blokken die uitsluitend over
  upgrades van een bestaand LFS-systeem gaan. De expliciete testlocales worden
  geïnstalleerd; `make localedata/install-locales` is het alternatieve pad en
  wordt niet daarnaast uitgevoerd. De optionele loader-include-map is opgenomen.
- De placeholder voor de tijdzone wordt `Europe/Amsterdam`, aanpasbaar via
  `LFS_TIMEZONE`. De interactieve `tzselect`-hulp wordt niet gestart. Groff
  gebruikt `A4`, aanpasbaar via `LFS_PAPER_SIZE`. Exporteer deze variabelen
  binnen chroot als andere waarden gewenst zijn.
- Shadow voert letterlijk `passwd root` uit en vraagt dus om een wachtwoord.
  Het script bevat geen wachtwoord en stelt er ook geen automatisch in.
- Bash start geen interactieve login-shell met `exec`: de orchestrator start
  iedere volgende stap met de inmiddels geïnstalleerde `/usr/bin/bash`.
- De GMP-regel `ABI=32 ./configure ...` is een voorwaardelijk 32-bit voorbeeld,
  geen tweede configuratie. De normale configuratie is opgenomen. Het uitgecommentarieerde
  testblok toont het aantal geslaagde tests en controleert de ondergrens van 199.
- De optionele oude ABI's van Libxcrypt en Ncurses worden niet gebouwd.
  De aangeboden documentatie-installaties zijn wel opgenomen, evenals de
  optionele Ninja-aanpassing voor `NINJAJOBS` en Texinfo's TeX-bestanden.
  Het reparatievoorbeeld voor een beschadigde Info-index wordt niet uitgevoerd.
- Vim opent geen interactieve optie-editor. Util-linux bevat voor chroot
  alleen een uitgecommentarieerd testblok als `tester`; de root-test uit de waarschuwing is
  uitsluitend bedoeld voor een geboot LFS-systeem.
- De uitgecommentarieerde diagnostische Binutils-`grep` mag nul treffers hebben (exitstatus 1).
  Andere grep-fouten blijven fataal. Glibc's losse timeout-diagnose wordt niet
  als verplichte installatiestap uitgevoerd.
- Stripping behoudt de boekvolgorde en de tijdelijke kopieën voor actieve
  libraries en binaries. In de laatste lus worden alleen ELF-bestanden en
  ar-archieven gestript. Zo stoppen de door het boek verwachte niet-binaire
  bestanden de scriptuitvoering niet; echte strip-fouten blijven fataal.

## Tests en afhankelijkheden

De aangeboden chroot-testsuites zijn uitgecommentarieerd, inclusief hun
afhankelijke logcontroles. De losse compilercontroles blijven actief. Python
behoudt `--enable-optimizations`: de PGO-profielgeneratie tijdens `make` kan
tests uitvoeren als onderdeel van de build. Bij handmatig heringeschakelde
tests stoppen ook bekende testfouten de run voor inspectie van het log. Raadpleeg de betreffende lokale boekpagina voor
bekende fouten en eventuele benodigde host-kernelopties.

De pagina's bevatten geen afzonderlijke BLFS-achtige lijsten met
“Required Dependencies” of “Recommended Dependencies”. De relevante
voorwaarden in de lopende tekst zijn wel gecontroleerd:

- Tcl, Expect en DejaGNU ondersteunen de tests van onder meer Binutils en GCC;
  Expect controleert eerst of PTY's werken.
- Ninja-tests vereisen CMake en kunnen volgens de pagina niet in chroot draaien.
  Meson-tests vereisen pakketten buiten LFS; Kmod-tests vereisen ruwe
  kernelheaders. Daarom worden hiervoor geen extra tests toegevoegd.
- Kbd-tests vereisen Valgrind; Libpipeline-tests vereisen Check. GRUB-tests
  worden door de pagina afgeraden wegens ontbrekende pakketten. Ncurses-tests
  zijn alleen na installatie handmatig vanuit de testmap uitvoerbaar.
- Glibc noemt Libidn2 als optionele runtime-afhankelijkheid voor internationale
  domeinnamen. Shadow verwijst naar BLFS bij gebruik van Linux-PAM. De GRUB-pagina
  verwijst voor UEFI-ondersteuning en bijbehorende afhankelijkheden naar BLFS.
  Deze aanvullende BLFS-installaties vallen buiten deze hoofdstuk-8-scripts.

De scripts zijn statisch gecontroleerd; er is geen build uitgevoerd.
