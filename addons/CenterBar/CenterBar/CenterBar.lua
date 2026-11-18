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
		PRESETS     = { "기본", "둥글게", "세로 3줄 1", "세로 3줄 2", "세로 3줄 3" },
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
		PRESETS     = { "Default", "Round", "Columns 1", "Columns 2", "Columns 3" },
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

-- 배치: 화면 가운데(캐릭터)를 0,0으로 본 버튼 18개의 칸 좌표. 실제 거리 = 좌표 x 간격(step, 기본 10).
-- 예전 센터바와 같은 좌표 체계라 같은 자리에 놓인다.
local PRESETS = {
	{ -- 기본: 세로 3줄, 가운데 줄이 살짝 어긋남
		x = { -14, -14, -14, -19, -19, -19, 14, 14, 14, 19, 19, 19, -24, -24, -24, 24, 24, 24 },
		y = { -5, 0, 5, -7, -2, 3, -5, 0, 5, 3, -2, -7, -5, 0, 5, -5, 0, 5 },
	},
	{ -- 둥글게: 캐릭터를 감싸는 호
		x = { -25, -29, -31, -31, -29, -25, 25, 29, 31, 31, 29, 25, -36, -38, -36, 36, 38, 36 },
		y = { 15, 9, 3, -3, -9, -15, 15, 9, 3, -3, -9, -15, 9, 0, -9, 9, 0, -9 },
	},
	{ -- 세로 3줄 1: 반듯하게
		x = { -20, -20, -20, -15, -15, -15, 15, 15, 15, 20, 20, 20, -25, -25, -25, 25, 25, 25 },
		y = { 5, 0, -5, 5, 0, -5, 5, 0, -5, 5, 0, -5, 5, 0, -5, 5, 0, -5 },
	},
	{ -- 세로 3줄 2: 넓게, 가운데 줄 어긋남
		x = { -18, -18, -18, -23, -23, -23, 18, 18, 18, 23, 23, 23, -28, -28, -28, 28, 28, 28 },
		y = { -5, 0, 5, 3, -2, -7, -5, 0, 5, 3, -2, -7, -5, 0, 5, -5, 0, 5 },
	},
	{ -- 세로 3줄 3: 줄마다 어긋남
		x = { -20, -20, -20, -15, -15, -15, 15, 15, 15, 20, 20, 20, -25, -25, -25, 25, 25, 25 },
		y = { 5, 0, -5, 3, -2, -7, 3, -2, -7, 5, 0, -5, 3, -2, -7, 3, -2, -7 },
	},
}
-- 표시 개수용 열 묶음 (한쪽에 3열)
local COLUMNS = {
	{ { 1, 2, 3 }, { 4, 5, 6 }, { 13, 14, 15 } },
	{ { 7, 8, 9 }, { 10, 11, 12 }, { 16, 17, 18 } },
}

