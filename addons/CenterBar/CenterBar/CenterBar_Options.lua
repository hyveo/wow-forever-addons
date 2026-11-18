-- 센터바 설정 창 — @hyveo

local L2
if GetLocale() == "koKR" then
	L2 = {
		TITLE      = "센터바 설정",
		BASIC      = "기본 설정",
		LAYOUT     = "배치 (템플릿)",
		COUNT      = "표시 개수",
		COUNT_FMT  = "%d개",
		DETAIL     = "세부 옵션",
		SCALE      = "배율: %d%%",
		ALPHA      = "투명도: %d%%",
		STEP       = "이동간격: %d",
		SLOT       = "슬롯 (지금 특성)",
		PAGE_MAIN  = "이 슬롯 페이지 (버튼 1~12): %d",
		PAGE_EXTRA = "추가 버튼(13~18) 페이지: %d",
		POS_Y      = "세로 위치",
		POS_X      = "가로 위치",
		MIRROR     = "대칭 이동",
		COMBAT     = "전투 시 투명도 복구",
		TARGET     = "대상 선택 시 복구",
		MOUSEOVER  = "마우스오버 시 복구",
		NOTIP      = "툴팁 숨김",
		VEHICLE    = "탈것 탑승 시 숨김",
		MOUNT      = "  - 일반 탈것 포함",
		GRID       = "빈 버튼 항상 표시",
		LOCK       = "위치 잠금 (손잡이 숨김)",
		RESET      = "처음으로",
		CLOSE      = "닫기 (ESC)",
		CENTER     = "CENTER",
		TIP1       = "화면 격자에서 번호 칸을 끌면 버튼이, CENTER 칸을 끌면 전체가 위아래로 움직여요.",
		TIP2       = "슬롯 1 = 예전 센터바와 같은 칸(2페이지 + 10페이지). 단축키: 게임 메뉴 → 단축키 설정 → 애드온",
	}
else
	L2 = {
		TITLE      = "CenterBar options",
		BASIC      = "Basics",
		LAYOUT     = "Layout (templates)",
		COUNT      = "Buttons shown",
		COUNT_FMT  = "%d",
		DETAIL     = "Details",
		SCALE      = "Scale: %d%%",
		ALPHA      = "Opacity: %d%%",
		STEP       = "Grid step: %d",
		SLOT       = "Slot (this spec)",
		PAGE_MAIN  = "Slot page (buttons 1–12): %d",
		PAGE_EXTRA = "Extra buttons (13–18) page: %d",
		POS_Y      = "Vertical",
		POS_X      = "Horizontal",
		MIRROR     = "Mirror moves",
		COMBAT     = "Full opacity in combat",
		TARGET     = "Full opacity with a target",
		MOUSEOVER  = "Full opacity on mouseover",
		NOTIP      = "Hide tooltips",
		VEHICLE    = "Hide in vehicles",
		MOUNT      = "  - also when mounted",
		GRID       = "Always show empty buttons",
		LOCK       = "Lock position (hide handle)",
		RESET      = "Reset",
		CLOSE      = "Close (ESC)",
		CENTER     = "CENTER",
		TIP1       = "Drag numbered boxes on the grid to move buttons; drag CENTER to move everything up/down.",
		TIP2       = "Slot 1 = same slots as the old CentarBar (page 2 + page 10). Keybinds: Game Menu → Keybindings → AddOns",
	}
end

