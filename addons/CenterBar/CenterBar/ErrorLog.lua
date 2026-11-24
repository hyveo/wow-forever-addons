-- hyveo 애드온 오류 기록 — @hyveo
-- 센터바·레벨페이스·hyveo 애드온 센터에서 난 Lua 오류와 "기능 차단" 알림을 조용히 적어 두고,
-- 창에서 복사해 개발자에게 보낼 수 있게 한다. 게임 플레이에는 끼어들지 않는다.
--
-- 이 파일은 세 애드온에 똑같이 들어 있다 (고칠 때는 세 곳을 같이 고친다).
-- 먼저 읽힌 애드온이 기록을 맡고, 나중에 읽힌 애드온은 같은 기록을 함께 쓴다.
-- 기록에는 캐릭터·서버·계정 이름을 넣지 않는다.

local ADDON_NAME, ns = ...

local VERSION = 1
local MAX_ENTRIES = 30
local WATCH = { "CenterBar", "LevelPace", "HyveoCenter" }
-- 애드온마다 기록을 저장해 둘 곳 (로그아웃·리로드 때 파일로 남는다)
local SAVED = { CenterBar = "CenterBarGlobalDB", LevelPace = "LevelPaceDB", HyveoCenter = "HyveoCenterDB" }
local COMMAND = { CenterBar = "/cb errors", LevelPace = "/lp errors", HyveoCenter = "/hv errors" }

local isSecret = issecretvalue or function() return false end

