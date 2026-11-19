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
		MM_LEFT     = "왼쪽 클릭: 설정 창",
		MM_RIGHT    = "오른쪽 클릭: 다음 슬롯",
		MM_DRAG     = "드래그: 버튼 옮기기",
		CANT_PLACE  = "여기에는 주문, 아이템, 매크로만 넣을 수 있어요.",
		RESET       = "센터바 위치와 설정을 처음으로 되돌렸어요. (버튼에 넣은 기술은 그대로예요)",
		HELP        = "/cb — 설정 창  |  /cb 1 ~ /cb 5 — 슬롯 바꾸기  |  /cb lock — 잠금/해제  |  /cb reset — 처음으로",
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
		MM_LEFT     = "Left-click: options",
		MM_RIGHT    = "Right-click: next slot",
		MM_DRAG     = "Drag: move this button",
		CANT_PLACE  = "Only spells, items and macros can go here.",
		RESET       = "CenterBar position and settings reset. (Your spells stay on the buttons)",
		HELP        = "/cb — options  |  /cb 1 … /cb 5 — switch slot  |  /cb lock — lock/unlock  |  /cb reset — reset",
		HANDLE      = "CenterBar — drag to move",
	}
end
CenterBar_L = L

local quiet = false -- 설정의 "채팅창 메시지 숨김"
local function Print(msg, always)
	if quiet and not always then return end
	print("|cffffd100" .. L.TITLE .. "|r: " .. msg)
end

---------------------------------------------------------------------------
-- 설정
---------------------------------------------------------------------------
local NUM_BUTTONS = 18
local BUTTON_SIZE = 36

-- 슬롯: 버튼 18개에 넣은 기술 묶음. 게임 액션바 칸을 빌리지 않고 센터바가 캐릭터별로 직접 저장하므로
-- 다른 액션바나 다른 슬롯과 내용이 섞이지 않는다.
local NUM_SLOTS = 5

-- 예전 버전(액션바 칸을 빌려 쓰던 1.2.x 이하, 예전 CentarBar)에서 넣어 둔 기술을 한 번 가져올 때 읽는 칸.
-- { 버튼 1~12의 첫 칸, 버튼 13~18의 첫 칸 }
local IMPORT_FROM = {
	{ 13, 109 },   -- 슬롯 1: 2페이지 + 10페이지 1~6번 (예전 센터바 기본값)
	{ 145, 115 },  -- 슬롯 2: 13페이지 + 10페이지 7~12번
	{ 157, 169 },  -- 슬롯 3: 14페이지 + 15페이지 1~6번
}

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
	quiet        = false,    -- 채팅창 안내 메시지 숨김
	minimapHide  = false,    -- 미니맵 버튼 숨김
	minimapAngle = 215,      -- 미니맵 둘레에서의 위치(도)
	sets       = {},         -- [슬롯][버튼] = { t = "spell"/"item"/"macro", id = 번호, name = 매크로 이름 }
	imported   = false,      -- 예전 버전 기술 가져오기를 끝냈는지
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
	if db.version == 5 and db.preset == 2 then db.preset = 1 db.px, db.py = nil, nil end -- 1.3.3의 곡선 기본값 되돌림
	if (db.version or 1) > 4 then db.version = 4 end
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
	if type(s) ~= "number" or s < 1 or s > NUM_SLOTS then s = 1 end
	return s
end

local function ButtonOffset(i)
	return db.px[i] * db.step, db.py[i] * db.step
end

local function Content(i, slot)
	local set = db.sets[slot or CurrentSlot()]
	return set and set[i]
end

local function SetContent(i, c, slot)
	slot = slot or CurrentSlot()
	db.sets[slot] = db.sets[slot] or {}
	db.sets[slot][i] = c
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
-- 누르는 동작만 게임 보안 버튼(SecureActionButton)에 맡기고, 아이콘·대기시간·개수·테두리는 직접 그린다.
-- 버튼 내용은 액션바 칸이 아니라 "주문 번호 / 아이템 번호 / 매크로"로 센터바가 직접 기억한다.
---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local isSecret = issecretvalue or function() return false end

-- 버튼에서 끌어 빼기는 보안 코드에서 처리 (전투 중에는 안 됨)
local DRAG_START = [[
	if PlayerInCombat() then return false end
	local mod = (IsModifiedClick and IsModifiedClick("PICKUPACTION")) or IsShiftKeyDown()
	if self:GetAttribute("cb-lock") and not mod then return false end
	local t = self:GetAttribute("type")
	if t == "spell" then return "spell", self:GetAttribute("spell") end
	if t == "item" then return "item", self:GetAttribute("item") end
	if t == "macro" then return "macro", self:GetAttribute("macro") end
	return false
]]
local function NoOp() end

