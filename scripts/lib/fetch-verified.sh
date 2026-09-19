# scripts/lib/fetch-verified.sh
#
# Herbruikbare bron-fetch-met-fallback voor ALLE bouwfasen (01-toolchain,
# 02-base-system, en toekomstig 03-blfs-desktop/04-devstack-apps). Wordt
# gesourced, niet los uitgevoerd.
#
# Achtergrond (zie BLUEPRINT.md "Bronbeschikbaarheid & fallback-beleid"):
# LFS-mirrors — vooral dated snapshots zoals ncurses' "current/"-map —
# rollen bestanden geregeld weg. In plaats van dat elke keer als losse
# onderbreking te behandelen, probeert fetch_verified automatisch een
# vaste reeks archiefbronnen. Dat mag ALLEEN zonder mens/AI-tussenkomst
# omdat elke kandidaat verplicht tegen de officiële LFS-checksum wordt
# geverifieerd — bij een match is het bewijsbaar exact hetzelfde bestand,
# ongeacht welke bron het uiteindelijk leverde. Geen enkele match ergens
# gevonden? Dan stopt de build en escaleert dit als een echt beslispunt
# (mogelijke versie-afwijking) — dat wordt nooit stilzwijgend doorgedrukt.
#
# Gebruik:
#   source ".../lib/fetch-verified.sh"
#   fetch_verified "<bestandsnaam>" "<officiële-url>" "<verwachte-md5>"

_fv_urlencode() {
  python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$1"
}

_fv_try_direct() { # url filename
  wget --no-verbose --timeout=30 --tries=2 -O "$2" "$1" >/dev/null 2>&1
}

