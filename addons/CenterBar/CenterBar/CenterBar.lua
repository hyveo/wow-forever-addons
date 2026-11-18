-- 센터바 (CenterBar) — 와우 포에버
-- 캐릭터 양옆에 액션 버튼을 최대 18개 놓아 주는 애드온.
-- 만든 사람: @hyveo  /  https://github.com/hyveo/wow-forever-addons

local ADDON_NAME = ...

---------------------------------------------------------------------------
-- 문자열
---------------------------------------------------------------------------
local L
if GetLocale() == "koKR" then
	L = {
		TITLE       = "센터바",
		BUTTON      = "센터바 %d",
		NEXT_SLOT   = "센터바 다음 슬롯",
		SLOT        = "슬롯 %d",
		SLOT_NOW    = "슬롯 %d번으로 바꿨어요.",
		COMBAT_WAIT = "전투가 끝나면 적용할게요.",
		LOCKED      = "센터바를 잠갔어요.",
		UNLOCKED    = "센터바 잠금을 풀었어요. 가운데 손잡이를 드래그해 옮기세요.",
		RESET       = "센터바 위치와 설정을 처음으로 되돌렸어요. (버튼에 넣은 기술은 그대로예요)",
		HELP        = "/cb — 설정 창  |  /cb 1, /cb 2, /cb 3 — 슬롯 바꾸기  |  /cb lock — 잠금/해제  |  /cb reset — 처음으로",
		HANDLE      = "센터바 — 드래그해서 옮기기",
	}
else
	L = {
		TITLE       = "CenterBar",
		BUTTON      = "CenterBar %d",
		NEXT_SLOT   = "CenterBar next slot",
		SLOT        = "Slot %d",
		SLOT_NOW    = "Switched to slot %d.",
		COMBAT_WAIT = "Will apply after combat.",
		LOCKED      = "CenterBar locked.",
		UNLOCKED    = "CenterBar unlocked. Drag the handle in the middle to move it.",
		RESET       = "CenterBar position and settings reset. (Your spells stay on the buttons)",
		HELP        = "/cb — options  |  /cb 1, /cb 2, /cb 3 — switch slot  |  /cb lock — lock/unlock  |  /cb reset — reset",
		HANDLE      = "CenterBar — drag to move",
	}
end
CenterBar_L = L

local function Print(msg)
	print("|cffffd100" .. L.TITLE .. "|r: " .. msg)
end

---------------------------------------------------------------------------
-- 설정
---------------------------------------------------------------------------
local NUM_BUTTONS = 18
local BUTTON_SIZE = 36
local PAGE_SLOTS  = 12

-- 슬롯: 버튼 18개가 쓰는 액션 칸 묶음. 기술은 게임이 칸마다 저장하므로 슬롯을 바꿔도 그대로 남는다.
--   main  = 버튼 1~12가 쓰는 액션바 페이지
--   extra = 버튼 13~18이 쓰는 페이지, offset = 그 페이지에서 몇 번째 칸부터(0 → 1~6번, 6 → 7~12번)
-- 슬롯 1은 예전 센터바(CentarBar)와 같은 칸이라, 예전에 넣어 둔 기술이 그대로 보인다.
-- 페이지 13~15는 기본 UI 액션바 6~8과 같은 칸이다.
local SLOTS = {
	{ main = 2,  extra = 10, offset = 0 },
	{ main = 13, extra = 10, offset = 6 },
	{ main = 14, extra = 15, offset = 0 },
}
local NUM_SLOTS = #SLOTS

local DEFAULTS = {
	version    = 2,
	point      = nil,        -- 저장 위치 (nil이면 화면 가운데 조금 아래)
	x          = 0,
	y          = -60,
	scale      = 1.0,
	alpha      = 1.0,
	gap        = 4,          -- 버튼 사이 간격
	inner      = 90,         -- 캐릭터와 안쪽 열 사이 거리
	count      = 18,         -- 6 / 12 / 18
	shape      = "arc",      -- arc(둥글게) / grid(반듯하게)
	grid       = true,       -- 빈 칸도 테두리 보이기
	visibility = "always",   -- always / combat / mouseover
	locked     = true,
	tooltips   = true,
	specSlot   = {},         -- [특성 번호] = 슬롯 번호
}

