-- 센터바 설정 창 — @hyveo

local L2
if GetLocale() == "koKR" then
	L2 = {
		TITLE      = "센터바 설정",
		COUNT      = "표시 개수",
		VIS        = "보이기",
		VIS_ALWAYS = "항상",
		VIS_COMBAT = "전투 중에만",
		VIS_MOUSE  = "마우스 올렸을 때",
		SCALE      = "크기",
		ALPHA      = "투명도",
		PRESET     = "배치",
		GAP        = "퍼짐 (간격)",
		SLOT       = "슬롯 (지금 특성)",
		GRID       = "빈 칸도 테두리 보이기",
		TOOLTIPS   = "버튼 툴팁 보이기",
		LOCK       = "위치 잠금",
		RESET      = "처음으로",
		BINDINGS   = "단축키: 게임 메뉴 → 단축키 설정 → 애드온 → 센터바",
		SLOT_TIP   = "슬롯마다 넣은 기술이 따로 저장돼요. 슬롯 1 = 예전 센터바와 같은 칸",
		SLOT_TIP2  = "슬롯 2·3은 기본 UI 액션바 6~8과 칸을 같이 써요. 단축키로도 바꿀 수 있어요.",
	}
else
	L2 = {
		TITLE      = "CenterBar options",
		COUNT      = "Buttons shown",
		VIS        = "Show",
		VIS_ALWAYS = "Always",
		VIS_COMBAT = "In combat",
		VIS_MOUSE  = "On mouseover",
		SCALE      = "Scale",
		ALPHA      = "Opacity",
		PRESET     = "Layout",
		GAP        = "Spread",
		SLOT       = "Slot (this spec)",
		GRID       = "Show borders on empty slots",
		TOOLTIPS   = "Show button tooltips",
		LOCK       = "Lock position",
		RESET      = "Reset",
		BINDINGS   = "Keybinds: Game Menu → Keybindings → AddOns → CenterBar",
		SLOT_TIP   = "Each slot keeps its own spells. Slot 1 = same as the old CentarBar",
		SLOT_TIP2  = "Slots 2–3 share slots with default action bars 6–8. You can bind a key too.",
	}
end

