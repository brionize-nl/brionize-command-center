# Gedeelde Xorg-omgeving voor fase 3a, gesourced door elke pakketscript.
# BLFS 12.4 boekkeuze: XORG_PREFIX="<PREFIX>" is een bewuste keuze die het
# boek open laat — "The BLFS editors recommend using the /usr prefix."
# Wij volgen dat advies (single-tree systeem, geen los /usr/X11R6, geen
# noodzaak voor de boek's compatibiliteits-symlinks/PATH-aanvullingen die
# alleen relevant zijn bij een AFWIJKEND prefix).
export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