local ShowSpellTooltip

local function ShortKey(key)
	if not key then return "" end
	local text = (GetBindingText and GetBindingText(key, 1)) or key
	text = text:gsub("SHIFT%-", "S"):gsub("CTRL%-", "C"):gsub("ALT%-", "A")
	text = text:gsub("s%-", "S"):gsub("c%-", "C"):gsub("a%-", "A")
	return text
end

local function MacroIndex(c)
	if c.name and GetMacroIndexByName then
		local idx = GetMacroIndexByName(c.name)
		if idx and idx > 0 then return idx end
		return nil
	end
	return c.id
end

-- 매크로가 지금 쓰려는 주문 (아이콘·대기시간 표시용)
local function MacroSpell(c)
	local idx = MacroIndex(c)
	if idx and GetMacroSpell then
		local ok, id = pcall(GetMacroSpell, idx)
		if ok and id and not isSecret(id) then return id end
	end
end

local function ContentTexture(c)
	if c.t == "spell" then
		return C_Spell.GetSpellTexture(c.id)
	elseif c.t == "item" then
		return C_Item.GetItemIconByID(c.id)
	elseif c.t == "macro" then
		local idx = MacroIndex(c)
		if not idx then return 134400 end -- 매크로가 지워졌으면 물음표
		local spell = MacroSpell(c)
		local tex = spell and C_Spell.GetSpellTexture(spell)
		if tex then return tex end
		local _, icon = GetMacroInfo(idx)
		return icon or 134400
	end
end

local function UpdateCooldown(b)
	local c, cd = b.content, b.cd
	if not c then return end
	local spell = (c.t == "spell" and c.id) or (c.t == "macro" and MacroSpell(c)) or nil
	if spell then
		-- 게임이 주는 "지속시간 객체"를 그대로 넘긴다 (값을 들여다보지 않으므로 전투 중에도 됨)
		if C_Spell.GetSpellCooldownDuration and cd.SetCooldownFromDurationObject then
			local ok, obj = pcall(C_Spell.GetSpellCooldownDuration, spell)
			if ok and obj and pcall(cd.SetCooldownFromDurationObject, cd, obj) then return end
		end
		local ok, info = pcall(C_Spell.GetSpellCooldown, spell)
		if ok and type(info) == "table" then
			pcall(cd.SetCooldown, cd, info.startTime, info.duration, info.modRate)
		end
	elseif c.t == "item" then
		local get = (C_Container and C_Container.GetItemCooldown) or (C_Item and C_Item.GetItemCooldown)
		if get then
			local ok, start, duration = pcall(get, c.id)
			if ok and start ~= nil then pcall(cd.SetCooldown, cd, start, duration) end
		end
	else
		cd:Clear()
	end
end

local function UpdateCount(b)
	local c = b.content
	local text = ""
	if c and c.t == "item" then
		local ok, n = pcall(C_Item.GetItemCount, c.id, false, true)
		if ok and n and not isSecret(n) then
			b.itemCount = n
			if n > 1 then text = (n > 9999) and "*" or tostring(n) end
		end
	elseif c and c.t == "spell" and C_Spell.GetSpellDisplayCount then
		local ok, n = pcall(C_Spell.GetSpellDisplayCount, c.id)
		if ok and n then text = n end
	end
	if not pcall(b.count.SetText, b.count, text) then b.count:SetText("") end
end

local function UpdateState(b)
	local c = b.content
	if not c then return end
	local spell = (c.t == "spell" and c.id) or (c.t == "macro" and MacroSpell(c)) or nil
	if spell then
		local ok, usable, noMana = pcall(C_Spell.IsSpellUsable, spell)
		if ok and not isSecret(usable) and not isSecret(noMana) then
			if usable then b.icon:SetVertexColor(1, 1, 1)
			elseif noMana then b.icon:SetVertexColor(0.5, 0.5, 1)
			else b.icon:SetVertexColor(0.4, 0.4, 0.4) end
		end
		local ok2, cur = pcall(C_Spell.IsCurrentSpell, spell)
		if ok2 and not isSecret(cur) then b:SetChecked(cur and true or false) end
	elseif c.t == "item" then
		if b.itemCount == 0 then b.icon:SetVertexColor(0.4, 0.4, 0.4) else b.icon:SetVertexColor(1, 1, 1) end
		b:SetChecked(false)
	else
		b.icon:SetVertexColor(1, 1, 1)
		b:SetChecked(false)
	end
end

