-- hyveo 애드온 센터 (HyveoCenter) — 와우 포에버
-- hyveo가 만든 애드온을 한 창에서 켜고 끄고, 열고, 자주 쓰는 설정을 바꾼다.
-- 만든 사람: @hyveo  /  https://github.com/hyveo/wow-forever-addons

local ADDON_NAME = ...
local REPO_URL   = "https://github.com/hyveo/wow-forever-addons"
local ISSUE_URL  = REPO_URL .. "/issues"

---------------------------------------------------------------------------
-- 문자열
---------------------------------------------------------------------------
local L
if GetLocale() == "koKR" then
	L = {
		TITLE         = "hyveo 애드온 센터",
		VERSION       = "버전 %s",
		ON            = "켜짐",
		OFF           = "꺼짐",
		ON_AFTER      = "다시 불러오면 켜짐",
		OFF_AFTER     = "다시 불러오면 꺼짐",
		MISSING       = "설치 안 됨",
		BTN_OPEN      = "창 열기",
		BTN_ENABLE    = "켜기",
		BTN_DISABLE   = "끄기",
		BTN_GETLINK   = "받는 곳 주소 복사",
		BTN_RELOAD    = "지금 다시 불러오기",
		BTN_BUG       = "버그 제보 주소 복사",
		RELOAD_MSG    = "바꾼 설정은 UI를 다시 불러와야 적용돼요.",
		QUICK         = "빠른 설정",
		QUICK_NONE    = "애드온이 켜져 있을 때 설정할 수 있어요.",
		FOOTER        = "/hv 로도 열 수 있어요",
		COPY_TITLE    = "Ctrl+C로 복사하세요",
		SIDE_NOTE     = "새 애드온 소식과 요청은\nGitHub: hyveo/wow-forever-addons",
		OPEN_CENTER   = "센터 열기",
		PANEL_DESC    = "hyveo가 만든 애드온을 한 창에서 관리해요.",
		MISSING_DESC  = "이 애드온은 아직 설치되지 않았어요. CurseForge 앱이나 GitHub에서 받을 수 있어요.",
		HELP_HEAD     = "명령어 목록",
		HELP_CENTER   = "/hv — 센터 열기/닫기",
		HELP_LINE     = "/hv %s — %s 열기 (원래 명령어: %s)",
		HELP_HELP     = "/hv help — 이 목록 보기",
		NOT_READY     = "%s이(가) 설치되어 있지 않거나 꺼져 있어요.",
		UNKNOWN       = "모르는 명령어예요: %s  (/hv help)",

		LP_NAME       = "레벨페이스",
		LP_DESC       = "시간당 경험치와 레벨업까지 남은 시간을 보여주는 레벨링 도우미예요.",
		LP_BAR        = "정보 바 보이기",
		LP_LOCK       = "정보 바 잠금",
		CB_NAME       = "센터바",
		CB_DESC       = "캐릭터 양옆에 액션 버튼을 최대 18개 놓아주는 애드온이에요.",
		CB_COMBAT     = "전투 중에만 보이기",
		CB_MOUSE      = "마우스를 올렸을 때만 보이기",
	}
else
	L = {
		TITLE         = "hyveo Addon Center",
		VERSION       = "Version %s",
		ON            = "On",
		OFF           = "Off",
		ON_AFTER      = "On after reload",
		OFF_AFTER     = "Off after reload",
		MISSING       = "Not installed",
		BTN_OPEN      = "Open",
		BTN_ENABLE    = "Enable",
		BTN_DISABLE   = "Disable",
		BTN_GETLINK   = "Copy download link",
		BTN_RELOAD    = "Reload UI now",
		BTN_BUG       = "Copy bug report link",
		RELOAD_MSG    = "Reload the UI to apply your changes.",
		QUICK         = "Quick settings",
		QUICK_NONE    = "Available while the addon is enabled.",
		FOOTER        = "You can also open this with /hv",
		COPY_TITLE    = "Press Ctrl+C to copy",
		SIDE_NOTE     = "News and requests:\nGitHub: hyveo/wow-forever-addons",
		OPEN_CENTER   = "Open center",
		PANEL_DESC    = "Manage hyveo's addons in one window.",
		MISSING_DESC  = "This addon is not installed yet. Get it from the CurseForge app or GitHub.",
		HELP_HEAD     = "Commands",
		HELP_CENTER   = "/hv — toggle the center",
		HELP_LINE     = "/hv %s — open %s (also: %s)",
		HELP_HELP     = "/hv help — show this list",
		NOT_READY     = "%s is not installed or is disabled.",
		UNKNOWN       = "Unknown command: %s  (/hv help)",

		LP_NAME       = "LevelPace",
		LP_DESC       = "Leveling helper: XP per hour and time to next level.",
		LP_BAR        = "Show info bar",
		LP_LOCK       = "Lock info bar",
		CB_NAME       = "CenterBar",
		CB_DESC       = "Up to 18 action buttons around your character.",
		CB_COMBAT     = "Show only in combat",
		CB_MOUSE      = "Show only on mouseover",
	}
end

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

f:SetScript("OnShow", Refresh)

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

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(_, _, name)
	if name == ADDON_NAME then
		RegisterSettingsPanel()
		ev:UnregisterEvent("ADDON_LOADED")
	end
end)
