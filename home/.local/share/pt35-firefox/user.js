// Profil Firefox du PocketTerm, lancé par la tuile Navigateur
// (firefox --profile ~/.local/share/pt35-firefox, voir apps.toml).
// Seules les préférences qu'on change. Firefox relit ce fichier à chaque
// démarrage : une préférence retirée d'ici reste dans prefs.js jusqu'à ce
// qu'on la remette par défaut dans about:config.

// Pages mobiles : les sites qui choisissent par user-agent (Wikipédia,
// Google, YouTube...) servent leur version mobile. Le numéro de version
// compte peu, « Mobile » et « Android » font le travail.
user_pref("general.useragent.override", "Mozilla/5.0 (Android 15; Mobile; rv:150.0) Gecko/150.0 Firefox/150.0");

// Viewport mobile, comme la vue adaptative (Ctrl+Maj+M) sans sa barre :
// la page suit la largeur de l'écran, une page de bureau est réduite pour
// tenir en largeur. Pincer ou toucher deux fois zoome, comme sur Android.
user_pref("dom.meta-viewport.enabled", true);
user_pref("apz.allow_zooming", true);
user_pref("apz.allow_double_tap_zooming", true);
// Les sites voient un écran tactile.
user_pref("dom.maxtouchpoints.testing.value", 1);

// Échelle de l'écran : celle du système. À 1,5 (première version), sous
// Wayland la fenêtre débordait de l'écran d'un tiers, à droite et en bas.
// Valeur par défaut écrite en clair : la retirer la laisserait dans prefs.js.
// L'interface est agrandie par userChrome.css, pas par l'échelle.
user_pref("layout.css.devPixelsPerPx", "-1.0");

// userChrome.css (chrome/) : barre et menus aux couleurs Phosphore.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Thème sombre de base, pour tout ce que userChrome.css ne couvre pas, et
// les sites qui ont une version sombre la servent.
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("layout.css.prefers-color-scheme.content-override", 0);

// Pas de boutons de fenêtre dans la barre d'onglets : sway gère la fenêtre.
user_pref("browser.tabs.inTitlebar", 0);
user_pref("browser.toolbars.bookmarks.visibility", "never");

// Au lancement, l'accueil de Firefox seul : pas d'onglet de bienvenue, de
// nouveautés ni de politique de confidentialité, pas de page de démarrage
// de la distribution. À 640x480 chacun couvre tout l'écran.
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "about:home");
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("startup.homepage_override_url", "");
user_pref("browser.aboutwelcome.enabled", false);
user_pref("datareporting.policy.firstRunURL", "");
user_pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("browser.shell.checkDefaultBrowser", false);
// L'accueil d'avant « Nova », trop large pour un petit écran
// (repris de mobile-config-firefox, postmarketOS).
user_pref("browser.newtabpage.activity-stream.nova.enabled", false);
