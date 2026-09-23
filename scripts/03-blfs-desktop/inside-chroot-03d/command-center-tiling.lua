-- Command Center — window-tiling-regels voor devilspie2.
--
-- Indeling (Brionize, 2026-09-23):
--   Werkblad 1 (Command Center): n8n-canvas + Conky-HUD + terminal-logs
--   Werkblad 2 (AI Matrix):      Claude/ChatGPT/Mistral/Gemini in een 2x2-grid
--   Werkblad 3 (Dev Studio):     Supabase Studio + GitHub-terminal
--
-- Conky zelf wordt hier NIET gematcht/getegeld — Conky's eigen
-- own_window-instellingen (own_window_hints =
-- 'undecorated,sticky,below,skip_taskbar,skip_pager', zie
-- conky-command-center.conf) regelen dat het altijd zichtbaar blijft
-- als HUD-overlay, op elk werkblad, zonder devilspie2 nodig te hebben.
--
-- BELANGRIJKE KANTTEKENING (evidence before done): de daadwerkelijke
-- apps hierin (n8n, de AI-webapps, Supabase Studio, de twee terminals)
-- bestaan nog niet op dit image — dat is fase 4 (devstack + PWA-
-- snelkoppelingen). Deze regels zijn dus vooruitlopend geschreven en
-- matchen op de raamtitel (get_window_name()) via bekende product-
-- namen. Ze zijn NIET functioneel te testen zonder een live X-sessie
-- met die apps daadwerkelijk open (kan niet in GitHub Actions) — wél
-- met `luac -p` op Lua-syntax gecontroleerd tijdens het bouwen (zie
-- 07-devilspie2-tiling-rules.sh). Zodra fase 4 de browser/PWA's en
-- terminals daadwerkelijk opzet, moeten de titelpatronen hieronder
-- geverifieerd/bijgesteld worden tegen de echte vensters.
--
-- De twee terminals hebben GEEN generieke titel (elke terminal heet
-- anders per emulator) — deze moeten in fase 4 expliciet gestart
-- worden met een titel die hier matcht, bv.:
--   xfce4-terminal --title="Command-Center-Logs" -e "tail -f ..."
--   xfce4-terminal --title="Command-Center-GitHub" -e "bash"

local screen_w, screen_h = get_screen_geometry()

local wide_w = math.floor(screen_w * 0.65)
local narrow_w = screen_w - wide_w
local half_w = math.floor(screen_w / 2)
local half_h = math.floor(screen_h / 2)

local name = get_window_name()

-- Werkblad 1 — Command Center
if string.find(name, "n8n", 1, true) then
	set_window_workspace(1)
	set_window_geometry2(0, 0, wide_w, screen_h)
elseif string.find(name, "Command-Center-Logs", 1, true) then
	set_window_workspace(1)
	set_window_geometry2(wide_w, 0, narrow_w, screen_h)

-- Werkblad 2 — AI Matrix (2x2-grid)
elseif string.find(name, "Claude", 1, true) then
	set_window_workspace(2)
	set_window_geometry2(0, 0, half_w, half_h)
elseif string.find(name, "ChatGPT", 1, true) then
	set_window_workspace(2)
	set_window_geometry2(half_w, 0, half_w, half_h)
elseif string.find(name, "Mistral", 1, true) then
	set_window_workspace(2)
	set_window_geometry2(0, half_h, half_w, half_h)
elseif string.find(name, "Gemini", 1, true) then
	set_window_workspace(2)
	set_window_geometry2(half_w, half_h, half_w, half_h)

-- Werkblad 3 — Dev Studio
elseif string.find(name, "Supabase", 1, true) then
	set_window_workspace(3)
	set_window_geometry2(0, 0, wide_w, screen_h)
elseif string.find(name, "Command-Center-GitHub", 1, true) then
	set_window_workspace(3)
	set_window_geometry2(wide_w, 0, narrow_w, screen_h)
end