local db

local function CopyDefaults(dst, src)
	for k, v in pairs(src) do
		if dst[k] == nil then
			if type(v) == "table" then
				dst[k] = {}
				CopyDefaults(dst[k], v)
			else
				dst[k] = v
			end
		end
	end
end

local function Migrate()
	if (db.version or 1) < 2 then
		-- 1.0.x: 특성별 페이지 → 슬롯. 모양과 거리는 새 기본값으로.
		db.specPages, db.extraPage = nil, nil
		db.inner = DEFAULTS.inner
		db.version = 2
	end
end

local function CurrentSpec()
	return (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization and C_SpecializationInfo.GetSpecialization())
		or (GetSpecialization and GetSpecialization()) or 1
end

local function CurrentSlot()
	local s = db and db.specSlot[CurrentSpec()] or 1
	if not SLOTS[s] then s = 1 end
	return s
end

---------------------------------------------------------------------------
-- 버튼 자리 (예전 센터바와 같은 번호 → 같은 자리)
--   왼쪽  안 1~3   가운데 4~6    바깥 13~15
--   오른쪽 안 7~9  가운데 10~12  바깥 16~18
--   row: 0 위, 1 가운데, 2 아래
-- 표시 개수 6 = 안쪽 두 열, 12 = 가운데 열까지, 18 = 전부.
---------------------------------------------------------------------------
local SPOTS = {
	{ -1, 0, 2 }, { -1, 0, 1 }, { -1, 0, 0 },
	{ -1, 1, 2 }, { -1, 1, 1 }, { -1, 1, 0 },
	{  1, 0, 2 }, {  1, 0, 1 }, {  1, 0, 0 },
	{  1, 1, 0 }, {  1, 1, 1 }, {  1, 1, 2 },
	{ -1, 2, 2 }, { -1, 2, 1 }, { -1, 2, 0 },
	{  1, 2, 2 }, {  1, 2, 1 }, {  1, 2, 0 },
}

local function ButtonOffset(i)
	local side, depth, row = SPOTS[i][1], SPOTS[i][2], SPOTS[i][3]
	local step = BUTTON_SIZE + db.gap
	local radius = db.inner + depth * step + BUTTON_SIZE / 2
	if db.shape == "grid" then
		return side * radius, (1 - row) * step
	end
	-- 둥글게: 캐릭터를 중심으로 부채꼴처럼 펼친다 (같은 줄은 같은 각도, 바깥 열일수록 더 벌어짐)
	local angle = (1 - row) * (step / (db.inner + BUTTON_SIZE / 2))
	return side * radius * math.cos(angle), radius * math.sin(angle)
end

local function ButtonAction(i, slot)
	local s = SLOTS[slot or CurrentSlot()]
	if i <= PAGE_SLOTS then
		return (s.main - 1) * PAGE_SLOTS + i
	end
	return (s.extra - 1) * PAGE_SLOTS + s.offset + (i - PAGE_SLOTS)
end

local function ButtonEnabled(i)
	local depth = SPOTS[i][2]
	return depth < (db.count / 6)
end

---------------------------------------------------------------------------
-- 프레임
---------------------------------------------------------------------------
local bar = CreateFrame("Frame", "CenterBarFrame", UIParent, "SecureHandlerStateTemplate")
bar:SetSize(10, BUTTON_SIZE * 3)
bar:SetClampedToScreen(true)
bar:SetMovable(true)