local f = CreateFrame("Frame", "CenterBarOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(420, 520)
f:SetPoint("CENTER")
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
local function Refresh()
	for _, fn in ipairs(refreshers) do fn() end
end

local y = -40
local function Label(text, size)
	local fs = f:CreateFontString(nil, "OVERLAY", size or "GameFontNormal")
	fs:SetPoint("TOPLEFT", 20, y)
	fs:SetText(text)
	return fs
end

-- 여러 값 중 하나 고르는 버튼 줄
local function Choice(label, key, options, getter, setter)
	Label(label)
	local btns = {}
	for i, opt in ipairs(options) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetSize(100, 22)
		b:SetPoint("TOPLEFT", 150 + (i - 1) * 84, y + 4)
		b:SetWidth(80)
		b:SetText(opt.text)
		b:SetScript("OnClick", function()
			if setter then setter(opt.value) else CenterBar.Set(key, opt.value) end
			Refresh()
		end)
		btns[i] = b
	end
	refreshers[#refreshers + 1] = function()
		local cur = getter and getter() or CenterBar.Get(key)
		for i, opt in ipairs(options) do
			btns[i]:SetEnabled(cur ~= opt.value)
		end
	end
	y = y - 32
end

-- - 값 + 버튼
local function Stepper(label, getter, setter, step, minV, maxV, fmt, x)
	local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fs:SetPoint("TOPLEFT", x or 20, y)
	fs:SetText(label)
	local minus = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	minus:SetSize(24, 22)
	minus:SetPoint("TOPLEFT", (x or 20) + 130, y + 4)
	minus:SetText("-")
	local val = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	val:SetPoint("LEFT", minus, "RIGHT", 6, 0)
	val:SetWidth(44)
	local plus = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	plus:SetSize(24, 22)
	plus:SetPoint("LEFT", val, "RIGHT", 6, 0)
	plus:SetText("+")
	local function change(d)
		local v = getter() + d
		v = math.max(minV, math.min(maxV, math.floor(v / step + 0.5) * step))
		setter(v)
		Refresh()
	end
	minus:SetScript("OnClick", function() change(-step) end)
	plus:SetScript("OnClick", function() change(step) end)
	refreshers[#refreshers + 1] = function()
		val:SetText((fmt or "%s"):format(getter()))
	end
end

local function Check(label, key)
	local c = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
	c:SetSize(24, 24)
	c:SetPoint("TOPLEFT", 16, y + 4)
	local fs = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fs:SetPoint("LEFT", c, "RIGHT", 4, 1)
	fs:SetText(label)
	c:SetScript("OnClick", function(self)
		if key == "locked" then
			CenterBar.SetLocked(self:GetChecked())
		else
			CenterBar.Set(key, self:GetChecked() and true or false)
		end
		Refresh()
	end)
	refreshers[#refreshers + 1] = function() c:SetChecked(CenterBar.Get(key) and true or false) end
	y = y - 28
end

-- 배치 고르기 (버튼 5개를 한 줄에)
do
	Label(L2.PRESET)
	y = y - 22
	local btns = {}
	for i = 1, CenterBar.NUM_PRESETS do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetSize(74, 22)
		b:SetPoint("TOPLEFT", 18 + (i - 1) * 77, y + 4)
		b:SetText(CenterBar.L.PRESETS[i])
		b:SetScript("OnClick", function() CenterBar.Set("preset", i) Refresh() end)
		btns[i] = b
	end
	refreshers[#refreshers + 1] = function()
		for i, b in ipairs(btns) do b:SetEnabled(CenterBar.Get("preset") ~= i) end
	end
	y = y - 34
end

Choice(L2.COUNT, "count", { { text = "6", value = 6 }, { text = "12", value = 12 }, { text = "18", value = 18 } })
Choice(L2.VIS, "visibility", {
	{ text = L2.VIS_ALWAYS, value = "always" },
	{ text = L2.VIS_COMBAT, value = "combat" },
	{ text = L2.VIS_MOUSE,  value = "mouseover" },
})

local function num(key) return function() return CenterBar.Get(key) or 0 end end
local function set(key) return function(v) CenterBar.Set(key, v) end end
Stepper(L2.SCALE, num("scale"), set("scale"), 0.05, 0.5, 2.0, "%.2f")
y = y - 30
Stepper(L2.ALPHA, num("alpha"), set("alpha"), 0.1, 0.1, 1.0, "%.1f")
y = y - 30
Stepper(L2.GAP, num("step"), set("step"), 1, 6, 16, "%d")
y = y - 38

local slotOpts = {}
for i = 1, CenterBar.NUM_SLOTS do slotOpts[i] = { text = CenterBar.L.SLOT:format(i), value = i } end
Choice(L2.SLOT, "slot", slotOpts, CenterBar.GetSlot, CenterBar.SetSlot)
y = y + 8
Label(L2.SLOT_TIP, "GameFontDisableSmall")
y = y - 16
Label(L2.SLOT_TIP2, "GameFontDisableSmall")
y = y - 26

Check(L2.GRID, "grid")
Check(L2.TOOLTIPS, "tooltips")
Check(L2.LOCK, "locked")

local reset = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
reset:SetSize(90, 22)
reset:SetPoint("BOTTOMRIGHT", -14, 12)
reset:SetText(L2.RESET)
reset:SetScript("OnClick", function() CenterBar.Reset(); Refresh() end)

local bind = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
bind:SetPoint("BOTTOMLEFT", 18, 18)
bind:SetText(L2.BINDINGS)

f:SetScript("OnShow", Refresh)

CenterBarOptions = {
	Toggle = function() f:SetShown(not f:IsShown()) end,
	Refresh = function() if f:IsShown() then Refresh() end end,
}