local DEFAULTS = {
	version    = 4,
	point      = nil,        -- 저장 위치 (nil이면 화면 한가운데)
	x          = 0,
	y          = 0,
	scale      = 1.0,
	alpha      = 1.0,
	preset     = 1,          -- PRESETS 번호
	step       = 10,         -- 칸 좌표 1의 거리 (클수록 넓게 퍼짐)
	count      = 18,         -- 6 / 12 / 18
	grid       = false,      -- 빈 칸도 테두리 보이기 (끄면 빈 칸은 안 보임)
	mirror     = true,       -- 격자에서 옮길 때 반대쪽 버튼도 같이
	combat     = false,      -- 전투 중에는 투명도 복구(또렷하게)
	target     = false,      -- 대상을 선택하면 복구
	mouseover  = false,      -- 마우스를 올리면 복구
	vehiclehide = false,     -- 탈것(탑승 장비) 탑승 시 숨김
	mounthide  = false,      -- 일반 탈것도 포함
	slotPages  = {},         -- [슬롯] = { main = 페이지, extra = 페이지 } (직접 바꾼 경우만)
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
	if (db.version or 1) < 3 then
		-- 1.0.x~1.1.0: 배치 방식이 바뀌어 위치를 화면 가운데로 되돌린다
		db.specPages, db.extraPage, db.shape, db.gap, db.inner = nil, nil, nil, nil, nil
		db.point, db.relPoint, db.x, db.y = nil, nil, 0, 0
		db.version = 3
	end
	if (db.version or 1) < 4 then
		-- 1.1.x: "보이기" 선택 → 예전 센터바처럼 투명도 + 복구 조건
		if db.visibility == "combat" then db.combat = true db.alpha = 0
		elseif db.visibility == "mouseover" then db.mouseover = true db.alpha = 0 end
		db.visibility = nil
		db.grid = false
		db.version = 4
	end
	if db.preset ~= 0 and not PRESETS[db.preset] then db.preset = 1 end
end

-- 버튼 자리(db.px, db.py)가 없으면 고른 배치에서 복사한다. 격자에서 직접 옮기면 preset = 0(직접 배치).
local function EnsurePositions()
	if type(db.px) == "table" and type(db.py) == "table" and #db.px >= 18 and #db.py >= 18 then return end
	local p = PRESETS[db.preset] or PRESETS[1]
	db.px, db.py = {}, {}
	for i = 1, 18 do db.px[i], db.py[i] = p.x[i], p.y[i] end
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

local function ButtonOffset(i)
	return db.px[i] * db.step, db.py[i] * db.step
end

local function ButtonAction(i, slot)
	slot = slot or CurrentSlot()
	local s, o = SLOTS[slot], db.slotPages[slot]
	local main = (o and o.main) or s.main
	local extra = (o and o.extra) or s.extra
	if i <= PAGE_SLOTS then
		return (main - 1) * PAGE_SLOTS + i
	end
	return (extra - 1) * PAGE_SLOTS + s.offset + (i - PAGE_SLOTS)
end

-- 표시 개수 6/12/18: 양쪽에서 캐릭터와 가까운 열부터 보인다
local function EnabledSet()
	local set, shown = {}, db.count / 6
	local xs = db.px
	for _, side in ipairs(COLUMNS) do
		local order = {}
		for idx, col in ipairs(side) do
			local sum = 0
			for _, i in ipairs(col) do sum = sum + math.abs(xs[i]) end
			order[idx] = { col = col, d = sum, idx = idx }
		end
		table.sort(order, function(a, b)
			if a.d ~= b.d then return a.d < b.d end
			return a.idx < b.idx
		end)
		for k = 1, math.min(shown, #order) do
			for _, i in ipairs(order[k].col) do set[i] = true end
		end
	end
	return set
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

---------------------------------------------------------------------------
-- 버튼
--
-- 게임 기본 액션 버튼 틀(ActionBarButtonTemplate)을 애드온이 만들어 쓰면, 재사용 대기시간 같은
-- "비밀 값"을 다루는 기본 UI 코드가 막혀 오류가 난다. 그래서 누르는 동작만 게임 보안 버튼에 맡기고
-- 아이콘·대기시간·개수·테두리는 직접 그린다.
---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local isSecret = issecretvalue or function() return false end

-- 끌어다 놓기/빼기는 보안 코드에서 처리 (애드온 코드가 직접 하면 "기능이 차단되었습니다"가 뜬다)
local DRAG_START = [[
	local mod = (IsModifiedClick and IsModifiedClick("PICKUPACTION")) or IsShiftKeyDown()
	if self:GetAttribute("cb-lock") and not mod then return false end
	return "action", self:GetAttribute("action")
]]
local DRAG_RECEIVE = [[
	return "action", self:GetAttribute("action")
]]
local function NoOp() end

local function Edge(b, layer, r, g, bl, a, size)
	local t = {}
	for k = 1, 4 do
		t[k] = b:CreateTexture(nil, layer)
		t[k]:SetColorTexture(r, g, bl, a)
	end
	t[1]:SetPoint("TOPLEFT") t[1]:SetPoint("TOPRIGHT") t[1]:SetHeight(size)
	t[2]:SetPoint("BOTTOMLEFT") t[2]:SetPoint("BOTTOMRIGHT") t[2]:SetHeight(size)
	t[3]:SetPoint("TOPLEFT") t[3]:SetPoint("BOTTOMLEFT") t[3]:SetWidth(size)
	t[4]:SetPoint("TOPRIGHT") t[4]:SetPoint("BOTTOMRIGHT") t[4]:SetWidth(size)
	return t
end

local function ShortKey(key)
	if not key then return "" end
	local text = (GetBindingText and GetBindingText(key, 1)) or key
	text = text:gsub("SHIFT%-", "S"):gsub("CTRL%-", "C"):gsub("ALT%-", "A")
	text = text:gsub("s%-", "S"):gsub("c%-", "C"):gsub("a%-", "A")
	return text
end

local function UpdateCooldown(b)
	local slot, cd = b.slot, b.cd
	if not slot then return end
	-- 새 방식: 게임이 주는 "지속시간 객체"를 그대로 넘긴다 (값을 들여다보지 않으므로 전투 중에도 됨)
	if C_ActionBar and C_ActionBar.GetActionCooldownDuration and cd.SetCooldownFromDurationObject then
		local okInfo, info = pcall(C_ActionBar.GetActionCooldown, slot)
		if okInfo and type(info) == "table" and info.isActive == false then
			cd:Clear()
			return
		end
		local ok, obj = pcall(C_ActionBar.GetActionCooldownDuration, slot)
		if ok and obj and pcall(cd.SetCooldownFromDurationObject, cd, obj) then return end
	end
	if GetActionCooldown then
		local ok, start, duration, _, modRate = pcall(GetActionCooldown, slot)
		if ok and start ~= nil then pcall(cd.SetCooldown, cd, start, duration, modRate) end
	end
end

local function CountText(slot)
	if C_ActionBar and C_ActionBar.GetActionDisplayCount then
		return C_ActionBar.GetActionDisplayCount(slot) or ""
	end
	if (IsConsumableAction and IsConsumableAction(slot)) or (IsStackableAction and IsStackableAction(slot)) then
		local n = GetActionCount(slot)
		return n > 9999 and "*" or tostring(n)
	end
	if GetActionCharges then
		local charges, maxCharges = GetActionCharges(slot)
		if maxCharges and maxCharges > 1 then return tostring(charges) end
	end
	return ""
end

local function UpdateState(b)
	local slot = b.slot
	if not slot or not b.has then return end
	local ok, usable, noMana = pcall(IsUsableAction, slot)
	if ok and not isSecret(usable) and not isSecret(noMana) then
		if usable then b.icon:SetVertexColor(1, 1, 1)
		elseif noMana then b.icon:SetVertexColor(0.5, 0.5, 1)
		else b.icon:SetVertexColor(0.4, 0.4, 0.4) end
	end
	local ok2, cur = pcall(IsCurrentAction, slot)
	local ok3, auto = pcall(IsAutoRepeatAction, slot)
	if ok2 and not isSecret(cur) and not (ok3 and isSecret(auto)) then
		b:SetChecked((cur or (ok3 and auto)) and true or false)
	end
end

local function UpdateButton(b)
	local slot = b.slot
	if not slot then return end
	local tex = GetActionTexture(slot)
	b.has = tex and true or false
	if tex then
		b.icon:SetTexture(tex)
		b.icon:Show()
	else
		b.icon:Hide()
		b.cd:Clear()
		b:SetChecked(false)
	end
	local ok, text = pcall(CountText, slot)
	pcall(b.count.SetText, b.count, (ok and tex and text) or "")
	b.hotkey:SetText(ShortKey(GetBindingKey and GetBindingKey(b.command)))
	if tex then
		UpdateCooldown(b)
		UpdateState(b)
	end
end

local function UpdateFrame(b, cursor)
	-- 테두리는 빈 칸에만 (기술이 들어 있으면 아이콘만 보임)
	local show = not b.has and (db.grid or cursor)
	if b.bg:IsShown() ~= (show and true or false) then
		b.bg:SetShown(show)
		for _, t in ipairs(b.edge) do t:SetShown(show) end
	end
end

local buttons = {}
for i = 1, NUM_BUTTONS do
	local name = "CenterBarButton" .. i
	local b = CreateFrame("CheckButton", name, bar, "SecureActionButtonTemplate")
	b:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	b:SetFrameLevel(bar:GetFrameLevel() + 2)
	b:SetAttribute("type", "action")
	b:SetAttribute("checkselfcast", true)
	b:SetAttribute("checkfocuscast", true)
	b:RegisterForClicks("AnyUp", "AnyDown")
	b:RegisterForDrag("LeftButton")
	b:SetScript("OnDragStart", NoOp)
	b:SetScript("OnReceiveDrag", NoOp)
	SecureHandlerWrapScript(b, "OnDragStart", bar, DRAG_START)
	SecureHandlerWrapScript(b, "OnReceiveDrag", bar, DRAG_RECEIVE)

	-- 칸 바탕 + 테두리(격자)
	b.bg = b:CreateTexture(nil, "BACKGROUND")
	b.bg:SetAllPoints()
	b.bg:SetColorTexture(0, 0, 0, 0.12)
	b.edge = Edge(b, "OVERLAY", 0.75, 0.75, 0.8, 0.6, 1)

	-- 아이콘: 칸을 꽉 채움
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetAllPoints()
	b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	b.icon:Hide()

	b.cd = CreateFrame("Cooldown", name .. "Cooldown", b, "CooldownFrameTemplate")
	b.cd:SetAllPoints()

	local over = CreateFrame("Frame", nil, b)
	over:SetAllPoints()
	over:SetFrameLevel(b.cd:GetFrameLevel() + 1)
	b.count = over:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	b.count:SetPoint("BOTTOMRIGHT", -2, 2)
	b.hotkey = over:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
	b.hotkey:SetPoint("TOPRIGHT", -2, -2)

	b:SetHighlightTexture(WHITE)
	local hl = b:GetHighlightTexture()
	if hl then hl:SetVertexColor(1, 1, 1, 0.2) hl:SetBlendMode("ADD") end
	b:SetPushedTexture(WHITE)
	local pt = b:GetPushedTexture()
	if pt then pt:SetVertexColor(0, 0, 0, 0.4) end
	b:SetCheckedTexture(WHITE)
	local ct = b:GetCheckedTexture()
	if ct then ct:SetVertexColor(1, 0.82, 0, 0.3) ct:SetBlendMode("ADD") end

	b:SetScript("PostClick", function(self) UpdateState(self) if not self.has then self:SetChecked(false) end end)
	b:SetScript("OnEnter", function(self)
		if db and db.tooltips and self.has then
			if GameTooltip_SetDefaultAnchor then GameTooltip_SetDefaultAnchor(GameTooltip, self)
			else GameTooltip:SetOwner(self, "ANCHOR_RIGHT") end
			GameTooltip:SetAction(self.slot)
			GameTooltip:Show()
		end
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- 단축키: Bindings.xml의 CLICK 바인딩과 같은 이름
	b.command = "CLICK " .. name .. ":LeftButton"
	_G["BINDING_NAME_" .. b.command] = L.BUTTON:format(i)
	buttons[i] = b
end
BINDING_HEADER_CENTERBAR = L.TITLE
BINDING_NAME_CENTERBAR_NEXTSLOT = L.NEXT_SLOT

local function UpdateAllButtons()
	if not db then return end
	local cursor = GetCursorInfo and GetCursorInfo() and true or false
	for _, b in ipairs(buttons) do
		UpdateButton(b)
		UpdateFrame(b, cursor)
	end
end

---------------------------------------------------------------------------
-- 적용 (보안 프레임이라 전투 중에는 미뤘다가 전투 끝나면 적용)
---------------------------------------------------------------------------
local pending = false

local function ApplyLayout()
	EnsurePositions()
	local lock = GetCVarBool and GetCVarBool("lockActionBars")
	local slot = CurrentSlot()
	local enabled = EnabledSet()
	for i, b in ipairs(buttons) do
		local x, y = ButtonOffset(i)
		b:ClearAllPoints()
		b:SetPoint("CENTER", bar, "CENTER", x, y)
		b.slot = ButtonAction(i, slot)
		b:SetAttribute("cb-lock", lock and true or nil)
		b:SetAttribute("action", b.slot)
		if enabled[i] then b:Show() else b:Hide() end
	end
	UpdateAllButtons()
end

local function ApplyVisibility()
	UnregisterStateDriver(bar, "visibility")
	local cond = "[petbattle] hide; "
	if db.vehiclehide then
		cond = cond .. "[vehicleui][overridebar][possessbar] hide; "
		if db.mounthide then cond = cond .. "[mounted] hide; " end
	end
	RegisterStateDriver(bar, "visibility", cond .. "show")
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
	EnsurePositions()
	ApplyPosition()
	ApplyLayout()
	ApplyVisibility()
	handle:SetShown(not db.locked)
end

-- 주기 갱신: 사용 가능 여부·테두리(0.2초), 마우스 올렸을 때만 보이기(투명도라 전투 중에도 됨)
local FADE_ALPHA = 0
bar:SetScript("OnUpdate", function(self, elapsed)
	self.t = (self.t or 0) + elapsed
	if self.t < 0.2 or not db then return end
	self.t = 0
	local cursor = GetCursorInfo and GetCursorInfo() and true or false
	for _, b in ipairs(buttons) do
		if b:IsShown() then
			UpdateState(b)
			UpdateFrame(b, cursor)
		end
	end
	-- 투명도: 평소에는 설정값, 복구 조건에 맞으면 또렷하게
	local target = db.alpha or 1
	if target < 1 then
		local full = cursor or not db.locked
			or (CenterBarEditFrame and CenterBarEditFrame:IsShown())
			or (db.combat and InCombatLockdown())
			or (db.target and UnitExists("target"))
		if not full and db.mouseover then
			for _, b in ipairs(buttons) do
				if b:IsShown() and b:IsMouseOver() then full = true break end
			end
		end
		if full then target = 1 end
	end
	if math.abs(self:GetAlpha() - target) > 0.01 then self:SetAlpha(target) end
end)

-- 게임 쪽 변화가 있으면 다시 그린다
local watch = CreateFrame("Frame")
for _, e in ipairs({
	"PLAYER_ENTERING_WORLD", "ACTIONBAR_SLOT_CHANGED", "ACTIONBAR_UPDATE_COOLDOWN", "ACTIONBAR_UPDATE_STATE",
	"ACTIONBAR_UPDATE_USABLE", "SPELL_UPDATE_COOLDOWN", "SPELL_UPDATE_CHARGES", "SPELL_UPDATE_USABLE",
	"SPELL_UPDATE_ICON", "UPDATE_BINDINGS", "BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UPDATE_SHAPESHIFT_FORM",
}) do
	pcall(watch.RegisterEvent, watch, e)
end
watch:SetScript("OnEvent", UpdateAllButtons)

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
		if key == "visibility" then -- hyveo 애드온 센터(예전 방식) 호환
			db.combat = (value == "combat")
			db.mouseover = (value == "mouseover")
			if value == "always" then db.alpha = 1 elseif (db.alpha or 1) >= 1 then db.alpha = 0 end
		else
			db[key] = value
		end
		if key == "preset" then db.px, db.py = nil, nil end
		ApplyAll()
	end,
	GetSlot = function() return db and CurrentSlot() or 1 end,
	SetSlot = SetSlot,
	NextSlot = function() SetSlot(CurrentSlot() % NUM_SLOTS + 1) end,
	GetSlotInfo = function(s) return SLOTS[s] end,
	-- 지금 슬롯이 쓰는 액션바 페이지 (kind = "main" 버튼 1~12, "extra" 버튼 13~18)
	GetSlotPage = function(kind)
		if not db then return 1 end
		local s = CurrentSlot()
		local o = db.slotPages[s]
		return (o and o[kind]) or SLOTS[s][kind]
	end,
	SetSlotPage = function(kind, page)
		if not db then return end
		local s = CurrentSlot()
		db.slotPages[s] = db.slotPages[s] or {}
		db.slotPages[s][kind] = page
		ApplyAll()
	end,
	-- 바 전체를 조금씩 옮기기
	Nudge = function(dx, dy)
		if not db then return end
		db.x, db.y = (db.x or 0) + dx, (db.y or 0) + dy
		ApplyAll()
	end,
	NUM_PRESETS = #PRESETS,
	NUM_BUTTONS = NUM_BUTTONS,
	GetPos = function(i) if db and db.px then return db.px[i], db.py[i] end end,
	SetPos = function(i, x, y)
		if not db or not db.px or InCombatLockdown() then return end
		db.px[i], db.py[i] = x, y
		db.preset = 0
		ApplyAll()
	end,
	IsButtonShown = function(i) return db and db.px and EnabledSet()[i] or false end,
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
	IsCombatOnly = function() return db and db.combat and (db.alpha or 1) < 1 or false end,
	IsMouseoverOnly = function() return db and db.mouseover and (db.alpha or 1) < 1 or false end,
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
		EnsurePositions()
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