local function UpdateButton(b)
	local c = b.content
	b.has = c and true or false
	if c then
		local ok, tex = pcall(ContentTexture, c)
		b.icon:SetTexture((ok and tex) or 134400)
		b.icon:Show()
	else
		b.icon:Hide()
		b.cd:Clear()
		b.count:SetText("")
		b:SetChecked(false)
	end
	b.hotkey:SetText(ShortKey(GetBindingKey and GetBindingKey(b.command)))
	if c then
		UpdateCount(b)
		UpdateCooldown(b)
		UpdateState(b)
	end
end

local function UpdateFrame(b, cursor)
	-- 테두리는 빈 칸에만 (기술이 들어 있으면 아이콘만 보임). 상태를 믿지 않고 매번 다시 맞춘다.
	local show = (not b.has and (db.grid or cursor)) and true or false
	b.bg:SetShown(show)
	for _, t in ipairs(b.edge) do t:SetShown(show) end
end

-- 버튼 내용을 보안 버튼에 반영 (전투 중에는 못 바꿈)
local function ApplyContent(b, c)
	b.content = c
	b.itemCount = nil
	local t, spell, item, macro
	if c then
		if c.t == "spell" then t, spell = "spell", c.id
		elseif c.t == "item" then t, item = "item", "item:" .. c.id
		elseif c.t == "macro" then
			macro = MacroIndex(c)
			if macro then t = "macro" end
		end
	end
	b:SetAttribute("type", t)
	b:SetAttribute("spell", spell)
	b:SetAttribute("item", item)
	b:SetAttribute("macro", macro)
end

-- 주문 툴팁: 스킬북에서 볼 때와 같은 내용(배운 스킬 레벨 포함)이 나오도록 스킬북 칸으로 먼저 띄운다.
-- 스킬북에서 못 찾으면 주문 번호로 띄운다.
ShowSpellTooltip = function(c)
	local tip = GameTooltip
	local find = C_SpellBook and C_SpellBook.FindSpellBookSlotForSpell
	if find and tip.SetSpellBookItem then
		for _, id in ipairs({ c.sid or false, c.id or false }) do
			if id then
				local ok, slot, bank = pcall(find, id)
				if ok and slot and pcall(tip.SetSpellBookItem, tip, slot, bank) and (tip:NumLines() or 0) > 0 then
					return
				end
			end
		end
	end
	local id = c.sid or c.id
	if C_Spell.GetOverrideSpell then
		local ok, ov = pcall(C_Spell.GetOverrideSpell, c.id)
		if ok and ov and not isSecret(ov) and ov ~= 0 then id = c.sid or ov end
	end
	pcall(tip.SetSpellByID, tip, id)
end -- ShowSpellTooltip

local buttons = {}

-- 커서에 들고 있는 기술/아이템/매크로를 i번 버튼에 넣는다
local function ReceiveCursor(i)
	if InCombatLockdown() then return end
	local kind, a1, _, a3, a4 = GetCursorInfo()
	local c
	if kind == "spell" then
		local id = a4 or a3
		-- id = 기본 주문 번호(시전·아이콘용), sid = 지금 배운 그대로의 주문 번호(툴팁용)
		if id then c = { t = "spell", id = id, sid = a3 } end
	elseif kind == "item" then
		if a1 then c = { t = "item", id = a1 } end
	elseif kind == "macro" then
		local name = a1 and GetMacroInfo(a1)
		if name then c = { t = "macro", id = a1, name = name } end
	end
	if not c then
		if kind then Print(L.CANT_PLACE) end
		return
	end
	ClearCursor()
	SetContent(i, c)
	ApplyContent(buttons[i], c)
	UpdateButton(buttons[i])
end

-- 커서에 뭔가 들고 있을 때만 버튼 위에 뜨는 "받는 판". 보안 버튼이 직접 받으면 그 순간 기술이 써져 버린다.
local catchers = {}

