-- hyveo 애드온 센터 (HyveoCenter) — 와우 포에버
-- hyveo가 만든 애드온을 한 창에서 켜고 끄고, 열고, 자주 쓰는 설정을 바꾼다.
-- 만든 사람: @hyveo  /  https://github.com/hyveo/wow-forever-addons

local ADDON_NAME, ns = ...
local REPO_URL   = "https://github.com/hyveo/wow-forever-addons"
local ISSUE_URL  = REPO_URL .. "/issues"

---------------------------------------------------------------------------
-- 문자열
---------------------------------------------------------------------------
local L = ns.L -- 문자열은 Locales.lua (언어를 바꾸면 이 표의 내용이 바뀜)

local function Print(msg)
	print("|cffffd100" .. L.TITLE .. "|r: " .. msg)
end

---------------------------------------------------------------------------
-- 애드온 목록 API (C_AddOns가 없으면 옛 전역 함수 사용)
---------------------------------------------------------------------------
local A = C_AddOns or {}
local GetAddOnInfoX      = A.GetAddOnInfo or GetAddOnInfo
local IsAddOnLoadedX     = A.IsAddOnLoaded or IsAddOnLoaded
local GetMetadataX       = A.GetAddOnMetadata or GetAddOnMetadata
local EnableAddOnX       = A.EnableAddOn or EnableAddOn
local DisableAddOnX      = A.DisableAddOn or DisableAddOn
local GetEnableStateX    = A.GetAddOnEnableState or GetAddOnEnableState

local function PlayerName()
	return UnitName("player")
end

local function IsInstalled(folder)
	local ok, name, _, _, _, reason = pcall(GetAddOnInfoX, folder)
	if not ok or not name then return false end
	return reason ~= "MISSING"
end

local function IsEnabled(folder)
	if not GetEnableStateX then return true end
	local ok, state = pcall(GetEnableStateX, folder, PlayerName())
	if not ok then
		ok, state = pcall(GetEnableStateX, PlayerName(), folder) -- 옛 순서
	end
	return ok and state and state > 0
end

local function IsLoaded(folder)
	return IsAddOnLoadedX and IsAddOnLoadedX(folder) and true or false
end

local function Version(folder)
	local v = GetMetadataX and GetMetadataX(folder, "Version")
	if not v or v == "" or v:find("@") then return "-" end
	return v
end

---------------------------------------------------------------------------
-- 관리할 애드온
---------------------------------------------------------------------------
local needReload = false

local ADDONS = {
	{
		folder = "LevelPace",
		keys   = { "lp", "levelpace", "레벨", "레벨페이스" },
		extra  = {},
		name   = L.LP_NAME,
		desc   = L.LP_DESC,
		cmd    = "/lp",
		icon   = "Interface\\AddOns\\LevelPace\\icon",
		open   = function()
			if LevelPace and LevelPace.ToggleWindow then LevelPace.ToggleWindow()
			elseif SlashCmdList.LEVELPACE then SlashCmdList.LEVELPACE("") end
		end,
		options = {
			{
				label = L.LP_BAR,
				get = function() return LevelPace and LevelPace.IsBarShown() end,
				set = function(v) if LevelPace then LevelPace.SetBarShown(v) end end,
			},
			{
				label = L.LP_LOCK,
				get = function() return LevelPace and LevelPace.IsBarLocked() end,
				set = function(v) if LevelPace then LevelPace.SetBarLocked(v) end end,
			},
		},
	},
	{
		folder = "CenterBar",
		keys   = { "cb", "centerbar", "센터", "센터바" },
		extra  = {},
		name   = L.CB_NAME,
		desc   = L.CB_DESC,
		cmd    = "/cb",
		icon   = "Interface\\AddOns\\CenterBar\\icon",
		open   = function()
			if CenterBar and CenterBar.ToggleOptions then CenterBar.ToggleOptions()
			elseif SlashCmdList.CENTERBAR then SlashCmdList.CENTERBAR("") end
		end,
		options = {
			{
				label = L.CB_COMBAT,
				get = function() return CenterBar and CenterBar.IsCombatOnly() end,
				set = function(v) if CenterBar then CenterBar.Set("visibility", v and "combat" or "always") end end,
			},
			{
				label = L.CB_MOUSE,
				get = function() return CenterBar and CenterBar.IsMouseoverOnly() end,
				set = function(v) if CenterBar then CenterBar.Set("visibility", v and "mouseover" or "always") end end,
			},
		},
	},
}