local handle = CreateFrame("Frame", nil, bar, "BackdropTemplate")
handle:SetSize(60, BUTTON_SIZE * 3)
handle:SetPoint("CENTER")
handle:SetFrameLevel(bar:GetFrameLevel() + 10)
handle:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
handle:SetBackdropColor(1, 0.82, 0, 0.15)
handle:SetBackdropBorderColor(1, 0.82, 0, 0.8)
handle:EnableMouse(true)
handle:RegisterForDrag("LeftButton")
handle.text = handle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
handle.text:SetPoint("CENTER")
handle.text:SetText(L.TITLE)
handle:SetScript("OnDragStart", function()
	if not InCombatLockdown() then bar:StartMoving() end
end)
handle:SetScript("OnDragStop", function()
	bar:StopMovingOrSizing()
	local point, _, relPoint, x, y = bar:GetPoint()
	db.point, db.relPoint, db.x, db.y = point, relPoint, x, y
end)
handle:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L.HANDLE)
	GameTooltip:Show()
end)
handle:SetScript("OnLeave", function() GameTooltip:Hide() end)
handle:Hide()

-- 드래그 놓기/집기는 보안 코드에서 처리한다.
-- 블리자드 기본 드래그 코드를 애드온 버튼에서 그대로 쓰면 "기능이 차단되었습니다"가 뜬다.
local DRAG_START = [[
	local mod = (IsModifiedClick and IsModifiedClick("PICKUPACTION")) or IsShiftKeyDown()
	if self:GetAttribute("cb-lock") and not mod then return false end
	return "action", self:GetAttribute("action")
]]
local DRAG_RECEIVE = [[
	return "action", self:GetAttribute("action")
]]
local function NoOp() end

-- 아이콘이 칸을 꽉 채우고 테두리는 예전 퀵슬롯 모양으로
local function StyleButton(b)
	local icon = b.icon or _G[b:GetName() .. "Icon"]
	if icon then
		if b.IconMask and icon.RemoveMaskTexture then icon:RemoveMaskTexture(b.IconMask) end
		icon:ClearAllPoints()
		icon:SetAllPoints(b)
		icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	end
	local nt = b:GetNormalTexture()
	if nt then nt:SetAlpha(0) end
	for _, key in ipairs({ "SlotBackground", "SlotArt", "FloatingBG" }) do
		if b[key] then b[key]:SetAlpha(0) end
	end
	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	for _, tex in ipairs({ b:GetPushedTexture(), b:GetHighlightTexture(), b:GetCheckedTexture() }) do
		tex:ClearAllPoints()
		tex:SetAllPoints(b)
	end
	local ct = b:GetCheckedTexture()
	if ct then ct:SetBlendMode("ADD") end
	for _, key in ipairs({ "cooldown", "Flash", "Border", "NewActionTexture", "SpellHighlightTexture" }) do
		local r = b[key]
		if r and r.ClearAllPoints then
			r:ClearAllPoints()
			r:SetAllPoints(b)
		end
	end
end