---------------------------------------------------------------------------
-- 문자열 (창에 보이는 말만. 보고서 본문은 개발자가 읽으므로 영어로 고정)
---------------------------------------------------------------------------
local TEXT = {
	enUS = {
		TITLE  = "hyveo addons — error log",
		HINT   = "Press Ctrl+A, then Ctrl+C to copy, and send it to the developer.",
		FILE   = "It is also saved to a file when you log out or reload:",
		EMPTY  = "No errors recorded.",
		SELECT = "Select all",
		CLEAR  = "Clear log",
		BUTTON = "Error log",
		NOTICE = "An addon error was recorded. Type %s to see it.",
		HELP   = "error log",
	},
	koKR = {
		TITLE  = "hyveo 애드온 — 오류 기록",
		HINT   = "Ctrl+A를 누른 뒤 Ctrl+C로 복사해서 개발자에게 보내 주세요.",
		FILE   = "로그아웃하거나 리로드하면 아래 파일에도 저장돼요:",
		EMPTY  = "기록된 오류가 없어요.",
		SELECT = "전체 선택",
		CLEAR  = "기록 지우기",
		BUTTON = "오류 기록",
		NOTICE = "애드온 오류가 기록됐어요. %s 로 볼 수 있어요.",
		HELP   = "오류 기록",
	},
	deDE = {
		TITLE  = "hyveo-Addons — Fehlerprotokoll",
		HINT   = "Drücke Strg+A, dann Strg+C zum Kopieren, und sende es an den Entwickler.",
		FILE   = "Beim Ausloggen oder Neuladen wird es auch in eine Datei gespeichert:",
		EMPTY  = "Keine Fehler aufgezeichnet.",
		SELECT = "Alles auswählen",
		CLEAR  = "Protokoll leeren",
		BUTTON = "Fehlerprotokoll",
		NOTICE = "Ein Addon-Fehler wurde aufgezeichnet. Gib %s ein, um ihn zu sehen.",
		HELP   = "Fehlerprotokoll",
	},
	frFR = {
		TITLE  = "Addons hyveo — journal d'erreurs",
		HINT   = "Appuyez sur Ctrl+A, puis Ctrl+C pour copier, et envoyez-le au développeur.",
		FILE   = "Il est aussi enregistré dans un fichier à la déconnexion ou au rechargement :",
		EMPTY  = "Aucune erreur enregistrée.",
		SELECT = "Tout sélectionner",
		CLEAR  = "Vider le journal",
		BUTTON = "Journal d'erreurs",
		NOTICE = "Une erreur d'addon a été enregistrée. Tapez %s pour la voir.",
		HELP   = "journal d'erreurs",
	},
	esES = {
		TITLE  = "Addons de hyveo — registro de errores",
		HINT   = "Pulsa Ctrl+A y luego Ctrl+C para copiar, y envíalo al desarrollador.",
		FILE   = "También se guarda en un archivo al cerrar sesión o recargar:",
		EMPTY  = "No hay errores registrados.",
		SELECT = "Seleccionar todo",
		CLEAR  = "Borrar registro",
		BUTTON = "Registro de errores",
		NOTICE = "Se registró un error de addon. Escribe %s para verlo.",
		HELP   = "registro de errores",
	},
	ptBR = {
		TITLE  = "Addons da hyveo — registro de erros",
		HINT   = "Pressione Ctrl+A e depois Ctrl+C para copiar, e envie ao desenvolvedor.",
		FILE   = "Também é salvo em um arquivo ao sair ou recarregar:",
		EMPTY  = "Nenhum erro registrado.",
		SELECT = "Selecionar tudo",
		CLEAR  = "Limpar registro",
		BUTTON = "Registro de erros",
		NOTICE = "Um erro de addon foi registrado. Digite %s para ver.",
		HELP   = "registro de erros",
	},
	ruRU = {
		TITLE  = "Аддоны hyveo — журнал ошибок",
		HINT   = "Нажмите Ctrl+A, затем Ctrl+C, чтобы скопировать, и отправьте разработчику.",
		FILE   = "При выходе или перезагрузке он также сохраняется в файл:",
		EMPTY  = "Ошибок не записано.",
		SELECT = "Выделить всё",
		CLEAR  = "Очистить журнал",
		BUTTON = "Журнал ошибок",
		NOTICE = "Записана ошибка аддона. Введите %s, чтобы посмотреть.",
		HELP   = "журнал ошибок",
	},
	zhCN = {
		TITLE  = "hyveo 插件 — 错误记录",
		HINT   = "按 Ctrl+A，再按 Ctrl+C 复制，然后发给开发者。",
		FILE   = "登出或重载界面时也会保存到文件：",
		EMPTY  = "没有记录到错误。",
		SELECT = "全选",
		CLEAR  = "清空记录",
		BUTTON = "错误记录",
		NOTICE = "记录到一个插件错误。输入 %s 查看。",
		HELP   = "错误记录",
	},
	zhTW = {
		TITLE  = "hyveo 插件 — 錯誤記錄",
		HINT   = "按 Ctrl+A，再按 Ctrl+C 複製，然後傳給開發者。",
		FILE   = "登出或重新載入介面時也會儲存到檔案：",
		EMPTY  = "沒有記錄到錯誤。",
		SELECT = "全選",
		CLEAR  = "清空記錄",
		BUTTON = "錯誤記錄",
		NOTICE = "記錄到一個插件錯誤。輸入 %s 查看。",
		HELP   = "錯誤記錄",
	},
}
TEXT.esMX = TEXT.esES

---------------------------------------------------------------------------
-- 공용 기록 (세 애드온이 함께 쓰는 전역 표)
---------------------------------------------------------------------------
local log = _G.HyveoErrorLog
local fresh = not log
if fresh then
	log = { version = 0, entries = {}, hosts = {} }
	_G.HyveoErrorLog = log
end
log.hosts[ADDON_NAME] = ns
ns.ErrorLog = log

-- 창에 쓸 말: 이 애드온에서 고른 언어 → 게임 언어 → 영어
function ns.ErrorText(key)
	local code = ns.locale or (GetLocale and GetLocale()) or "enUS"
	local t = TEXT[code] or TEXT.enUS
	return t[key] or TEXT.enUS[key] or key
