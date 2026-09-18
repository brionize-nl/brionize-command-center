# SETUP

> Nog in opbouw. Dit document wordt bijgewerkt zodra de bouwscripts en de
> GitHub Actions-workflow bestaan (zie PROGRESS.md voor de actuele status).

## Voor de ontwikkelaar (Brionize)
Beoogde flow zodra de build klaar is:

1. Clone deze repo.
2. Start de ISO-build:
   - Via GitHub Actions: trigger de workflow (`.github/workflows/build-iso.yml`).
   - Lokaal (fallback): `./scripts/build-local.sh` — draait dezelfde
     Docker-gebaseerde bouwscripts als de CI, zonder tijd/schijflimiet.
3. Download het `.iso`-artifact.
4. Brand de ISO op een USB-stick (bv. Rufus, BalenaEtcher of `dd`).
5. Boot de doelmachine vanaf de USB-stick en volg de installer (partitioneert
   en installeert permanent naar de interne schijf).
6. Na de installatie draait automatisch de **first-boot wizard**: lokale
   gebruiker aanmaken, `tailscale up`, `gh auth login`, optioneel API-keys
   invoeren. De wizard schakelt zichzelf daarna uit.

## Voor een eindgebruiker
Geen technische voorkennis nodig: USB-stick erin, opstarten, installer
volgen, first-boot wizard doorlopen. Alle persoonlijke configuratie
(accounts, keys) wordt pas op dat moment ingevoerd — de ISO zelf bevat niets
persoonlijks.

## Configuratie
Zie `.env.example` voor de volledige lijst met optionele omgevingsvariabelen.
Nooit een echte `.env` met ingevulde waarden committen.
