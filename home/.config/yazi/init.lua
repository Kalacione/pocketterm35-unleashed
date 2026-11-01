-- Phosphore : les icônes prennent la couleur de leur ligne, sans teinte par type.
function Entity:icon()
	local icon = th.icon:match(self._file, { hovered = self._file.is_hovered })
	return icon and icon.text .. " " or ""
end

-- Le compteur dit ce qu'il compte (SEL, COPY, CUT) : la couleur n'est qu'un appui.
function Header:count()
	local selected, yanked = #self._tab.selected, #cx.yanked
	local text, style
	if selected > 0 then
		text, style = selected .. " SEL", th.mgr.count_selected
	elseif yanked == 0 then
		return ""
	elseif cx.yanked.is_cut then
		text, style = yanked .. " CUT", th.mgr.count_cut
	else
		text, style = yanked .. " COPY", th.mgr.count_copied
	end
	return ui.Line { ui.Span(" " .. text .. " "):style(style), " " }
end