local f = CreateFrame("Frame", "CenterBarOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(470, 520)
f:SetPoint("LEFT", 40, 0)
f:SetFrameStrata("DIALOG")
f:SetClampedToScreen(true)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()
tinsert(UISpecialFrames, "CenterBarOptionsFrame")

f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.title:SetPoint("TOP", 0, -6)
f.title:SetText(L2.TITLE)

local refreshers = {}
local refreshing = false
local function Refresh()
	refreshing = true
	for _, fn in ipairs(refreshers) do fn() end
	refreshing = false
end

local LEFT, RIGHT = 20, 250

local function Header(text, x, y)
	local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fs:SetPoint("TOPLEFT", x, y)
	fs:SetText(text)
	return fs
end

-- 슬라이더 (마우스 휠로도 조절). 템플릿이 없는 클라이언트에서도 뜨도록 순서대로 시도한다.
local sliderCount = 0
local function Slider(fmt, y, minV, maxV, getter, setter)
	sliderCount = sliderCount + 1
	local name = "CenterBarOptionsSlider" .. sliderCount
	local ok, sl = pcall(CreateFrame, "Slider", name, f, "OptionsSliderTemplate")
	if not ok or not sl then ok, sl = pcall(CreateFrame, "Slider", name, f, "UISliderTemplate") end
	if not ok or not sl then
		sl = CreateFrame("Slider", name, f)
		sl:SetOrientation("HORIZONTAL")
		sl:SetHeight(16)
		local bg = sl:CreateTexture(nil, "BACKGROUND")
		bg:SetColorTexture(0, 0, 0, 0.5)
		bg:SetPoint("LEFT") bg:SetPoint("RIGHT") bg:SetHeight(6)
		sl:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	end
	sl:SetWidth(190)
	sl:SetPoint("TOPLEFT", LEFT, y)
	sl:SetMinMaxValues(minV, maxV)
	sl:SetValueStep(1)
	if sl.SetObeyStepOnDrag then sl:SetObeyStepOnDrag(true) end
	sl:EnableMouseWheel(true)
	for _, suffix in ipairs({ "Text", "Low", "High" }) do
		local r = _G[name .. suffix]
		if r then r:SetText("") end
	end
	local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	title:SetPoint("BOTTOM", sl, "TOP", 0, 3)
	sl:SetScript("OnValueChanged", function(self, value)
		value = math.floor(value + 0.5)
		title:SetText(fmt:format(value))
		if not refreshing and value ~= getter() then setter(value) end
	end)
	sl:SetScript("OnMouseWheel", function(self, delta)
		self:SetValue(math.max(minV, math.min(maxV, getter() + delta)))
	end)
	refreshers[#refreshers + 1] = function()
		local v = getter()
		sl:SetValue(v)
		title:SetText(fmt:format(v))
	end
	return sl
end

local function Check(label, key, y, invert)
	local c = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
	c:SetSize(24, 24)
	c:SetPoint("TOPLEFT", RIGHT - 4, y)
	local fs = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fs:SetPoint("LEFT", c, "RIGHT", 2, 1)
	fs:SetText(label)
	c.label = fs
	c:SetScript("OnClick", function(self)
		local v = self:GetChecked() and true or false
		if invert then v = not v end
		if key == "locked" then CenterBar.SetLocked(v) else CenterBar.Set(key, v) end
		Refresh()
	end)
	refreshers[#refreshers + 1] = function()
		local v = CenterBar.Get(key) and true or false
		if invert then v = not v end
		c:SetChecked(v)
	end
	return c
end

-- 한 줄짜리 고르기 버튼들
local function Buttons(x, y, width, perRow, items, getter, setter)
	local btns = {}
	for i, it in ipairs(items) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetSize(width, 22)
		b:SetPoint("TOPLEFT", x + ((i - 1) % perRow) * (width + 4), y - math.floor((i - 1) / perRow) * 24)
		b:SetText(it.text)
		b:SetScript("OnClick", function() setter(it.value) Refresh() end)
		btns[i] = b
	end
	refreshers[#refreshers + 1] = function()
		local cur = getter()
		for i, it in ipairs(items) do btns[i]:SetEnabled(cur ~= it.value) end
	end
end

local function Nudger(label, y, dx, dy)
	local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fs:SetPoint("TOPLEFT", LEFT, y - 5)
	fs:SetText(label)
	local minus = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	minus:SetSize(28, 22)
	minus:SetPoint("TOPLEFT", LEFT + 100, y)
	minus:SetText("-")
	minus:SetScript("OnClick", function() CenterBar.Nudge(-dx, -dy) Refresh() end)
	local plus = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	plus:SetSize(28, 22)
	plus:SetPoint("LEFT", minus, "RIGHT", 4, 0)
	plus:SetText("+")
	plus:SetScript("OnClick", function() CenterBar.Nudge(dx, dy) Refresh() end)
end

---------------------------------------------------------------------------
-- 왼쪽: 기본 설정
---------------------------------------------------------------------------
Header(L2.BASIC, LEFT, -34)
Slider(L2.SCALE, -72, 70, 200,
	function() return math.floor((CenterBar.Get("scale") or 1) * 100 + 0.5) end,
	function(v) CenterBar.Set("scale", v / 100) end)
Slider(L2.ALPHA, -118, 0, 100,
	function() return math.floor((CenterBar.Get("alpha") or 1) * 100 + 0.5) end,
	function(v) CenterBar.Set("alpha", v / 100) end)
Slider(L2.STEP, -164, 2, 20,
	function() return CenterBar.Get("step") or 10 end,
	function(v) CenterBar.Set("step", v) Refresh() end)

Header(L2.SLOT, LEFT, -196)
do
	local items = {}
	for i = 1, CenterBar.NUM_SLOTS do items[i] = { text = CenterBar.L.SLOT:format(i), value = i } end
	Buttons(LEFT, -214, 60, 3, items, CenterBar.GetSlot, CenterBar.SetSlot)
end
Slider(L2.PAGE_MAIN, -264, 1, 15,
	function() return CenterBar.GetSlotPage("main") end,
	function(v) CenterBar.SetSlotPage("main", v) end)
Slider(L2.PAGE_EXTRA, -310, 1, 15,
	function() return CenterBar.GetSlotPage("extra") end,
	function(v) CenterBar.SetSlotPage("extra", v) end)

Nudger(L2.POS_Y, -344, 0, 1)
Nudger(L2.POS_X, -370, 1, 0)

---------------------------------------------------------------------------
-- 오른쪽: 배치, 표시 개수, 세부 옵션
---------------------------------------------------------------------------
Header(L2.LAYOUT, RIGHT, -34)
do
	local items = {}
	for i = 1, CenterBar.NUM_PRESETS do items[i] = { text = CenterBar.L.PRESETS[i], value = i } end
	Buttons(RIGHT, -52, 98, 2, items,
		function() return CenterBar.Get("preset") end,
		function(v) CenterBar.Set("preset", v) end)
end

Header(L2.COUNT, RIGHT, -130)
Buttons(RIGHT, -148, 64, 3, {
	{ text = L2.COUNT_FMT:format(6), value = 6 },
	{ text = L2.COUNT_FMT:format(12), value = 12 },
	{ text = L2.COUNT_FMT:format(18), value = 18 },
}, function() return CenterBar.Get("count") end, function(v) CenterBar.Set("count", v) end)

Header(L2.DETAIL, RIGHT, -182)
Check(L2.MIRROR, "mirror", -198)
Check(L2.COMBAT, "combat", -222)
Check(L2.TARGET, "target", -246)
Check(L2.MOUSEOVER, "mouseover", -270)
Check(L2.NOTIP, "tooltips", -294, true)
Check(L2.VEHICLE, "vehiclehide", -318)
local mountCheck = Check(L2.MOUNT, "mounthide", -342)
refreshers[#refreshers + 1] = function()
	local on = CenterBar.Get("vehiclehide") and true or false
	mountCheck:SetEnabled(on)
	mountCheck.label:SetTextColor(on and 1 or 0.5, on and 1 or 0.5, on and 1 or 0.5)
end
Check(L2.GRID, "grid", -366)
Check(L2.LOCK, "locked", -390)

local tip1 = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
tip1:SetPoint("BOTTOMLEFT", 18, 64)
tip1:SetWidth(434) tip1:SetJustifyH("LEFT")
tip1:SetText(L2.TIP1)
local tip2 = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
tip2:SetPoint("BOTTOMLEFT", 18, 40)
tip2:SetWidth(434) tip2:SetJustifyH("LEFT")
tip2:SetText(L2.TIP2)

local reset = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
reset:SetSize(100, 24)
reset:SetPoint("BOTTOM", -56, 12)
reset:SetText(L2.RESET)
reset:SetScript("OnClick", function() CenterBar.Reset(); Refresh() end)
local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
close:SetSize(100, 24)
close:SetPoint("BOTTOM", 56, 12)
close:SetText(L2.CLOSE)
close:SetScript("OnClick", function() f:Hide() end)

---------------------------------------------------------------------------
-- 위치 편집: 설정 창이 열려 있는 동안 화면 전체 격자 + 끌어 옮기는 번호 칸
---------------------------------------------------------------------------
local edit = CreateFrame("Frame", "CenterBarEditFrame", UIParent)
edit:SetSize(10, 10)
edit:SetFrameStrata("HIGH")
edit:Hide()

local LINES = 60
local vlines, hlines = {}, {}
for i = -LINES, LINES do
	local a = (i == 0) and 0.9 or (i % 5 == 0) and 0.55 or 0.28
	local r = (i == 0) and 1 or 0
	vlines[i] = edit:CreateTexture(nil, "BACKGROUND")
	vlines[i]:SetColorTexture(r, r, r, a)
	hlines[i] = edit:CreateTexture(nil, "BACKGROUND")
	hlines[i]:SetColorTexture(r, r, r, a)
end

local markers = {}
local function CursorCell()
	local cx, cy = GetCursorPosition()
	local s = edit:GetEffectiveScale()
	local bx, by = edit:GetCenter()
	local step = CenterBar.Get("step") or 10
	if not bx then return 0, 0 end
	return math.floor((cx / s - bx) / step + 0.5), math.floor((cy / s - by) / step + 0.5)
end

local function Partner(i)
	local x, y = CenterBar.GetPos(i)
	for j = 1, CenterBar.NUM_BUTTONS do
		if j ~= i then
			local jx, jy = CenterBar.GetPos(j)
			if jx == -x and jy == y then return j end
		end
	end
end

local function RefreshEdit()
	if not edit:IsShown() then return end
	local step = CenterBar.Get("step") or 10
	edit:SetScale(CenterBar.Get("scale") or 1)
	edit:ClearAllPoints()
	edit:SetPoint("CENTER", CenterBarFrame, "CENTER")
	for i = -LINES, LINES do
		local c = i * step * 2
		local w = (i == 0) and 2 or 1
		vlines[i]:ClearAllPoints()
		vlines[i]:SetSize(w, 6000)
		vlines[i]:SetPoint("CENTER", edit, "CENTER", c, 0)
		hlines[i]:ClearAllPoints()
		hlines[i]:SetSize(6000, w)
		hlines[i]:SetPoint("CENTER", edit, "CENTER", 0, c)
	end
	for i, m in ipairs(markers) do
		local x, y = CenterBar.GetPos(i)
		if x then
			m:ClearAllPoints()
			m:SetPoint("CENTER", edit, "CENTER", x * step, y * step)
			m.text:SetText(i .. "\n" .. x .. "." .. y)
			m:SetShown(CenterBar.IsButtonShown(i))
		end
	end
end

for i = 1, CenterBar.NUM_BUTTONS do
	local m = CreateFrame("Button", nil, edit)
	m:SetSize(36, 36)
	m.bg = m:CreateTexture(nil, "ARTWORK")
	m.bg:SetAllPoints()
	if i > 12 then m.bg:SetColorTexture(0.1, 0.8, 0.3, 0.5) else m.bg:SetColorTexture(0, 0.4, 1, 0.5) end
	m.text = m:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	m.text:SetPoint("CENTER")
	m:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		self.partner = CenterBar.Get("mirror") and Partner(i) or nil
		self:SetScript("OnUpdate", function()
			local x, y = CursorCell()
			local ox, oy = CenterBar.GetPos(i)
			if x ~= ox or y ~= oy then
				CenterBar.SetPos(i, x, y)
				if self.partner then CenterBar.SetPos(self.partner, -x, y) end
				Refresh()
			end
		end)
	end)
	m:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
	m:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
	markers[i] = m
end
-- CENTER 칸: 끌면 바 전체가 위아래로 움직인다
local center = CreateFrame("Button", nil, edit)
center:SetSize(60, 36)
center:SetPoint("CENTER")
center.bg = center:CreateTexture(nil, "ARTWORK")
center.bg:SetAllPoints()
center.bg:SetColorTexture(0, 0, 1, 0.5)
center.text = center:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
center.text:SetPoint("CENTER")
center.text:SetText(L2.CENTER)
center:SetScript("OnMouseDown", function(self)
	if InCombatLockdown() then return end
	self:SetScript("OnUpdate", function()
		local _, y = CursorCell()
		if y ~= 0 and math.abs(y) < 200 then
			CenterBar.Nudge(0, y * (CenterBar.Get("step") or 10))
		end
	end)
end)
center:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
center:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)

refreshers[#refreshers + 1] = RefreshEdit

-- 전투 중에는 버튼을 옮길 수 없으니 격자를 숨긴다
edit:RegisterEvent("PLAYER_REGEN_DISABLED")
edit:RegisterEvent("PLAYER_REGEN_ENABLED")
edit:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		self:Hide()
	elseif f:IsShown() then
		self:Show()
		Refresh()
	end
end)

f:SetScript("OnShow", function()
	if not InCombatLockdown() then edit:Show() end
	Refresh()
end)
f:SetScript("OnHide", function() edit:Hide() end)

CenterBarOptions = {
	Toggle = function() f:SetShown(not f:IsShown()) end,
	Refresh = function() if f:IsShown() then Refresh() end end,
}
