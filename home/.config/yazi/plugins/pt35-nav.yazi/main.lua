--- @sync entry
-- A, B et Y des boutons. enter : le smart-enter de yazi-rs/plugins (MIT), un
-- dossier s'ouvre dans yazi. back : Échap annule d'abord, sinon remonte.
-- tab : onglet suivant, ou un deuxième ici s'il n'y en a qu'un.
return {
	entry = function(_, job)
		local tab = cx.active
		if job.args[1] == "tab" then
			if #cx.tabs > 1 then
				ya.emit("tab_switch", { 1, relative = true })
			else
				ya.emit("tab_create", { current = true })
			end
		elseif job.args[1] == "enter" then
			local h = tab.current.hovered
			ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
		elseif not tab.mode.is_normal or #tab.selected > 0 or tab.finder
			or tab.current.files.filter or tab.current.cwd.spec.is_search then
			ya.emit("escape", {})
		else
			ya.emit("leave", {})
		end
	end,
}
