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
		TITLE      = "센터바",
		BUTTON     = "센터바 %d",
		COMBAT_WAIT = "전투가 끝나면 적용할게요.",
		LOCKED     = "센터바를 잠갔어요.",
		UNLOCKED   = "센터바 잠금을 풀었어요. 가운데 손잡이를 드래그해 옮기세요.",
		RESET      = "센터바 위치와 설정을 처음으로 되돌렸어요.",
		HELP       = "/cb — 설정 창  |  /cb lock — 잠금/해제  |  /cb reset — 처음으로",
		HANDLE     = "센터바 — 드래그해서 옮기기",
	}
else
	L = {
		TITLE      = "CenterBar",
		BUTTON     = "CenterBar %d",
		COMBAT_WAIT = "Will apply after combat.",
		LOCKED     = "CenterBar locked.",
		UNLOCKED   = "CenterBar unlocked. Drag the handle in the middle to move it.",
		RESET      = "CenterBar position and settings reset.",
		HELP       = "/cb — options  |  /cb lock — lock/unlock  |  /cb reset — reset",
		HANDLE     = "CenterBar — drag to move",
	}
end
CenterBar_L = L

local function Print(msg)
	print("|cffffd100" .. L.TITLE .. "|r: " .. msg)
end

---------------------------------------------------------------------------
-- 설정
---------------------------------------------------------------------------
local NUM_BUTTONS   = 18
local BUTTON_SIZE   = 36
local PAGE_SLOTS    = 12

local DEFAULTS = {
	version    = 1,
	point      = nil,        -- 저장 위치 (nil이면 화면 가운데 조금 아래)
	x          = 0,
	y          = -60,
	scale      = 1.0,
	alpha      = 1.0,
	gap        = 4,          -- 버튼 사이 간격
	inner      = 70,         -- 캐릭터와 안쪽 열 사이 거리
	count      = 18,         -- 6 / 12 / 18
	visibility = "always",   -- always / combat / mouseover
	locked     = true,
	tooltips   = true,
	specPages  = {},         -- [특성 번호] = 1~10번 액션바 페이지
	extraPage  = 10,         -- 13~18번 버튼이 쓰는 페이지 (1~6번 칸)
}
local DEFAULT_SPEC_PAGE = 7

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

---------------------------------------------------------------------------
-- 버튼 배치
--
-- 한쪽에 3줄짜리 열이 3개(안쪽 → 바깥쪽). 왼쪽 열 = 왼쪽으로, 오른쪽 열 = 오른쪽으로.
--   열 번호  1(왼쪽 안)  2(오른쪽 안)  3(왼쪽 가운데)  4(오른쪽 가운데)  5(왼쪽 바깥)  6(오른쪽 바깥)
--   버튼     1~3        4~6          7~9            10~12            13~15        16~18
-- 표시 개수 6 = 열 1·2, 12 = 열 1~4, 18 = 전부. 버튼 1~12는 특성 페이지, 13~18은 추가 페이지.
---------------------------------------------------------------------------
local function ButtonLayout(i)
	local col = math.floor((i - 1) / 3) + 1       -- 1~6
	local row = (i - 1) % 3                        -- 0~2 (위에서 아래)
	local side = (col % 2 == 1) and -1 or 1        -- 홀수 열 왼쪽, 짝수 열 오른쪽
	local depth = math.floor((col - 1) / 2)        -- 0 안쪽, 1 가운데, 2 바깥
	return col, row, side, depth
end

local function ButtonAction(i)
	if i <= PAGE_SLOTS then
		-- 열 1~4 → 페이지 칸 1~12 (왼쪽 안 1~3, 오른쪽 안 4~6, 왼쪽 가운데 7~9, 오른쪽 가운데 10~12)
		local spec = (GetSpecialization and GetSpecialization()) or 1
		local page = db.specPages[spec] or DEFAULT_SPEC_PAGE
		return (page - 1) * PAGE_SLOTS + i
	end
	return (db.extraPage - 1) * PAGE_SLOTS + (i - PAGE_SLOTS)
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

local buttons = {}
for i = 1, NUM_BUTTONS do
	local name = "CenterBarButton" .. i
	local b = CreateFrame("CheckButton", name, bar, "ActionBarButtonTemplate")
	b:SetID(0) -- 페이지 계산을 블리자드 바에 맡기지 않고 action 속성을 그대로 쓰게 함
	b:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	b:SetAttribute("type", "action")
	b:SetAttribute("checkselfcast", true)
	b:SetAttribute("checkfocuscast", true)
	-- 단축키 표시: Bindings.xml의 CLICK 바인딩과 같은 이름
	b.commandName = "CLICK " .. name .. ":LeftButton"
	_G["BINDING_NAME_CLICK " .. name .. ":LeftButton"] = L.BUTTON:format(i)
	buttons[i] = b
end
BINDING_HEADER_CENTERBAR = L.TITLE

---------------------------------------------------------------------------
-- 적용 (보안 프레임이라 전투 중에는 미뤘다가 전투 끝나면 적용)
---------------------------------------------------------------------------
local pending = false

local function ApplyLayout()
	local step = BUTTON_SIZE + db.gap
	for i, b in ipairs(buttons) do
		local col, row, side, depth = ButtonLayout(i)
		local x = side * (db.inner + depth * step + BUTTON_SIZE / 2)
		local y = (1 - row) * step
		b:ClearAllPoints()
		b:SetPoint("CENTER", bar, "CENTER", x, y)
		b:SetAttribute("action", ButtonAction(i))
		if col <= (db.count / 3) then b:Show() else b:Hide() end
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

-- 마우스를 올렸을 때만 보이기: 투명도만 바꾸므로 전투 중에도 동작
local FADE_ALPHA = 0
bar:SetScript("OnUpdate", function(self, elapsed)
	self.t = (self.t or 0) + elapsed
	if self.t < 0.1 then return end
	self.t = 0
	local target = db and db.alpha or 1
	if db and db.visibility == "mouseover" and db.locked then
		local over = self:IsMouseOver(10, -10, -10, 10)
		if not over then
			for _, b in ipairs(buttons) do
				if b:IsShown() and b:IsMouseOver() then over = true break end
			end
		end
		if not over and not (GetCursorInfo and GetCursorInfo()) then target = FADE_ALPHA end
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
CenterBar = {
	L = L,
	Get = function(key) return db and db[key] end,
	Set = function(key, value)
		if not db then return end
		db[key] = value
		ApplyAll()
	end,
	GetSpecPage = function(spec) return db and (db.specPages[spec] or DEFAULT_SPEC_PAGE) end,
	SetSpecPage = function(spec, page)
		if not db then return end
		db.specPages[spec] = page
		ApplyAll()
	end,
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
ev:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON_NAME then return end
		CenterBarDB = CenterBarDB or {}
		db = CenterBarDB
		CopyDefaults(db, DEFAULTS)
	elseif event == "PLAYER_LOGIN" then
		ApplyAll()
	elseif event == "PLAYER_REGEN_ENABLED" then
		if pending then ApplyAll() end
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
	if msg == "" then
		CenterBar.ToggleOptions()
	elseif msg == "lock" or msg == "잠금" then
		CenterBar.SetLocked(not db.locked)
	elseif msg == "reset" or msg == "초기화" then
		CenterBar.Reset()
	else
		Print(L.HELP)
	end
end
