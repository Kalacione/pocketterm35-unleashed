-- Accueil du lecteur : sans fichier, mpv affiche un menu uosc au lieu d'un écran noir.
-- Comme le menu de pt35 sur un bureau vide, il revient dès qu'aucun menu n'est ouvert :
-- B ne laisse jamais un écran muet, L ferme l'app comme partout.
local utils = require 'mp.utils'
local script = mp.get_script_name()

-- Le dossier de la médiathèque est celui où uosc commence à parcourir (profil de l'app).
local function library()
  local dir = mp.get_opt('uosc-default_directory') or '~/'
  return dir, mp.command_native({'expand-path', dir})
end

-- Vide = aucun fichier, sous-dossiers compris. On s'arrête au premier trouvé.
local function has_files(path)
  if (utils.readdir(path, 'files') or {})[1] then return true end
  for _, dir in ipairs(utils.readdir(path, 'dirs') or {}) do
    if dir:sub(1, 1) ~= '.' and has_files(path .. '/' .. dir) then return true end
  end
  return false
end

-- format_json renvoie aussi une erreur (nil) : commandv refuserait cet argument en plus.
local function menu_json(t) return (utils.format_json(t)) end

local function open_home()
  local dir, path = library()
  local empty = not has_files(path)
  local items = {
    {title = 'Browse', hint = dir, value = 'script-binding uosc/open-file'},
    {title = 'Open URL', value = {'script-message-to', script, 'url'}},
  }
  if not empty then table.insert(items, 1, {title = 'Play all', hint = dir, value = {'loadfile', path}}) end
  mp.commandv('script-message-to', 'uosc', 'open-menu', menu_json({
    type = 'pt35-home',
    title = empty and 'Empty folder' or 'Nothing playing',
    search_style = 'disabled',
    items = items,
  }))
end

-- Le champ de recherche d'uosc sert de saisie : on tape l'URL au clavier, Entrée l'ouvre.
mp.register_script_message('url', function()
  mp.commandv('script-message-to', 'uosc', 'open-menu', menu_json({
    type = 'pt35-url',
    title = 'Open URL',
    search_style = 'palette',
    search_debounce = 'submit',
    on_search = {'script-message-to', script, 'open-url'},
    footnote = 'A: open. YouTube links need yt-dlp',
    items = {},
  }))
end)

mp.register_script_message('open-url', function(url)
  if url == '' then return end
  mp.commandv('script-message-to', 'uosc', 'close-menu', 'pt35-url')
  mp.commandv('loadfile', url)
end)

-- Un menu en remplace un autre en deux temps : on décide 0,3 s après le dernier changement.
local timer = mp.add_timeout(0.3, function()
  local menu = mp.get_property_native('user-data/uosc/menu/type')
  if mp.get_property_native('idle-active') then
    if not menu then open_home() end
  elseif menu == 'pt35-home' or menu == 'pt35-url' then
    mp.commandv('script-message-to', 'uosc', 'close-menu', menu)
  end
end)
timer:kill()

local function check() timer:kill(); timer:resume() end
mp.observe_property('idle-active', 'native', check)
mp.observe_property('user-data/uosc/menu/type', 'native', check)
