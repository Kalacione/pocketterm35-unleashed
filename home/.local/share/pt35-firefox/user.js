// Profil Firefox du PocketTerm, lancé par la tuile Navigateur
// (firefox --profile ~/.local/share/pt35-firefox, voir apps.toml).
// Seules les préférences qu'on change. Firefox relit ce fichier à chaque
// démarrage : une préférence retirée d'ici reste dans prefs.js jusqu'à ce
// qu'on la remette par défaut dans about:config.

// Pages mobiles : les sites qui choisissent par user-agent (Wikipédia,
// Google, YouTube...) servent leur version mobile. Le numéro de version
// compte peu, « Mobile » et « Android » font le travail.
user_pref("general.useragent.override", "Mozilla/5.0 (Android 15; Mobile; rv:150.0) Gecko/150.0 Firefox/150.0");

// 1,5 pixel d'écran par pixel CSS : la page fait 427 px de large, comme un
// téléphone, et le texte a la taille physique de celui d'un téléphone. Les
// autres sites passent en mise en page mobile par leur largeur seule.
// Agrandit aussi les menus et les boutons du navigateur (cible 40 px).
// 1.25 si c'est trop gros (512 px de large).
user_pref("layout.css.devPixelsPerPx", "1.5");

// userChrome.css (chrome/) : barre et menus aux couleurs Phosphore.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Thème sombre de base, pour tout ce que userChrome.css ne couvre pas, et
// les sites qui ont une version sombre la servent.
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("layout.css.prefers-color-scheme.content-override", 0);

// Pas de boutons de fenêtre dans la barre d'onglets : sway gère la fenêtre.
user_pref("browser.tabs.inTitlebar", 0);
user_pref("browser.toolbars.bookmarks.visibility", "never");

// Pas de fenêtres d'accueil ni de questions au premier lancement : à
// 640x480 elles couvrent tout l'écran.
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
