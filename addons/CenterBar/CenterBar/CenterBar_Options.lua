-- 센터바 설정 창 — @hyveo

local _, ns = ...
local L2 = ns.L2 -- 문자열은 Locales.lua

local f = CreateFrame("Frame", "CenterBarOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(470, 595)
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

local refreshers = {}
local refreshing = false
local function Refresh()
	refreshing = true
	for _, fn in ipairs(refreshers) do fn() end
	refreshing = false
end

-- 창 안의 내용은 처음 열 때 만든다. 저장된 언어 설정(ADDON_LOADED 이후에 읽힘)이 반영되도록.
local built = false
local function Build()
	if built then return end
	built = true

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.title:SetPoint("TOP", 0, -6)
	f.title:SetText(L2.TITLE)

	local LEFT, RIGHT = 20, 250
	local checks = {} -- 세부 옵션 체크박스 (긴 문구는 줄바꿈하고 아래 칸을 그만큼 내린다)

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
		checks[#checks + 1] = c
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
		for i = 1, CenterBar.NUM_SLOTS do items[i].text = tostring(i) end
		Buttons(LEFT, -214, 34, 5, items, CenterBar.GetSlot, CenterBar.SetSlot)
	end
	Nudger(L2.POS_Y, -256, 0, 1)
	Nudger(L2.POS_X, -282, 1, 0)

	---------------------------------------------------------------------------
	-- 왼쪽 아래: 언어 (자동 = 게임 언어). 바꾸면 UI를 다시 불러와야 적용된다.
	---------------------------------------------------------------------------
	Header(L2.LANG, LEFT, -318)
	do
		-- 저장값: nil = hyveo 애드온 센터를 따름(센터가 없으면 게임 언어), "auto" = 게임 언어, 그 밖 = 언어 코드
		local hasCenter = HyveoCenter_GetLanguage ~= nil
		local function Name(code)
			if not code or code == "auto" then return L2.LANG_AUTO:format(ns.GameLocale()) end
			return ns.LANG_NAMES[code] or code
		end
		local function Label(code)
			if code == "follow" then -- 짧게: 센터가 고른 언어 이름, 없으면 게임 언어 코드
				local c = HyveoCenter_GetLanguage()
				return L2.LANG_FOLLOW:format(c and ns.LANG_NAMES[c] or ns.GameLocale())
			end
			return Name(code)
		end
		local function Current()
			local v = CenterBarGlobalDB and CenterBarGlobalDB.lang
			if v then return v end
			return hasCenter and "follow" or "auto"
		end

		StaticPopupDialogs["CENTERBAR_LANGUAGE"] = {
			text = "%s",
			button1 = L2.RELOAD_NOW,
			button2 = L2.LATER,
			OnAccept = function() ReloadUI() end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}

		local drop = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		drop:SetSize(190, 22)
		drop:SetPoint("TOPLEFT", LEFT, -336)

		local list = CreateFrame("Frame", nil, drop, "BackdropTemplate")
		list:SetFrameStrata("FULLSCREEN_DIALOG")
		list:SetClampedToScreen(true)
		list:SetPoint("TOPLEFT", drop, "BOTTOMLEFT", 0, -2)
		list:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
		list:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
		list:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
		list:EnableMouse(true)
		list:Hide()

		local codes = hasCenter and { "follow", "auto" } or { "auto" }
		local head = #codes -- 위쪽 묶음(따름/자동) 다음에 구분선
		for _, c in ipairs(ns.LANGS) do codes[#codes + 1] = c end
		local rows = {}
		local ROW = 20
		for i, code in ipairs(codes) do
			local r = CreateFrame("Button", nil, list)
			r:SetSize(220, ROW)
			r:SetPoint("TOPLEFT", 4, -4 - (i - 1) * ROW - (i > head and 6 or 0))
			r.hl = r:CreateTexture(nil, "HIGHLIGHT")
			r.hl:SetAllPoints()
			r.hl:SetColorTexture(1, 0.82, 0, 0.15)
			r.check = r:CreateTexture(nil, "OVERLAY") -- 지금 고른 언어 표시
			r.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
			r.check:SetSize(16, 16)
			r.check:SetPoint("LEFT", 4, 0)
			r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			r.text:SetPoint("LEFT", 24, 0)
			r.text:SetText(Label(code))
			r:SetScript("OnClick", function()
				list:Hide()
				if code == Current() then return end
				CenterBarGlobalDB = CenterBarGlobalDB or {}
				if code == "follow" or (code == "auto" and not hasCenter) then
					CenterBarGlobalDB.lang = nil
				else
					CenterBarGlobalDB.lang = code
				end
				drop:SetText(Label(code))
				StaticPopup_Show("CENTERBAR_LANGUAGE", L2.LANG_ASK:format(Label(code)) .. "\n" .. L2.LANG_RELOAD)
			end)
			rows[i] = r
		end
		-- 자동과 언어 목록 사이 구분선
		local sep = list:CreateTexture(nil, "ARTWORK")
		sep:SetColorTexture(0.6, 0.5, 0.3, 0.6)
		sep:SetHeight(1)
		sep:SetPoint("TOPLEFT", 8, -4 - head * ROW - 3)
		sep:SetPoint("TOPRIGHT", -8, -4 - head * ROW - 3)
		list:SetSize(228, 8 + #codes * ROW + 6)

		drop:SetScript("OnClick", function() list:SetShown(not list:IsShown()) end)
		list:SetScript("OnHide", nil)
		f:HookScript("OnHide", function() list:Hide() end)

		refreshers[#refreshers + 1] = function()
			local cur = Current()
			drop:SetText(Label(cur))
			for i, code in ipairs(codes) do
				rows[i].check:SetShown(code == cur)
				rows[i].text:SetText(Label(code))
			end
		end
	end

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
	Check(L2.NOMINIMAP, "minimapHide", -414)
	Check(L2.QUIET, "quiet", -438)

	-- 문구가 긴 언어(독일어 등)는 체크박스 글자를 줄바꿈하고, 그만큼 다음 칸을 아래로 내린다.
	-- 창 너비는 그대로 두고, 모자라면 창 높이만 늘린다.
	local W = 470
	local LABEL_W = W - (RIGHT - 4 + 26) - 18
	local y = -198
	for _, c in ipairs(checks) do
		c:ClearAllPoints()
		c:SetPoint("TOPLEFT", RIGHT - 4, y)
		c.label:ClearAllPoints()
		c.label:SetPoint("TOPLEFT", c, "TOPRIGHT", 2, -6)
		c.label:SetWidth(LABEL_W)
		c.label:SetJustifyH("LEFT")
		c.label:SetWordWrap(true)
		local h = c.label:GetStringHeight() or 12
		y = y - math.max(24, math.ceil(h) + 12)
	end
	f:SetHeight(math.max(595, -y + 130))

	-- 도움말 두 줄: 아래 것부터 놓고 위 것을 그 위에 붙여서, 줄이 넘어가도 겹치지 않게 한다
	local tip2 = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	tip2:SetPoint("BOTTOMLEFT", 18, 58) -- 아래 버튼(높이 26, 바닥에서 14)과 넉넉히 띄움
	tip2:SetWidth(W - 36) tip2:SetJustifyH("LEFT")
	tip2:SetText(L2.TIP2)
	local tip1 = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	tip1:SetPoint("BOTTOMLEFT", tip2, "TOPLEFT", 0, 4)
	tip1:SetWidth(W - 36) tip1:SetJustifyH("LEFT")
	tip1:SetText(L2.TIP1)

	-- 아래 버튼 두 개: 글자 길이에 맞춰 넓히되 최소 130, 높이 26, 사이 20
	local reset = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	reset:SetText(L2.RESET)
	reset:SetScript("OnClick", function() CenterBar.Reset(); Refresh() end)
	local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	close:SetText(L2.CLOSE)
	close:SetScript("OnClick", function() f:Hide() end)
	local function TextW(b) local fs = b:GetFontString() return fs and fs:GetStringWidth() or 0 end
	local BW = math.max(130, math.ceil(math.max(TextW(reset), TextW(close)) + 36))
	reset:SetSize(BW, 26)
	close:SetSize(BW, 26)
	reset:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -10, 14)
	close:SetPoint("BOTTOMLEFT", f, "BOTTOM", 10, 14)

	---------------------------------------------------------------------------
	-- 위치 편집: 설정 창이 열려 있는 동안 화면 전체 격자 + 끌어 옮기는 번호 칸
	---------------------------------------------------------------------------
	local edit = CreateFrame("Frame", "CenterBarEditFrame", UIParent)
	edit:SetSize(10, 10)
	edit:SetFrameStrata("HIGH")
	edit:Hide()

	-- 화면 전체 격자: 화면(UIParent) 가장자리에서 가장자리까지 긋는다. 간격 = 이동간격 x 2.
	local gridFrame = CreateFrame("Frame", nil, edit)
	gridFrame:SetAllPoints(UIParent)
	gridFrame:SetFrameStrata("HIGH")
	gridFrame:SetFrameLevel(0)
	gridFrame:SetIgnoreParentScale(true)
	gridFrame:SetScale(UIParent:GetEffectiveScale())
	local LINES = 100
	local vlines, hlines = {}, {}
	for i = -LINES, LINES do
		local a = (i == 0) and 0.95 or (i % 5 == 0) and 0.6 or 0.3
		local r = (i == 0) and 1 or 0
		vlines[i] = gridFrame:CreateTexture(nil, "BACKGROUND")
		vlines[i]:SetColorTexture(r, r, r, a)
		hlines[i] = gridFrame:CreateTexture(nil, "BACKGROUND")
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
		-- 선 굵기는 화면 픽셀 1칸 이상이 되게 (UI 배율이 작으면 1보다 얇은 선은 안 보인다)
		gridFrame:SetScale(UIParent:GetEffectiveScale())
		local es = gridFrame:GetEffectiveScale()
		local px = (es and es > 0 and es < 1) and (1 / es) or 1
		for i = -LINES, LINES do
			local c = i * step * 2
			local w = (i == 0) and px * 2 or px
			vlines[i]:ClearAllPoints()
			vlines[i]:SetPoint("TOP", UIParent, "TOP", c, 0)
			vlines[i]:SetPoint("BOTTOM", UIParent, "BOTTOM", c, 0)
			vlines[i]:SetWidth(w)
			hlines[i]:ClearAllPoints()
			hlines[i]:SetPoint("LEFT", UIParent, "LEFT", 0, c)
			hlines[i]:SetPoint("RIGHT", UIParent, "RIGHT", 0, c)
			hlines[i]:SetHeight(w)
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
end -- Build

CenterBarOptions = {
	Toggle = function() Build() f:SetShown(not f:IsShown()) end,
	Refresh = function() if built and f:IsShown() then Refresh() end end,
}