for i = 1, NUM_BUTTONS do
	local name = "CenterBarButton" .. i
	local b = CreateFrame("CheckButton", name, bar, "SecureActionButtonTemplate")
	b:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	b:SetFrameLevel(bar:GetFrameLevel() + 2)
	b:SetAttribute("checkselfcast", true)
	b:SetAttribute("checkfocuscast", true)
	b:RegisterForClicks("AnyUp", "AnyDown")
	b:RegisterForDrag("LeftButton")
	b:SetScript("OnDragStart", NoOp)
	SecureHandlerWrapScript(b, "OnDragStart", bar, DRAG_START)
	-- 끌어 빼면(커서에 들리면) 버튼을 비운다
	b:HookScript("OnDragStart", function(self)
		if InCombatLockdown() or not self.content then return end
		if GetCursorInfo() then
			SetContent(i, nil)
			ApplyContent(self, nil)
			UpdateButton(self)
		end
	end)

	-- 빈 칸 테두리: 예전 센터바와 같은 게임 기본 퀵슬롯 테두리를 옅게
	b.bg = b:CreateTexture(nil, "BACKGROUND")
	b.bg:SetAllPoints()
	b.bg:SetColorTexture(0, 0, 0, 0)
	local slotTex = b:CreateTexture(nil, "BORDER")
	slotTex:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	slotTex:SetPoint("TOPLEFT", -14, 14)
	slotTex:SetPoint("BOTTOMRIGHT", 15, -15)
	slotTex:SetAlpha(0.45)
	b.edge = { slotTex }

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

	b:SetScript("PostClick", function(self)
		if self.content then UpdateState(self) else self:SetChecked(false) end
	end)
	b:SetScript("OnEnter", function(self)
		local c = self.content
		if db and db.tooltips and c then
			if GameTooltip_SetDefaultAnchor then GameTooltip_SetDefaultAnchor(GameTooltip, self)
			else GameTooltip:SetOwner(self, "ANCHOR_RIGHT") end
			if c.t == "spell" then ShowSpellTooltip(c)
			elseif c.t == "item" then pcall(GameTooltip.SetItemByID, GameTooltip, c.id)
			else GameTooltip:SetText(c.name or "") end
			GameTooltip:Show()
		end
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- 단축키: Bindings.xml의 CLICK 바인딩과 같은 이름
	b.command = "CLICK " .. name .. ":LeftButton"
	_G["BINDING_NAME_" .. b.command] = L.BUTTON:format(i)
	buttons[i] = b

	local catch = CreateFrame("Button", nil, UIParent)
	catch:SetAllPoints(b)
	catch:SetFrameStrata("HIGH")
	catch:RegisterForClicks("AnyUp")
	catch:SetScript("OnClick", function() ReceiveCursor(i) end)
	catch:SetScript("OnReceiveDrag", function() ReceiveCursor(i) end)
	catch:Hide()
	catchers[i] = catch
end
BINDING_HEADER_CENTERBAR = L.TITLE
BINDING_NAME_CENTERBAR_NEXTSLOT = L.NEXT_SLOT

local function UpdateCatchers(cursor)
	local on = cursor and not InCombatLockdown()
	for i, c in ipairs(catchers) do
		local show = (on and buttons[i]:IsVisible()) and true or false
		if c:IsShown() ~= show then c:SetShown(show) end
	end
end

local function UpdateAllButtons()
	if not db then return end
	local cursor = GetCursorInfo and GetCursorInfo() and true or false
	for _, b in ipairs(buttons) do
		UpdateButton(b)
		UpdateFrame(b, cursor)
	end
end

-- 예전 버전에서 액션바 칸에 넣어 둔 기술을 한 번만 가져온다 (이미 채운 버튼은 건드리지 않음)
local function ImportOld()
	if db.imported or InCombatLockdown() or not GetActionInfo then return end
	for slot, from in ipairs(IMPORT_FROM) do
		for i = 1, NUM_BUTTONS do
			if not Content(i, slot) then
				local action = (i <= 12) and (from[1] + i - 1) or (from[2] + i - 13)
				local ok, t, id = pcall(GetActionInfo, action)
				if ok and id and not isSecret(id) then
					if t == "spell" or t == "item" then
						SetContent(i, { t = t, id = id }, slot)
					elseif t == "macro" then
						local name = GetMacroInfo(id)
						if name then SetContent(i, { t = "macro", id = id, name = name }, slot) end
					end
				end
			end
		end
	end
	db.imported = true
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
		b:SetAttribute("cb-lock", lock and true or nil)
		ApplyContent(b, Content(i, slot))
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
	if not db then return end
	local cursor = GetCursorInfo and GetCursorInfo() and true or false
	if cursor ~= self.cursor then
		self.cursor = cursor
		UpdateCatchers(cursor)
	end
	self.t = (self.t or 0) + elapsed
	if self.t < 0.2 then return end
	self.t = 0
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
	"PLAYER_ENTERING_WORLD", "ACTIONBAR_UPDATE_COOLDOWN", "ACTIONBAR_UPDATE_STATE", "ACTIONBAR_UPDATE_USABLE",
	"SPELL_UPDATE_COOLDOWN", "SPELL_UPDATE_CHARGES", "SPELL_UPDATE_USABLE", "SPELL_UPDATE_ICON", "SPELLS_CHANGED",
	"UPDATE_BINDINGS", "BAG_UPDATE_DELAYED", "BAG_UPDATE_COOLDOWN", "PLAYER_EQUIPMENT_CHANGED", "UPDATE_SHAPESHIFT_FORM",
	"PLAYER_TARGET_CHANGED", "CURRENT_SPELL_CAST_CHANGED",
}) do
	pcall(watch.RegisterEvent, watch, e)