_fv_try_wayback() { # primary_url filename
  local primary_url="$1" filename="$2"
  local row ts orig
  row=$(curl -s --max-time 20 \
    "http://web.archive.org/cdx/search/cdx?url=$(_fv_urlencode "$primary_url")&output=json&limit=1&filter=statuscode:200&fl=timestamp,original" \
    | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    if len(d) > 1:
        row = dict(zip(d[0], d[1]))
        print(row["timestamp"] + "\t" + row["original"])
except Exception:
    pass
' 2>/dev/null)
  [ -z "$row" ] && return 1
  ts="${row%%$'\t'*}"
  orig="${row#*$'\t'}"
  [ -z "$ts" ] && return 1
  wget --no-verbose --timeout=30 --tries=2 -O "$filename" "http://web.archive.org/web/${ts}id_/${orig}" >/dev/null 2>&1
}

_fv_try_swh() { # primary_url filename
  local primary_url="$1"
  # Software Heritage's content-API vereist vooraf een sha1/sha256/
  # blake2s256 (geen md5-lookup), en de origin-search-API bleek in de
  # praktijk geblokkeerd door een antibot-check (Anubis) — dus geen
  # generieke "zoek op bestandsnaam" mogelijk. Best-effort: alleen zinvol
  # als SWH deze exacte URL al als origin heeft gearchiveerd.
  local code
  code=$(curl -s --max-time 20 -o /dev/null -w "%{http_code}" \
    "https://archive.softwareheritage.org/api/1/origin/$(_fv_urlencode "$primary_url")/get/")
  # Geen bruikbare content-traversal geïmplementeerd zolang we geen
  # concreet geval hebben waarin deze origin ook echt bestaat (code=200) —
  # dan is dit alsnog een fallback zonder resultaat, geen valse hit.
  return 1
}

_fv_try_debian_snapshot() {
  # snapshot.debian.org zoekt op sha1 van het bestand zelf (/mr/file/<sha1>/info)
  # of op vooraf bekend pakket+versie (/mr/package/<naam>/<versie>/srcfiles) —
  # geen generieke bestandsnaam→URL-mapping mogelijk zonder die kennis.
  # Blijft daarom een handmatige escalatie-optie (zie BLUEPRINT.md), geen
  # automatische bron.
  return 1
}

# Zelf-gehoste back-up (GitHub Release "build-deps" in deze repo) voor
# bestanden die bewezen onbetrouwbaar bleken via alle bovenstaande bronnen —
# elk hier vermeld bestand is vooraf handmatig gedownload en tegen de
# officiële LFS-md5 geverifieerd vóórdat het hier werd geüpload (zie
# PROGRESS.md voor het concrete geval: ncurses' officiële mirror is
# permanent dood, en de Wayback Machine bleek specifiek vanuit GitHub
# Actions-IP-reeksen onbetrouwbaar terwijl 'ie elders wel werkte). Dit is
# een allerlaatste, door onszelf gecontroleerde bron — geen vervanging van
# de officiële bron, alleen een stabielere fallback dan externe archieven.
declare -A _FV_SELF_HOSTED=(
  [ncurses-6.5-20250809.tgz]="https://github.com/brionize-nl/brionize-command-center/releases/download/build-deps/ncurses-6.5-20250809.tgz"
)

_fv_try_self_hosted() { # filename filename
  local url="${_FV_SELF_HOSTED[$1]:-}"
  [ -z "$url" ] && return 1
  wget --no-verbose --timeout=30 --tries=2 -O "$2" "$url" >/dev/null 2>&1
}

fetch_verified() {
  local filename="$1" primary_url="$2" expected_md5="$3"

  if [ -f "$filename" ] && echo "$expected_md5  $filename" | md5sum -c - >/dev/null 2>&1; then
    echo "==> [$filename] al aanwezig, checksum klopt (cache)"
    return 0
  fi
  rm -f "$filename"

  local -a src_labels=() src_funcs=() src_args=()

  src_labels+=("officiële URL");    src_funcs+=("_fv_try_direct");          src_args+=("$primary_url")

  if [ -n "${_FV_SELF_HOSTED[$filename]:-}" ]; then
    src_labels+=("eigen back-up (GitHub Release)")
    src_funcs+=("_fv_try_self_hosted")
    src_args+=("$filename")
  fi

  if [[ "$primary_url" == https://ftp.gnu.org/gnu/* ]]; then
    src_labels+=("GNU-mirrornetwerk (ftpmirror.gnu.org)")
    src_funcs+=("_fv_try_direct")
    src_args+=("${primary_url/https:\/\/ftp.gnu.org/https:\/\/ftpmirror.gnu.org}")
  fi

  src_labels+=("Wayback Machine");     src_funcs+=("_fv_try_wayback");          src_args+=("$primary_url")
  src_labels+=("Software Heritage");   src_funcs+=("_fv_try_swh");              src_args+=("$primary_url")
  src_labels+=("snapshot.debian.org"); src_funcs+=("_fv_try_debian_snapshot");  src_args+=("$primary_url")

  local i attempt ok
  for i in "${!src_labels[@]}"; do
    echo "==> [$filename] proberen via ${src_labels[$i]}..."
    # 3 pogingen per bron met een korte pauze ertussen — ondervonden dat de
    # Wayback Machine na een storing een wankele/schokkerige herstelfase kan
    # hebben (soms wel, soms niet bereikbaar binnen enkele minuten), waarbij
    # één losse poging pech kan hebben terwijl de bron feitelijk alweer
    # (grotendeels) werkt. Geen eindeloze retry — na 3x mislukt gaat de
    # keten door naar de volgende bron, zoals bedoeld.
    ok=false
    for attempt in 1 2 3; do
      if "${src_funcs[$i]}" "${src_args[$i]}" "$filename"; then
        ok=true
        break
      fi
      if [ "$attempt" -lt 3 ]; then
        echo "==> [$filename] ${src_labels[$i]}: poging $attempt mislukt, nieuwe poging over 10s..."
        sleep 10
      fi
    done
    if [ "$ok" = true ]; then
      if echo "$expected_md5  $filename" | md5sum -c - >/dev/null 2>&1; then
        echo "==> [$filename] geverifieerd via ${src_labels[$i]} (md5 $expected_md5 bevestigd)"
        return 0
      else
        echo "==> [$filename] via ${src_labels[$i]} gedownload maar checksum komt NIET overeen — verworpen"
        rm -f "$filename"
      fi
    fi
  done

  echo "FOUT: [$filename] via geen enkele bron (officieel, eigen back-up, GNU-mirror, Wayback, Software Heritage, snapshot.debian.org) een kloppende checksum ($expected_md5) gekregen." >&2
  echo "Dit is een echt beslispunt (mogelijke versie-afwijking) — build stopt hier, geen automatische versie-bump." >&2
  return 1
}