local buttons, frames = {}, {}
for i = 1, NUM_BUTTONS do
	local name = "CenterBarButton" .. i
	local b = CreateFrame("CheckButton", name, bar, "ActionBarButtonTemplate")
	b:SetID(0) -- 페이지 계산을 블리자드 바에 맡기지 않고 action 속성을 그대로 쓰게 함
	b:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	b:SetFrameLevel(bar:GetFrameLevel() + 2)
	b:SetAttribute("type", "action")
	b:SetAttribute("checkselfcast", true)
	b:SetAttribute("checkfocuscast", true)
	b:SetAttribute("showgrid", 1) -- 빈 칸도 숨기지 않아야 기술을 끌어다 놓을 수 있다
	b:RegisterForDrag("LeftButton")
	b:SetScript("OnDragStart", NoOp)
	b:SetScript("OnReceiveDrag", NoOp)
	SecureHandlerWrapScript(b, "OnDragStart", bar, DRAG_START)
	SecureHandlerWrapScript(b, "OnReceiveDrag", bar, DRAG_RECEIVE)
	StyleButton(b)
	-- 단축키 표시: Bindings.xml의 CLICK 바인딩과 같은 이름
	b.commandName = "CLICK " .. name .. ":LeftButton"
	_G["BINDING_NAME_CLICK " .. name .. ":LeftButton"] = L.BUTTON:format(i)
	buttons[i] = b

	-- 칸 테두리 (버튼 위에 그리지만 마우스는 받지 않음)
	local fr = CreateFrame("Frame", nil, bar)
	fr:SetAllPoints(b)
	fr:SetFrameLevel(bar:GetFrameLevel() + 6)
	fr:EnableMouse(false)
	fr.tex = fr:CreateTexture(nil, "OVERLAY")
	fr.tex:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	fr.tex:SetPoint("TOPLEFT", -14, 14)
	fr.tex:SetPoint("BOTTOMRIGHT", 15, -15)
	fr.tex:SetAlpha(0.6)
	frames[i] = fr
end
BINDING_HEADER_CENTERBAR = L.TITLE
BINDING_NAME_CENTERBAR_NEXTSLOT = L.NEXT_SLOT

---------------------------------------------------------------------------
-- 적용 (보안 프레임이라 전투 중에는 미뤘다가 전투 끝나면 적용)
---------------------------------------------------------------------------
local pending = false

local function ApplyLayout()
	local lock = GetCVarBool and GetCVarBool("lockActionBars")
	local slot = CurrentSlot()
	for i, b in ipairs(buttons) do
		local x, y = ButtonOffset(i)
		b:ClearAllPoints()
		b:SetPoint("CENTER", bar, "CENTER", x, y)
		b:SetAttribute("cb-lock", lock and true or nil)
		b:SetAttribute("action", ButtonAction(i, slot))
		if ButtonEnabled(i) then b:Show() else b:Hide() end
		if b.UpdateAction then b:UpdateAction(true) end
	end
end

local function ApplyVisibility()
	UnregisterStateDriver(bar, "visibility")
	if db.visibility == "combat" then
		RegisterStateDriver(bar, "visibility", "[petbattle][vehicleui] hide; [combat] show; hide")
	else
		RegisterStateDriver(bar, "visibility", "[petbattle][vehicleui] hide; show")
	end
end

local function ApplyPosition()
	bar:ClearAllPoints()
	if db.point then
		bar:SetPoint(db.point, UIParent, db.relPoint or db.point, db.x, db.y)
	else
		bar:SetPoint("CENTER", UIParent, "CENTER", db.x, db.y)
	end
	bar:SetScale(db.scale)
end

local function ApplyAll()
	if InCombatLockdown() then
		if not pending then Print(L.COMBAT_WAIT) end
		pending = true
		return
	end
	pending = false
	ApplyPosition()
	ApplyLayout()
	ApplyVisibility()
	handle:SetShown(not db.locked)
end

-- 0.1초마다: 마우스 올렸을 때만 보이기(투명도라 전투 중에도 됨) + 칸 테두리
local FADE_ALPHA = 0
bar:SetScript("OnUpdate", function(self, elapsed)
	self.t = (self.t or 0) + elapsed
	if self.t < 0.1 or not db then return end
	self.t = 0
	local cursor = GetCursorInfo and GetCursorInfo()
	for i, b in ipairs(buttons) do
		local show = b:IsShown() and (db.grid or cursor or HasAction(b:GetAttribute("action") or 0))
		if frames[i]:IsShown() ~= (show and true or false) then frames[i]:SetShown(show) end
	end
	local target = db.alpha or 1
	if db.visibility == "mouseover" and db.locked then
		local over = self:IsMouseOver(10, -10, -10, 10)
		if not over then
			for _, b in ipairs(buttons) do
				if b:IsShown() and b:IsMouseOver() then over = true break end
			end
		end
		if not over and not cursor then target = FADE_ALPHA end
	end
	if math.abs(self:GetAlpha() - target) > 0.01 then self:SetAlpha(target) end
end)

