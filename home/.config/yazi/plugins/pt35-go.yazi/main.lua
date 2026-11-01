-- X des boutons : Lieux. X encore = dossier personnel, 1 à 9 = hôtes SSH,
-- lus dans le vfs.toml que pt35-yazi-vfs écrit au lancement de Files.
return {
	entry = function()
		local cands, urls = { { on = "<Tab>", desc = "Home" } }, { "~" }
		local f = io.open(os.getenv("HOME") .. "/.config/yazi/vfs.toml")
		if f then
			for name in f:read("a"):gmatch("%[sftp%.([%w-]+)%]") do
				if #urls > 9 then break end
				cands[#cands + 1] = { on = tostring(#urls), desc = name }
				urls[#urls + 1] = "sftp://" .. name
			end
			f:close()
		end
		local i = ya.which { cands = cands }
		if i then ya.emit("cd", { urls[i] }) end
	end,
}