end
watch:SetScript("OnEvent", UpdateAllButtons)

---------------------------------------------------------------------------
-- 미니맵 버튼: 왼쪽 클릭 = 설정 창, 오른쪽 클릭 = 다음 슬롯, 드래그 = 둘레를 따라 옮기기
---------------------------------------------------------------------------
local mm = CreateFrame("Button", "CenterBarMinimapButton", Minimap)
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
mm.icon:SetTexture("Interface\\AddOns\\CenterBar\\icon")
mm.icon:SetSize(18, 18)
mm.icon:SetPoint("TOPLEFT", 7, -6)
mm.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
mm.border = mm:CreateTexture(nil, "OVERLAY")
mm.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
mm.border:SetSize(53, 53)
mm.border:SetPoint("TOPLEFT")

local function UpdateMinimap()
	if not db then return end
	mm:SetShown(not db.minimapHide)
	local a = math.rad(db.minimapAngle or 215)
	local r = (Minimap:GetWidth() or 140) / 2 + 5
	mm:ClearAllPoints()
	mm:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
end

mm:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", function()
		local mx, my = Minimap:GetCenter()
		local cx, cy = GetCursorPosition()
		local s = Minimap:GetEffectiveScale()
		if not mx or not s or s == 0 then return end
		db.minimapAngle = math.deg(math.atan2(cy / s - my, cx / s - mx))
		UpdateMinimap()
	end)
end)
mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
mm:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine(L.TITLE)
	GameTooltip:AddLine(L.MM_LEFT, 1, 1, 1)
	GameTooltip:AddLine(L.MM_RIGHT, 1, 1, 1)
	GameTooltip:AddLine(L.MM_DRAG, 1, 1, 1)
	GameTooltip:Show()
end)
mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
mm:Hide()

---------------------------------------------------------------------------
-- 공개 API (설정 창, hyveo 애드온 센터에서 사용)
---------------------------------------------------------------------------
local function SetSlot(s)
	if not db or type(s) ~= "number" or s < 1 or s > NUM_SLOTS or s ~= math.floor(s) then return end
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
		quiet = db.quiet and true or false
		UpdateMinimap()
		quiet = db.quiet and true or false
		ApplyAll()
	end,
	GetSlot = function() return db and CurrentSlot() or 1 end,
	SetSlot = SetSlot,
	NextSlot = function() SetSlot(CurrentSlot() % NUM_SLOTS + 1) end,
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
		local sets, specSlot = db.sets, db.specSlot -- 버튼에 넣은 기술은 지우지 않는다
		wipe(db)
		CopyDefaults(db, DEFAULTS)
		db.sets, db.specSlot, db.imported = sets, specSlot, true
		quiet = false
		UpdateMinimap()
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

mm:SetScript("OnClick", function(_, button)
	if button == "RightButton" then CenterBar.NextSlot() else CenterBar.ToggleOptions() end
end)

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
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("UPDATE_MACROS")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON_NAME then return end
		CenterBarDB = CenterBarDB or {}
		db = CenterBarDB
		CopyDefaults(db, DEFAULTS)
		Migrate()
		EnsurePositions()
	elseif event == "PLAYER_LOGIN" then
		UpdateMinimap()
		ApplyAll()
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- 액션바 정보는 이때부터 읽을 수 있다
		if db and not db.imported and not InCombatLockdown() then
			ImportOld()
			ApplyAll()
		end
	elseif event == "UPDATE_MACROS" then
		-- 매크로 순서가 바뀌면 번호가 달라지므로 이름으로 다시 찾는다
		if db and not InCombatLockdown() then ApplyLayout() else pending = true end
	elseif event == "PLAYER_REGEN_DISABLED" then
		UpdateCatchers(false)
	elseif event == "PLAYER_REGEN_ENABLED" then
		if db and not db.imported then ImportOld() pending = true end
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
		if n >= 1 and n <= NUM_SLOTS then SetSlot(n) else Print(L.HELP, true) end
	elseif msg == "next" or msg == "다음" then
		CenterBar.NextSlot()
	elseif msg == "lock" or msg == "잠금" then
		CenterBar.SetLocked(not db.locked)
	elseif msg == "reset" or msg == "초기화" then
		CenterBar.Reset()
	else
		Print(L.HELP, true)
	end
end
