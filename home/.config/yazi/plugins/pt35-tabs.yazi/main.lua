-- Y des boutons : la liste des onglets. Y encore = nouvel onglet ici,
-- 1 à 9 = aller à cet onglet. L'onglet courant est marqué par un mot.
local tabs = ya.sync(function()
	local list = {}
	for i = 1, #cx.tabs do
		list[i] = ya.readable_path(tostring(cx.tabs[i].current.cwd))
			.. (i == cx.tabs.idx and "  (here)" or "")
	end
	return list
end)

return {
	entry = function()
		local cands = { { on = "<F10>", desc = "New tab here" } }
		for i, path in ipairs(tabs()) do
			if i > 9 then break end
			cands[#cands + 1] = { on = tostring(i), desc = path }
		end
		local i = ya.which { cands = cands }
		if i == 1 then
			ya.emit("tab_create", { current = true })
		elseif i then
			ya.emit("tab_switch", { i - 2 })
		end
	end,
}