local function Status(a)
	if not IsInstalled(a.folder) then return L.MISSING, 0.6, 0.6, 0.6 end
	local enabled, loaded = IsEnabled(a.folder), IsLoaded(a.folder)
	if enabled and loaded then return L.ON .. " · " .. Version(a.folder), 0.25, 0.73, 0.31 end
	if enabled and not loaded then return L.ON_AFTER, 1, 0.82, 0 end
	if not enabled and loaded then return L.OFF_AFTER, 1, 0.82, 0 end
	return L.OFF, 0.62, 0.62, 0.62
end

local function SetEnabled(a, on)
	local fn = on and EnableAddOnX or DisableAddOnX
	if not fn then return end
	local folders = { a.folder }
	for _, f in ipairs(a.extra) do folders[#folders + 1] = f end
	for _, f in ipairs(folders) do
		if IsInstalled(f) then pcall(fn, f, PlayerName()) end
	end
	needReload = true
end

---------------------------------------------------------------------------
-- 주소 복사 창
---------------------------------------------------------------------------
StaticPopupDialogs["HYVEOCENTER_COPY"] = {
	text = "%s",
	button1 = CLOSE or "닫기",
	hasEditBox = true,
	editBoxWidth = 340,
	OnShow = function(self, data)
		local eb = (self.GetEditBox and self:GetEditBox()) or self.editBox or self.EditBox
		if eb then
			eb:SetText(data or "")
			eb:HighlightText()
			eb:SetFocus()
		end
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local function ShowCopy(url)
	StaticPopup_Show("HYVEOCENTER_COPY", L.COPY_TITLE, nil, url)
end

---------------------------------------------------------------------------
-- 창
---------------------------------------------------------------------------
local selected = 1
local Refresh

local f = CreateFrame("Frame", "HyveoCenterFrame", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(660, 440)
f:SetPoint("CENTER")
f:SetFrameStrata("DIALOG")
f:SetClampedToScreen(true)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()
tinsert(UISpecialFrames, "HyveoCenterFrame") -- Esc로 닫기

f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.title:SetPoint("TOP", 0, -6)
f.title:SetText(L.TITLE)

-- 왼쪽 목록
local list = CreateFrame("Frame", nil, f, "BackdropTemplate")
list:SetPoint("TOPLEFT", 12, -32)
list:SetPoint("BOTTOMLEFT", 12, 12)
list:SetWidth(210)
list:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
list:SetBackdropColor(0, 0, 0, 0.35)
list:SetBackdropBorderColor(0.18, 0.16, 0.13, 1)

local rows = {}
for i, a in ipairs(ADDONS) do
	local b = CreateFrame("Button", nil, list, "BackdropTemplate")
	b:SetSize(194, 52)
	b:SetPoint("TOPLEFT", 8, -8 - (i - 1) * 58)
	b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetSize(36, 36)
	b.icon:SetPoint("LEFT", 8, 0)
	b.icon:SetTexture(a.icon)
	b.name = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	b.name:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", 10, -1)
	b.name:SetText(a.name)
	b.status = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	b.status:SetPoint("TOPLEFT", b.name, "BOTTOMLEFT", 0, -4)
	b:SetScript("OnClick", function()
		selected = i
		Refresh()
	end)
	rows[i] = b
end

list.note = list:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
list.note:SetPoint("BOTTOMLEFT", 10, 10)
list.note:SetPoint("RIGHT", -10, 0)
list.note:SetJustifyH("LEFT")
list.note:SetText(L.SIDE_NOTE)

-- 언어: 여기서 고른 언어를 센터바·레벨페이스도 따라간다 (HyveoCenter_GetLanguage).
-- 바꾸면 UI를 다시 불러와야 적용된다.
local function CurrentLang() return (HyveoCenterDB and HyveoCenterDB.lang) or "auto" end
local function LangLabel(code)
	if code == "auto" then return L.LANG_AUTO:format(ns.GameLocale()) end
	return ns.LANG_NAMES[code] or code
end

StaticPopupDialogs["HYVEOCENTER_LANGUAGE"] = {
	text = "%s",
	button1 = L.RELOAD_NOW,
	button2 = L.LATER,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

list.langLabel = list:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
list.langLabel:SetPoint("TOPLEFT", 10, -8 - #ADDONS * 58 - 10)
list.langLabel:SetPoint("RIGHT", -10, 0)
list.langLabel:SetJustifyH("LEFT")

local langBtn = CreateFrame("Button", nil, list, "UIPanelButtonTemplate")
langBtn:SetSize(194, 22)
langBtn:SetPoint("TOPLEFT", list.langLabel, "BOTTOMLEFT", -2, -4)

local langList = CreateFrame("Frame", nil, langBtn, "BackdropTemplate")
langList:SetFrameStrata("FULLSCREEN_DIALOG")
langList:SetClampedToScreen(true)
langList:SetPoint("TOPLEFT", langBtn, "BOTTOMLEFT", 0, -2)
langList:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
langList:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
langList:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
langList:EnableMouse(true)
langList:Hide()

local langCodes = { "auto" }
for _, c in ipairs(ns.LANGS) do langCodes[#langCodes + 1] = c end
local langRows = {}
local LROW = 20
for i, code in ipairs(langCodes) do
	local r = CreateFrame("Button", nil, langList)
	r:SetSize(220, LROW)
	r:SetPoint("TOPLEFT", 4, -4 - (i - 1) * LROW - (i > 1 and 6 or 0))
	r.hl = r:CreateTexture(nil, "HIGHLIGHT")
	r.hl:SetAllPoints()
	r.hl:SetColorTexture(1, 0.82, 0, 0.15)
	r.check = r:CreateTexture(nil, "OVERLAY") -- 지금 고른 언어 표시
	r.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	r.check:SetSize(16, 16)
	r.check:SetPoint("LEFT", 4, 0)
	r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	r.text:SetPoint("LEFT", 24, 0)
	r:SetScript("OnClick", function()
		langList:Hide()
		if code == CurrentLang() then return end
		HyveoCenterDB = HyveoCenterDB or {}
		HyveoCenterDB.lang = (code ~= "auto") and code or nil
		langBtn:SetText(LangLabel(code))
		StaticPopup_Show("HYVEOCENTER_LANGUAGE", L.LANG_ASK:format(LangLabel(code)) .. "\n" .. L.LANG_RELOAD)
	end)
	langRows[i] = r
end
local langSep = langList:CreateTexture(nil, "ARTWORK") -- 자동과 언어 목록 사이 구분선
langSep:SetColorTexture(0.6, 0.5, 0.3, 0.6)
langSep:SetHeight(1)
langSep:SetPoint("TOPLEFT", 8, -4 - LROW - 3)
langSep:SetPoint("TOPRIGHT", -8, -4 - LROW - 3)
langList:SetSize(228, 8 + #langCodes * LROW + 6)
langBtn:SetScript("OnClick", function() langList:SetShown(not langList:IsShown()) end)

local function RefreshLang()
	local cur = CurrentLang()
	langBtn:SetText(LangLabel(cur))
	for i, code in ipairs(langCodes) do
		langRows[i].text:SetText(LangLabel(code))
		langRows[i].check:SetShown(code == cur)
	end
end

-- 오른쪽 상세
local d = CreateFrame("Frame", nil, f, "BackdropTemplate")
d:SetPoint("TOPLEFT", list, "TOPRIGHT", 10, 0)
d:SetPoint("BOTTOMRIGHT", -12, 12)
d:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
d:SetBackdropColor(0, 0, 0, 0.35)
d:SetBackdropBorderColor(0.18, 0.16, 0.13, 1)

d.icon = d:CreateTexture(nil, "ARTWORK")
d.icon:SetSize(56, 56)
d.icon:SetPoint("TOPLEFT", 16, -16)

d.name = d:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
d.name:SetPoint("TOPLEFT", d.icon, "TOPRIGHT", 12, -6)

d.sub = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
d.sub:SetPoint("TOPLEFT", d.name, "BOTTOMLEFT", 0, -6)

d.openBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
d.openBtn:SetSize(84, 24)
d.openBtn:SetPoint("TOPRIGHT", -16, -20)
d.openBtn:SetText(L.BTN_OPEN)
d.openBtn:SetScript("OnClick", function()
	local a = ADDONS[selected]
	if a and IsLoaded(a.folder) then a.open() end
end)

d.toggleBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
d.toggleBtn:SetSize(70, 24)
d.toggleBtn:SetPoint("RIGHT", d.openBtn, "LEFT", -6, 0)
d.toggleBtn:SetScript("OnClick", function()
	local a = ADDONS[selected]
	if a then
		SetEnabled(a, not IsEnabled(a.folder))
		Refresh()
	end
end)

d.linkBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
d.linkBtn:SetSize(150, 24)
d.linkBtn:SetPoint("TOPRIGHT", -16, -20)
d.linkBtn:SetText(L.BTN_GETLINK)
d.linkBtn:SetScript("OnClick", function()
	local a = ADDONS[selected]
	ShowCopy(REPO_URL .. "/tree/main/addons/" .. (a and a.folder or ""))
end)

d.desc = d:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
d.desc:SetPoint("TOPLEFT", d.icon, "BOTTOMLEFT", 0, -14)
d.desc:SetPoint("RIGHT", -16, 0)
d.desc:SetJustifyH("LEFT")
d.desc:SetSpacing(3)

-- 다시 불러오기 안내
d.reload = CreateFrame("Frame", nil, d, "BackdropTemplate")
d.reload:SetHeight(34)
d.reload:SetPoint("TOPLEFT", d.desc, "BOTTOMLEFT", 0, -12)
d.reload:SetPoint("RIGHT", -16, 0)
d.reload:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
d.reload:SetBackdropColor(1, 0.82, 0, 0.12)
d.reload:SetBackdropBorderColor(1, 0.82, 0, 0.45)
d.reload.text = d.reload:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
d.reload.text:SetPoint("LEFT", 10, 0)
d.reload.text:SetText(L.RELOAD_MSG)
d.reload.btn = CreateFrame("Button", nil, d.reload, "UIPanelButtonTemplate")
d.reload.btn:SetSize(130, 22)
d.reload.btn:SetPoint("RIGHT", -6, 0)
d.reload.btn:SetText(L.BTN_RELOAD)
d.reload.btn:SetScript("OnClick", function() ReloadUI() end)
d.reload:Hide()

-- 빠른 설정
d.quick = d:CreateFontString(nil, "OVERLAY", "GameFontNormal")
d.quick:SetText(L.QUICK)

d.quickNone = d:CreateFontString(nil, "OVERLAY", "GameFontDisable")
d.quickNone:SetPoint("TOPLEFT", d.quick, "BOTTOMLEFT", 0, -10)
d.quickNone:SetText(L.QUICK_NONE)

local checks = {}
for i = 1, 4 do
	local c = CreateFrame("CheckButton", nil, d, "UICheckButtonTemplate")
	c:SetSize(26, 26)
	c:SetPoint("TOPLEFT", d.quick, "BOTTOMLEFT", -4, -6 - (i - 1) * 28)
	c.label = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	c.label:SetPoint("LEFT", c, "RIGHT", 4, 1)
	c:SetScript("OnClick", function(self)
		if self.opt then self.opt.set(self:GetChecked() and true or false) end
		Refresh()
	end)
	c:Hide()
	checks[i] = c
end

-- 아래쪽
d.footer = d:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
d.footer:SetPoint("BOTTOMLEFT", 16, 16)
d.footer:SetText(L.FOOTER)

d.bugBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
d.bugBtn:SetSize(140, 22)
d.bugBtn:SetPoint("BOTTOMRIGHT", -12, 10)
d.bugBtn:SetText(L.BTN_BUG)
d.bugBtn:SetScript("OnClick", function() ShowCopy(ISSUE_URL) end)

-- 오류 기록 창 (세 애드온의 오류를 한곳에서 보고 복사)
d.errBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
d.errBtn:SetSize(110, 22)
d.errBtn:SetPoint("RIGHT", d.bugBtn, "LEFT", -6, 0)
d.errBtn:SetText(ns.ErrorText("BUTTON"))
d.errBtn:SetScript("OnClick", function() ns.ShowErrorLog() end)

-- 언어를 바꾼 뒤(접속 시 저장된 언어 적용) 미리 만들어 둔 글자를 다시 쓴다
local function ApplyTexts()
	local texts = {
		{ ADDONS[1], "LP_NAME", "LP_DESC", "LP_BAR", "LP_LOCK" },
		{ ADDONS[2], "CB_NAME", "CB_DESC", "CB_COMBAT", "CB_MOUSE" },
	}
	for _, t in ipairs(texts) do
		local a = t[1]
		a.name, a.desc = L[t[2]], L[t[3]]
		a.options[1].label, a.options[2].label = L[t[4]], L[t[5]]
	end
	for i, a in ipairs(ADDONS) do rows[i].name:SetText(a.name) end
	f.title:SetText(L.TITLE)
	list.note:SetText(L.SIDE_NOTE)
	list.langLabel:SetText(L.LANG)
	d.openBtn:SetText(L.BTN_OPEN)
	d.linkBtn:SetText(L.BTN_GETLINK)
	d.reload.text:SetText(L.RELOAD_MSG)
	d.reload.btn:SetText(L.BTN_RELOAD)
	d.quick:SetText(L.QUICK)
	d.quickNone:SetText(L.QUICK_NONE)
	d.footer:SetText(L.FOOTER)
	d.bugBtn:SetText(L.BTN_BUG)
	d.errBtn:SetText(ns.ErrorText("BUTTON"))
	StaticPopupDialogs["HYVEOCENTER_LANGUAGE"].button1 = L.RELOAD_NOW
	StaticPopupDialogs["HYVEOCENTER_LANGUAGE"].button2 = L.LATER
	RefreshLang()
end
ApplyTexts()

Refresh = function()
	for i, a in ipairs(ADDONS) do
		local b = rows[i]
		local text, r, g, bl = Status(a)
		b.status:SetText(text)
		b.status:SetTextColor(r, g, bl)
		if i == selected then
			b:SetBackdropColor(1, 0.82, 0, 0.12)
			b:SetBackdropBorderColor(1, 0.82, 0, 0.9)
		else
			b:SetBackdropColor(1, 1, 1, 0.03)
			b:SetBackdropBorderColor(1, 1, 1, 0.08)
		end
	end

	local a = ADDONS[selected]
	local installed = IsInstalled(a.folder)
	local enabled, loaded = IsEnabled(a.folder), IsLoaded(a.folder)

	d.icon:SetTexture(a.icon)
	d.name:SetText(a.name)
	d.sub:SetText(installed and (L.VERSION:format(Version(a.folder)) .. "  ·  " .. a.cmd) or L.MISSING)
	d.desc:SetText(installed and a.desc or (a.desc .. "\n\n" .. L.MISSING_DESC))

	d.openBtn:SetShown(installed)
	d.openBtn:SetEnabled(loaded)
	d.toggleBtn:SetShown(installed)
	d.toggleBtn:SetText(enabled and L.BTN_DISABLE or L.BTN_ENABLE)
	d.linkBtn:SetShown(not installed)

	d.reload:SetShown(needReload)
	d.quick:ClearAllPoints()
	if needReload then
		d.quick:SetPoint("TOPLEFT", d.reload, "BOTTOMLEFT", 0, -16)
	else
		d.quick:SetPoint("TOPLEFT", d.desc, "BOTTOMLEFT", 0, -18)
	end

	local canSet = installed and loaded
	d.quick:SetShown(installed)
	d.quickNone:SetShown(installed and not canSet)
	for i, c in ipairs(checks) do
		local opt = canSet and a.options[i] or nil
		c.opt = opt
		if opt then
			c.label:SetText(opt.label)
			c:SetChecked(opt.get() and true or false)
			c:Show()
		else
			c:Hide()
		end
	end
end

f:SetScript("OnShow", function() RefreshLang() Refresh() end)
f:HookScript("OnHide", function() langList:Hide() end)

local function Toggle()
	if f:IsShown() then f:Hide() else f:Show() end
end

---------------------------------------------------------------------------
-- 여는 곳: 명령어, 미니맵 옆 애드온 메뉴, 게임 설정 > 애드온
---------------------------------------------------------------------------
SLASH_HYVEOCENTER1 = "/hv"
SLASH_HYVEOCENTER2 = "/hyveo"
SLASH_HYVEOCENTER3 = "/하이브"
SLASH_HYVEOCENTER4 = "/애드온센터"
local function PrintHelp()
	Print(L.HELP_HEAD)
	print("  " .. L.HELP_CENTER)
	for _, a in ipairs(ADDONS) do
		print("  " .. L.HELP_LINE:format(a.keys[1], a.name, a.cmd))
	end
	print("  /hv errors — " .. ns.ErrorText("HELP"))
	print("  " .. L.HELP_HELP)
end

local function FindAddon(key)
	for i, a in ipairs(ADDONS) do
		for _, k in ipairs(a.keys) do
			if k == key then return a, i end
		end
	end
end

SlashCmdList.HYVEOCENTER = function(msg)
	msg = strlower(strtrim(msg or ""))
	if msg == "" then
		Toggle()
	elseif msg == "help" or msg == "도움말" or msg == "?" then
		PrintHelp()
	elseif msg == "minimap" or msg == "미니맵" then
		HyveoCenter_ToggleMinimapButton()
	elseif msg == "errors" or msg == "error" or msg == "오류" then
		ns.ShowErrorLog()
	else
		local a, i = FindAddon(msg)
		if not a then
			Print(L.UNKNOWN:format(msg))
		elseif IsLoaded(a.folder) then
			selected = i
			a.open()
		else
			Print(L.NOT_READY:format(a.name))
		end
	end
end

-- TOC의 AddonCompartmentFunc에서 부른다
function HyveoCenter_OnAddonCompartmentClick()
	Toggle()
end

function HyveoCenter_OnAddonCompartmentEnter(_, button)
	GameTooltip:SetOwner(button or UIParent, "ANCHOR_LEFT")
	GameTooltip:AddLine(L.TITLE)
	GameTooltip:AddLine(L.FOOTER, 1, 1, 1)
	GameTooltip:Show()
end

function HyveoCenter_OnAddonCompartmentLeave()
	GameTooltip:Hide()
end

local function RegisterSettingsPanel()
	if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
	local panel = CreateFrame("Frame")
	panel.name = L.TITLE
	local t = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	t:SetPoint("TOPLEFT", 16, -16)
	t:SetText(L.TITLE)
	local s = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	s:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -8)
	s:SetText(L.PANEL_DESC)
	local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	b:SetSize(140, 26)
	b:SetPoint("TOPLEFT", s, "BOTTOMLEFT", 0, -14)
	b:SetText(L.OPEN_CENTER)
	b:SetScript("OnClick", function()
		if SettingsPanel and SettingsPanel:IsShown() then pcall(HideUIPanel, SettingsPanel) end
		f:Show()
	end)
	local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, panel, L.TITLE)
	if ok and cat then pcall(Settings.RegisterAddOnCategory, cat) end
end

---------------------------------------------------------------------------
-- 미니맵 버튼: 클릭 = 센터 열기, 드래그 = 미니맵 둘레를 따라 옮기기, /hv minimap = 보이기/숨기기
---------------------------------------------------------------------------
local mm = CreateFrame("Button", "HyveoCenterMinimapButton", Minimap)
mm:SetSize(31, 31)
mm:SetFrameStrata("MEDIUM")
mm:SetFrameLevel(8)
mm:RegisterForClicks("LeftButtonUp", "RightButtonUp")
mm:RegisterForDrag("LeftButton")
mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
mm.bg = mm:CreateTexture(nil, "BACKGROUND")
mm.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
mm.bg:SetSize(20, 20)
mm.bg:SetPoint("TOPLEFT", 7, -5)
mm.icon = mm:CreateTexture(nil, "ARTWORK")
mm.icon:SetTexture("Interface\\AddOns\\HyveoCenter\\icon")
mm.icon:SetSize(18, 18)
mm.icon:SetPoint("TOPLEFT", 7, -6)
mm.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
mm.border = mm:CreateTexture(nil, "OVERLAY")
mm.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
mm.border:SetSize(53, 53)
mm.border:SetPoint("TOPLEFT")
mm:Hide()

local function UpdateMinimap()
	local db = HyveoCenterDB
	if not db then return end
	mm:SetShown(not db.minimapHide)
	local a = math.rad(db.minimapAngle or 190)
	local r = (Minimap:GetWidth() or 140) / 2 + 5
	mm:ClearAllPoints()
	mm:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
end

mm:SetScript("OnClick", function() Toggle() end)
mm:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", function()
		local mx, my = Minimap:GetCenter()
		local cx, cy = GetCursorPosition()
		local s = Minimap:GetEffectiveScale()
		if not mx or not s or s == 0 or not HyveoCenterDB then return end
		HyveoCenterDB.minimapAngle = math.deg(math.atan2(cy / s - my, cx / s - mx))
		UpdateMinimap()
	end)
end)
mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
mm:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine(L.TITLE)
	GameTooltip:AddLine(L.MM_CLICK, 1, 1, 1)
	GameTooltip:AddLine(L.MM_DRAG, 1, 1, 1)
	GameTooltip:AddLine(L.MM_HIDE, 0.6, 0.6, 0.6)
	GameTooltip:Show()
end)
mm:SetScript("OnLeave", function() GameTooltip:Hide() end)

function HyveoCenter_ToggleMinimapButton()
	HyveoCenterDB = HyveoCenterDB or {}
	HyveoCenterDB.minimapHide = not HyveoCenterDB.minimapHide
	UpdateMinimap()
end

-- 다른 hyveo 애드온(센터바, 레벨페이스)이 접속할 때(PLAYER_LOGIN) 불러서 같은 언어를 쓴다.
-- 돌려주는 값: 언어 코드(예: "deDE") 또는 nil(= 게임 언어)
function HyveoCenter_GetLanguage()
	return HyveoCenterDB and HyveoCenterDB.lang or nil
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(_, _, name)
	if name == ADDON_NAME then
		HyveoCenterDB = HyveoCenterDB or {}
		if HyveoCenterDB.lang then
			ns.ApplyLocale(HyveoCenterDB.lang)
			ApplyTexts()
		end
		UpdateMinimap()
		RegisterSettingsPanel()
		ev:UnregisterEvent("ADDON_LOADED")
	end
end)