end

if (log.version or 0) < VERSION then
	log.version = VERSION

	local function Meta(addon, field)
		local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
		if not get then return nil end
		local ok, v = pcall(get, addon, field)
		if ok and type(v) == "string" and not isSecret(v) then return v end
	end

	local function Loaded(addon)
		local f = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
		if not f then return false end
		local ok, v = pcall(f, addon)
		return ok and v and true or false
	end

	local function Stamp()
		return date and date("%Y-%m-%d %H:%M") or "?"
	end

	-- 어느 애드온 것인지: 오류 문구나 호출 경로에 폴더 이름이 들어 있는지로 가린다
	local function WhichAddon(text)
		for _, name in ipairs(WATCH) do
			if text:find(name, 1, true) then return name end
		end
	end

	local noticed = false
	local busy = false

	-- kind: "error"(Lua 오류) / "blocked"(게임이 막은 동작)
	function log.Record(kind, msg, stack)
		if busy then return end
		busy = true
		pcall(function()
			if type(msg) ~= "string" or isSecret(msg) then return end
			if type(stack) ~= "string" or isSecret(stack) then stack = nil end
			-- 이 기록기 자신이 호출 경로에 끼어 있으면 남의 오류까지 우리 것으로 보이므로 그 줄은 뺀다
			if stack then stack = stack:gsub("[^\n]*ErrorLog%.lua[^\n]*\n?", "") end
			local addon = WhichAddon(msg) or (stack and WhichAddon(stack))
			if not addon then return end
			msg = msg:sub(1, 600)
			if stack then stack = stack:sub(1, 1500) end
			for _, e in ipairs(log.entries) do
				if e.msg == msg then
					e.count = (e.count or 1) + 1
					e.last = Stamp()
					return
				end
			end
			local combat = InCombatLockdown and InCombatLockdown() and true or false
			log.entries[#log.entries + 1] = {
				addon = addon, kind = kind, msg = msg, stack = stack,
				time = Stamp(), count = 1, combat = combat,
				ver = Meta(addon, "Version"),
			}
			while #log.entries > MAX_ENTRIES do table.remove(log.entries, 1) end
			if not noticed then
				noticed = true
				local host = log.hosts[addon] or ns
				local cmd = COMMAND[addon] or COMMAND[ADDON_NAME] or "/cb errors"
				local say = (host.ErrorText or ns.ErrorText)("NOTICE"):format("|cffffffff" .. cmd .. "|r")
				print("|cffffd100hyveo|r: " .. say)
			end
		end)
		busy = false
	end

	-- 저장돼 있던 기록을 합친다 (같은 문구는 한 번만)
	function log.Merge(saved)
		if type(saved) ~= "table" or saved == log.entries then return end
		local seen = {}
		for _, e in ipairs(log.entries) do seen[e.msg or ""] = true end
		for _, e in ipairs(saved) do
			if type(e) == "table" and type(e.msg) == "string" and not seen[e.msg] then
				seen[e.msg] = true
				log.entries[#log.entries + 1] = e
			end
		end
		table.sort(log.entries, function(a, b) return (a.time or "") < (b.time or "") end)
		while #log.entries > MAX_ENTRIES do table.remove(log.entries, 1) end
	end

	function log.Count() return #log.entries end

	function log.Clear()
		for i = #log.entries, 1, -1 do log.entries[i] = nil end
		if log.Refresh then log.Refresh() end
	end

	-- 개발자에게 보낼 보고서 본문 (영어 고정, 개인 정보 없음)
	function log.Report()
		local out = {}
		local function add(s) out[#out + 1] = s end
		local version, build, _, toc = "?", "?", nil, "?"
		if GetBuildInfo then version, build, _, toc = GetBuildInfo() end
		add("== hyveo addon error report ==")
		add(("Game: %s (build %s, interface %s), locale %s"):format(tostring(version), tostring(build), tostring(toc),
			tostring(GetLocale and GetLocale() or "?")))
		local list = {}
		for _, name in ipairs(WATCH) do
			list[#list + 1] = name .. " " .. (Loaded(name) and (Meta(name, "Version") or "?") or "(not loaded)")
		end
		add("Addons: " .. table.concat(list, ", "))
		add("Written: " .. Stamp())
		add("Entries: " .. #log.entries)
		for i, e in ipairs(log.entries) do
			add("")
			add(("[%d] %s %s | %s | %s | x%d%s%s"):format(i, tostring(e.addon), tostring(e.ver or "?"), tostring(e.kind),
				tostring(e.time), e.count or 1, e.combat and " | in combat" or "",
				(e.last and e.last ~= e.time) and (" | last " .. e.last) or ""))
			add(tostring(e.msg))
			if e.stack then add(e.stack) end
		end
		return table.concat(out, "\n")
	end

	-- 오류 받기: 게임의 오류 처리기 앞에 끼어들어 적기만 하고, 원래 처리기로 그대로 넘긴다
	if fresh and geterrorhandler and seterrorhandler then
		local previous = geterrorhandler()
		seterrorhandler(function(msg, ...)
			local ok, stack = pcall(debugstack, 3)
			if HyveoErrorLog and HyveoErrorLog.Record then
				HyveoErrorLog.Record("error", msg, ok and stack or nil)
			end
			if previous then return previous(msg, ...) end
		end)
	end

	local watcher = CreateFrame("Frame")
	watcher:RegisterEvent("PLAYER_LOGIN")
	pcall(watcher.RegisterEvent, watcher, "ADDON_ACTION_BLOCKED")
	pcall(watcher.RegisterEvent, watcher, "ADDON_ACTION_FORBIDDEN")
	watcher:SetScript("OnEvent", function(_, event, a1, a2)
		if event == "PLAYER_LOGIN" then
			-- 다른 오류 수집 애드온(BugGrabber)이 처리기를 가져갔으면 거기서 받아 온다
			local grabber = _G.BugGrabber
			if grabber and grabber.RegisterCallback then
				pcall(grabber.RegisterCallback, log, "BugGrabber_BugGrabbed", function(_, bug)
					if type(bug) == "table" then log.Record("error", bug.message, bug.stack) end
				end)
			end
		elseif type(a1) == "string" and not isSecret(a1) then
			for _, name in ipairs(WATCH) do
				if a1 == name then
					log.Record("blocked", name .. ": " .. event .. " " .. tostring((not isSecret(a2)) and a2 or "?"), nil)
				end
			end
		end
	end)

	---------------------------------------------------------------------------
	-- 창
	---------------------------------------------------------------------------
	local frame
	local function Build()
		local f = CreateFrame("Frame", "HyveoErrorLogFrame", UIParent, "BackdropTemplate")
		f:SetSize(600, 420)
		f:SetPoint("CENTER")
		f:SetFrameStrata("DIALOG")
		f:SetFrameLevel(200)
		f:SetClampedToScreen(true)
		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartMoving)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)
		if f.SetBackdrop then
			f:SetBackdrop({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				edgeSize = 16, tile = true, tileSize = 16,
				insets = { top = 4, bottom = 4, left = 4, right = 4 },
			})
			f:SetBackdropColor(0.05, 0.05, 0.05, 0.96)
		end
		tinsert(UISpecialFrames, "HyveoErrorLogFrame") -- Esc로 닫기

		f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		f.title:SetPoint("TOPLEFT", 16, -14)

		f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		f.hint:SetPoint("TOPLEFT", 16, -36)
		f.hint:SetPoint("RIGHT", -16, 0)
		f.hint:SetJustifyH("LEFT")

		f.file = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		f.file:SetPoint("BOTTOMLEFT", 16, 40)
		f.file:SetPoint("RIGHT", -16, 0)
		f.file:SetJustifyH("LEFT")

		local scroll = CreateFrame("ScrollFrame", nil, f)
		scroll:SetPoint("TOPLEFT", 16, -58)
		scroll:SetPoint("BOTTOMRIGHT", -16, 74)
		scroll:EnableMouseWheel(true)

		local edit = CreateFrame("EditBox", nil, scroll)
		edit:SetMultiLine(true)
		edit:SetAutoFocus(false)
		edit:SetFontObject(ChatFontNormal or GameFontHighlightSmall)
		edit:SetWidth(560)
		edit:SetScript("OnEscapePressed", function() f:Hide() end)
		scroll:SetScrollChild(edit)
		scroll:SetScript("OnMouseWheel", function(self, delta)
			local max = math.max(0, (edit:GetHeight() or 0) - (self:GetHeight() or 0))
			local to = math.min(max, math.max(0, (self:GetVerticalScroll() or 0) - delta * 40))
			self:SetVerticalScroll(to)
		end)
		scroll:SetScript("OnMouseDown", function() edit:SetFocus() end)
		f.edit, f.scroll = edit, scroll

		local function Button(x, width)
			local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
			b:SetSize(width, 22)
			b:SetPoint("BOTTOMLEFT", x, 12)
			return b
		end
		f.selectBtn = Button(16, 130)
		f.selectBtn:SetScript("OnClick", function()
			edit:SetFocus()
			edit:HighlightText()
		end)
		f.clearBtn = Button(152, 130)
		f.clearBtn:SetScript("OnClick", function() log.Clear() end)
		f.closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		f.closeBtn:SetSize(100, 22)
		f.closeBtn:SetPoint("BOTTOMRIGHT", -16, 12)
		f.closeBtn:SetText(CLOSE or "Close")
		f.closeBtn:SetScript("OnClick", function() f:Hide() end)
		f:Hide()
		return f
	end

	function log.Refresh()
		if not frame or not frame:IsShown() then return end
		local host = frame.host or ns
		local T = host.ErrorText or ns.ErrorText
		frame.title:SetText(T("TITLE"))
		frame.hint:SetText(T("HINT"))
		frame.selectBtn:SetText(T("SELECT"))
		frame.clearBtn:SetText(T("CLEAR"))
		local files = {}
		for _, name in ipairs(WATCH) do
			if Loaded(name) and log.hosts[name] then files[#files + 1] = name .. ".lua" end
		end
		frame.file:SetText(T("FILE") .. "\nWTF\\Account\\...\\SavedVariables\\" .. table.concat(files, ", "))
		frame.edit:SetText(#log.entries > 0 and log.Report() or T("EMPTY"))
		frame.edit:SetCursorPosition(0)
		frame.scroll:SetVerticalScroll(0)
	end

	-- host: 창을 연 애드온의 ns (그 애드온에서 고른 언어로 보여 준다)
	function log.Show(host)
		frame = frame or Build()
		frame.host = host or ns
		frame:Show()
		log.Refresh()
		if #log.entries > 0 then
			frame.edit:SetFocus()
			frame.edit:HighlightText()
		end
	end

	function log.Toggle(host)
		if frame and frame:IsShown() then frame:Hide() else log.Show(host) end
	end
end

---------------------------------------------------------------------------
-- 이 애드온의 저장 변수에 기록을 이어 붙인다
---------------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
	if name ~= ADDON_NAME then return end
	self:UnregisterEvent("ADDON_LOADED")
	local key = SAVED[ADDON_NAME]
	if not key then return end
	if type(_G[key]) ~= "table" then _G[key] = {} end
	log.Merge(_G[key].errors)
	_G[key].errors = log.entries -- 같은 표를 가리키게 해 두면 로그아웃 때 그대로 저장된다
end)

-- 이 애드온 언어로 창 열기
function ns.ShowErrorLog() log.Toggle(ns) end
