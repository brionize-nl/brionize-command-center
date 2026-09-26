/* command-center-kiosk.c
 *
 * Minimale WebKitGTK-kiosk-shell voor Command-Center-Matrix.
 *
 * Toont EEN webapp (naam + URL) in een gewoon, door de window-manager
 * beheerbaar venster: geen adresbalk, geen menu/toolbar, maar WEL een
 * normale titelbalk (verplaatsbaar/herformaatbaar/sluitbaar). Dit is
 * bewust GEEN vaste fullscreen-lock — de tegel-manager (fase 5c) toont
 * straks precies dit soort echte, live vensters in tegels, en
 * devilspie2/wmctrl blijft daarvoor het technische fundament (zie
 * BLUEPRINT.md "UX-herziening: Tegel-manager & Visuele laag").
 *
 * Twee aanroepvormen:
 *   command-center-kiosk --webapp=NAME
 *     Zoekt NAME op in ~/.config/command-center/webapps.ini (door
 *     command-center-webapp-add geschreven) en opent de bijbehorende
 *     URL. Dit is de vorm die sneltoetsen gebruiken (zie
 *     command-center-webapp-add) — de URL zelf staat dus niet in de
 *     sneltoets-configuratie, alleen de webapp-naam.
 *   command-center-kiosk --url=URL --title=TITEL
 *     Directe modus (handig voor ad-hoc gebruik/testen), zonder de
 *     config-file nodig te hebben.
 *
 * Venstertitel = de webapp-naam. Dit is BEWUST het enige
 * "identificatiekenmerk" dat toekomstige devilspie2-regels/tile-
 * manager-code nodig hebben — generiek, niet per-AI hardcoded (in
 * tegenstelling tot de oude, door de UX-herziening van 2026-09-26
 * vervangen aanpak in
 * scripts/03-blfs-desktop/inside-chroot-03d/command-center-tiling.lua,
 * die specifieke productnamen als "Claude"/"ChatGPT" hardcodeerde).
 * WM_CLASS is altijd vast "CommandCenterKiosk", ongeacht welke webapp
 * er open staat — zodat matching-code op class kan filteren en op
 * titel kan onderscheiden.
 */
#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
#include <glib.h>

static gchar *opt_webapp = NULL;
static gchar *opt_url = NULL;
static gchar *opt_title = NULL;

static const GOptionEntry option_entries[] = {
    { "webapp", 0, 0, G_OPTION_ARG_STRING, &opt_webapp,
      "Naam van een webapp uit webapps.ini", "NAME" },
    { "url", 0, 0, G_OPTION_ARG_STRING, &opt_url,
      "Direct te openen URL (zonder config-file)", "URL" },
    { "title", 0, 0, G_OPTION_ARG_STRING, &opt_title,
      "Venstertitel bij --url (verplicht samen met --url)", "TITEL" },
    { NULL, 0, 0, 0, NULL, NULL, NULL }
};

static gboolean
lookup_webapp(const gchar *name, gchar **out_url)
{
    g_autofree gchar *config_path = g_build_filename(
        g_get_user_config_dir(), "command-center", "webapps.ini", NULL);
    g_autoptr(GKeyFile) kf = g_key_file_new();
    g_autoptr(GError) err = NULL;

    if (!g_key_file_load_from_file(kf, config_path, G_KEY_FILE_NONE, &err)) {
        g_printerr("command-center-kiosk: kan %s niet lezen: %s\n",
                   config_path, err->message);
        return FALSE;
    }
    if (!g_key_file_has_group(kf, name)) {
        g_printerr("command-center-kiosk: webapp '%s' niet gevonden in %s\n",
                   name, config_path);
        return FALSE;
    }
    *out_url = g_key_file_get_string(kf, name, "URL", &err);
    if (*out_url == NULL) {
        g_printerr("command-center-kiosk: geen URL voor '%s' in %s: %s\n",
                   name, config_path, err->message);
        return FALSE;
    }
    return TRUE;
}

static void
on_activate(GtkApplication *app, gpointer user_data)
{
    const gchar *url = (const gchar *)user_data;
    const gchar *title = opt_title ? opt_title : (opt_webapp ? opt_webapp : url);

    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), title);
    gtk_window_set_default_size(GTK_WINDOW(window), 1280, 800);

    WebKitWebView *webview = webkit_web_view_new();
    gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(webview));
    webkit_web_view_load_uri(webview, url);

    gtk_widget_show_all(window);
}

int
main(int argc, char **argv)
{
    /* WM_CLASS-instance/class vastzetten vóórdat er iets van GTK/GDK
     * geïnitialiseerd wordt — dit is de niet-verouderde manier om
     * WM_CLASS te sturen in GTK3 (i.p.v. het verouderde
     * gtk_window_set_wmclass()). */
    g_set_prgname("command-center-kiosk");
    gdk_set_program_class("CommandCenterKiosk");

    g_autoptr(GOptionContext) ctx = g_option_context_new(
        "— minimale WebKitGTK-kiosk-shell voor Command-Center-Matrix");
    g_option_context_add_main_entries(ctx, option_entries, NULL);
    g_autoptr(GError) err = NULL;
    if (!g_option_context_parse(ctx, &argc, &argv, &err)) {
        g_printerr("command-center-kiosk: %s\n", err->message);
        return 1;
    }

    g_autofree gchar *resolved_url = NULL;
    const gchar *final_url;

    if (opt_webapp != NULL) {
        if (!lookup_webapp(opt_webapp, &resolved_url))
            return 1;
        final_url = resolved_url;
    } else if (opt_url != NULL) {
        if (opt_title == NULL) {
            g_printerr("command-center-kiosk: --title is verplicht samen met --url\n");
            return 1;
        }
        final_url = opt_url;
    } else {
        g_printerr("command-center-kiosk: geef --webapp=NAME of --url=URL --title=TITEL op\n");
        return 1;
    }

    /* G_APPLICATION_NON_UNIQUE: elke aanroep start een eigen, los
     * proces/venster. Zonder deze vlag zou een tweede webapp-tegel
     * alleen het EERSTE geopende venster activeren i.p.v. een nieuw
     * venster te openen — terwijl meerdere tegels/webapps gelijktijdig
     * live moeten kunnen staan. */
    GtkApplication *app = gtk_application_new(
        "nl.brionize.CommandCenterKiosk", G_APPLICATION_NON_UNIQUE);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), (gpointer)final_url);
    int status = g_application_run(G_APPLICATION(app), 0, NULL);
    g_object_unref(app);
    return status;
}