-- 툴팁 끄기
hooksecurefunc(GameTooltip, "SetAction", function(tip, slot)
	if db and not db.tooltips and slot then
		for _, b in ipairs(buttons) do
			if b:GetAttribute("action") == slot and b:IsMouseOver() then
				tip:Hide()
				return
			end
		end
	end
end)

---------------------------------------------------------------------------
-- 공개 API (설정 창, hyveo 애드온 센터에서 사용)
---------------------------------------------------------------------------
local function SetSlot(s)
	if not db or not SLOTS[s] then return end
	db.specSlot[CurrentSpec()] = s
	ApplyAll()
	Print(L.SLOT_NOW:format(s))
	if CenterBarOptions and CenterBarOptions.Refresh then CenterBarOptions.Refresh() end
end

CenterBar = {
	L = L,
	NUM_SLOTS = NUM_SLOTS,
	Get = function(key) return db and db[key] end,
	Set = function(key, value)
		if not db then return end
		db[key] = value
		ApplyAll()
	end,
	GetSlot = function() return db and CurrentSlot() or 1 end,
	SetSlot = SetSlot,
	NextSlot = function() SetSlot(CurrentSlot() % NUM_SLOTS + 1) end,
	GetSlotInfo = function(s) return SLOTS[s] end,
	Apply = function() ApplyAll() end,
	Reset = function()
		if InCombatLockdown() then Print(L.COMBAT_WAIT) return end
		wipe(db)
		CopyDefaults(db, DEFAULTS)
		ApplyAll()
		Print(L.RESET)
	end,
	SetLocked = function(v)
		if not db then return end
		db.locked = v and true or false
		ApplyAll()
		Print(db.locked and L.LOCKED or L.UNLOCKED)
	end,
	IsCombatOnly = function() return db and db.visibility == "combat" end,
	IsMouseoverOnly = function() return db and db.visibility == "mouseover" end,
	ToggleOptions = function()
		if CenterBarOptions and CenterBarOptions.Toggle then CenterBarOptions.Toggle() end
	end,
}

---------------------------------------------------------------------------
-- 이벤트
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
ev:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
ev:RegisterEvent("CVAR_UPDATE")
ev:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON_NAME then return end
		CenterBarDB = CenterBarDB or {}
		db = CenterBarDB
		CopyDefaults(db, DEFAULTS)
		Migrate()
	elseif event == "PLAYER_LOGIN" then
		ApplyAll()
	elseif event == "PLAYER_REGEN_ENABLED" then
		if pending then ApplyAll() end
	elseif event == "CVAR_UPDATE" then
		if db and not InCombatLockdown() then ApplyLayout() end
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		if arg1 == nil or arg1 == "player" then ApplyAll() end
	end
end)

---------------------------------------------------------------------------
-- 명령어
---------------------------------------------------------------------------
SLASH_CENTERBAR1 = "/cb"
SLASH_CENTERBAR2 = "/centerbar"
SLASH_CENTERBAR3 = "/센터바"
SlashCmdList.CENTERBAR = function(msg)
	msg = strlower(strtrim(msg or ""))
	local n = tonumber(msg:match("^%D*(%d+)$") or "")
	if msg == "" then
		CenterBar.ToggleOptions()
	elseif n and (msg == tostring(n) or msg:find("^slot") or msg:find("^슬롯")) then
		if SLOTS[n] then SetSlot(n) else Print(L.HELP) end
	elseif msg == "next" or msg == "다음" then
		CenterBar.NextSlot()
	elseif msg == "lock" or msg == "잠금" then
		CenterBar.SetLocked(not db.locked)
	elseif msg == "reset" or msg == "초기화" then
		CenterBar.Reset()
	else
		Print(L.HELP)
	end
end
