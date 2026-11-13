-- [수정자: zico] CentarBar_Option (클래식 20주년 100% 완벽 호환 & 단일 깔끔 격자망)
local ADDON_NAME = ...
local addon = _G["CentarBar"]

-- 버튼 개수 (본체와 동일): 1~12 기존, 13~15 왼쪽 바깥 줄, 16~18 오른쪽 바깥 줄
local NUM_BUTTONS = 18

-- 대칭 이동 짝: 1~6 <-> 7~12, 13~15 <-> 16~18
local function PartnerOf(id)
	if id <= 12 then return id + (id > 6 and -6 or 6) end
	return id + (id > 15 and -3 or 3)
end

-- [1. 싱글톤 가드: 2중 중복 로드 및 격자선 겹침 원천 차단]
if _G["CentarBar_Option_Loaded"] then
	return
end
_G["CentarBar_Option_Loaded"] = true

local options = _G["CentarBar_OptionFrame1"] or CreateFrame("Frame", "CentarBar_OptionFrame1", UIParent, BackdropTemplateMixin and "BackdropTemplate")
if not options.SetBackdrop and BackdropTemplateMixin then
	Mixin(options, BackdropTemplateMixin)
end
options:SetFrameStrata("DIALOG")
options:SetFrameLevel(100)
options:SetWidth(450)
options:SetHeight(430)
options:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
if options.SetBackdrop then
	options:SetBackdrop({
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		edgeSize = 16, tile = 1, tileSize = 16,
		insets = {top=4, bottom=4, left=4, right=4}
	})
	options:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
end
options:SetMovable(true)
options:SetClampedToScreen(true)
options:EnableMouse(true)
options:RegisterForDrag("LeftButton")
options:SetScript("OnDragStart", options.StartMoving)
options:SetScript("OnDragStop", options.StopMovingOrSizing)

-- ESC 키로 창 닫기 등록
tinsert(UISpecialFrames, options:GetName())

-- 좌측 헤더: 기본 설정
local titleLeft = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleLeft:SetText("기본 설정")
titleLeft:SetPoint("TOPLEFT", 20, -15)

-- 우측 헤더: 외형 모양
local titleRight = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleRight:SetText("외형 모양 (템플릿)")
titleRight:SetPoint("TOPLEFT", 235, -15)

local buttons = _G["CentarBar_OptionFrame2"] or CreateFrame("Button", "CentarBar_OptionFrame2", UIParent)
buttons:SetClampedToScreen(true)
buttons:SetFrameStrata("HIGH")
buttons:SetFrameLevel(0)
buttons:SetWidth(60)
buttons:SetHeight(36)
if addon then
	buttons:SetPoint("CENTER", addon, "CENTER", 0, 0)
else
	buttons:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
buttons:SetNormalFontObject("ChatFontNormal")
buttons:SetID(0)

-- [2. 단일 격자망 텍스처 풀 및 정밀 렌더러]
options.lines1 = {}
options.lines2 = {}

for i = -50, 50 do
	local t1 = buttons:CreateTexture(nil, "BACKGROUND")
	if i == 0 then
		t1:SetColorTexture(1, 1, 1, 0.95) -- 중앙 수직 기준선 (선명한 흰색)
	elseif i % 5 == 0 then
		t1:SetColorTexture(0, 0, 0, 0.6) -- 5칸 단위 보조선
	else
		t1:SetColorTexture(0, 0, 0, 0.3) -- 기본 격자선 (은은한 반투명)
	end
	options.lines1[i] = t1

	local t2 = buttons:CreateTexture(nil, "BACKGROUND")
	if i == 0 then
		t2:SetColorTexture(1, 1, 1, 0.95) -- 중앙 수평 기준선 (선명한 흰색)
	elseif i % 5 == 0 then
		t2:SetColorTexture(0, 0, 0, 0.6) -- 5칸 단위 보조선
	else
		t2:SetColorTexture(0, 0, 0, 0.3) -- 기본 격자선 (은은한 반투명)
	end
	options.lines2[i] = t2
end

local function UpdateGridPositions(stepVal)
	local curStep = stepVal or options.step or 10
	for i = -50, 50 do
		local c = i * curStep * 2
		local t1 = options.lines1[i]
		if t1 then
			t1:ClearAllPoints()
			if i == 0 then
				t1:SetPoint("TOPLEFT", UIParent, "TOP", -1, 0)
				t1:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 1, 0)
			else
				t1:SetPoint("TOPLEFT", UIParent, "TOP", c, 0)
				t1:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", c + 1, 0)
			end
		end
		
		local t2 = options.lines2[i]
		if t2 then
			t2:ClearAllPoints()
			if i == 0 then
				t2:SetPoint("TOPLEFT", UIParent, "LEFT", 0, 1)
				t2:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", 0, -1)
			else
				t2:SetPoint("TOPLEFT", UIParent, "LEFT", 0, c + 1)
				t2:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", 0, c)
			end
		end
	end
end

local function GetPosIndex(target)
	local x, y = GetCursorPosition()
	local px, py = target:GetCenter()
	if not px or not py then return 0, 0 end
	local s = target:GetEffectiveScale() or 1
	local curStep = options.step or 10
	return math.floor((x-px*s)/(curStep*s)), math.floor((y-py*s)/(curStep*s))
end

local function memory(btn, x, y)
	btn.x = x
	btn.y = y
	local curStep = options.step or 10
	btn:ClearAllPoints()
	btn:SetPoint("CENTER", x*curStep, y*curStep)
	btn:SetText(btn:GetID().."\n"..x.."."..y)
end

local function OnUpdate(self, elapsed)
	local x, y = GetPosIndex(buttons)
	local id = self.target
	if id and self[id] and (self[id].x ~= x or self[id].y ~= y) then
		memory(self[id], x, y)
		if options.decal then
			local partner = PartnerOf(id)
			if self[partner] then
				memory(self[partner], -x, y)
			end
		end
	end
end

local function OnDragStart(self)
	buttons.target = self:GetID()
	buttons:SetScript("OnUpdate", OnUpdate)
end

local function OnDragStop(self)
	buttons:SetScript("OnUpdate", nil)
end

for i = 1, NUM_BUTTONS do
	local btn = buttons[i] or CreateFrame("Button", "CentarBar_OptionDummyBtn"..i, buttons)
	btn:SetID(i)
	btn:SetSize(36, 36)
	if not btn.icon then
		btn.icon = btn:CreateTexture(nil, "BORDER")
		btn.icon:SetAllPoints(btn)
		if i > 12 then
			btn.icon:SetColorTexture(0.1, 0.8, 0.3, 0.45) -- 추가 버튼(13~18)은 초록색
		else
			btn.icon:SetColorTexture(0, 0.4, 1, 0.4)
		end
	end
	btn:SetNormalFontObject("GameFontHighlight")
	btn:SetScript("OnMouseDown", OnDragStart)
	btn:SetScript("OnMouseUp", OnDragStop)
	buttons[i] = btn
end

local tBorder = buttons.border or buttons:CreateTexture(nil, "BORDER")
tBorder:SetAllPoints(buttons)
tBorder:SetColorTexture(0, 0, 1, 0.5)
buttons.border = tBorder

local function OnCenterUpdate(self, elapsed)
	local _, y = GetPosIndex(UIParent)
	local curStep = options.step or 10
	if y ~= options.yOffset then
		options.yOffset = y
		self:ClearAllPoints()
		self:SetPoint("CENTER", 0, y*curStep)
		self:SetText("CENTER\n"..y)
	end
end
buttons:SetScript("OnMouseDown", function(self, button)
	self:SetScript("OnUpdate", OnCenterUpdate)
end)
buttons:SetScript("OnMouseUp", function(self, button)
	self:SetScript("OnUpdate", nil)
end)

-- 슬라이더 생성 헬퍼 함수
local function CreateOptionSlider(name, minVal, maxVal, stepVal, yPos, labelFormat)
	local slider = _G[options:GetName()..name] or CreateFrame("Slider", options:GetName()..name, options, "OptionsSliderTemplate")
	slider:SetWidth(180)
	slider:SetPoint("TOPLEFT", 20, -yPos)
	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValueStep(stepVal)
	slider:EnableMouseWheel(true)
	
	local title = _G[slider:GetName().."Text"] or slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	title:ClearAllPoints()
	title:SetPoint("BOTTOM", slider, "TOP", 0, 3)
	slider.title = title
	
	local low = _G[slider:GetName().."Low"]
	if low then low:SetText(tostring(minVal)) end
	local high = _G[slider:GetName().."High"]
	if high then high:SetText(tostring(maxVal)) end
	
	slider.formatLabel = labelFormat
	return slider
end

-- 좌측 슬라이더 5개 배치
-- 1. 크기(배율)
local scaleSlider = CreateOptionSlider("Scale", 70, 200, 1, 55, function(v) return "배율: " .. string.format("%d%%", v) end)
scaleSlider:SetScript("OnValueChanged", function(self, value)
	local s = value / 100
	self.title:SetText(self.formatLabel(value))
	self:GetParent().scale = s
	buttons:SetScale(s)
end)
scaleSlider:SetScript("OnMouseWheel", function(self, delta)
	self:SetValue(math.max(70, math.min(200, (self:GetParent().scale or 1)*100 + delta*5)))
end)

-- 2. 투명도
local alphaSlider = CreateOptionSlider("Alpha", 0, 100, 1, 105, function(v) return "투명도: " .. string.format("%d%%", v) end)
alphaSlider:SetScript("OnValueChanged", function(self, value)
	local s = value / 100
	self.title:SetText(self.formatLabel(value))
	self:GetParent().alpha = s
	if addon and addon.SetAlpha then addon:SetAlpha(s) end
end)
alphaSlider:SetScript("OnMouseWheel", function(self, delta)
	self:SetValue(math.max(0, math.min(100, (self:GetParent().alpha or 1)*100 + delta*5)))
end)

-- 3. 이동간격
local stepSlider = CreateOptionSlider("Step", 2, 20, 1, 155, function(v) return "이동간격: " .. string.format("%d", v) end)
stepSlider:SetScript("OnValueChanged", function(self, value)
	self.title:SetText(self.formatLabel(value))
	self:GetParent().step = value
	UpdateGridPositions(value)
	for i = 1, NUM_BUTTONS do
		if buttons[i] and buttons[i].x and buttons[i].y then
			memory(buttons[i], buttons[i].x, buttons[i].y)
		end
	end
end)
stepSlider:SetScript("OnMouseWheel", function(self, delta)
	self:SetValue(math.max(2, math.min(20, (self:GetParent().step or 10) + delta)))
end)

-- 4. 특성1 페이지
local page1Slider = CreateOptionSlider("Page1", 1, 10, 1, 205, function(v) return "특성1 페이지: " .. string.format("%d", v) end)
page1Slider:SetScript("OnValueChanged", function(self, value)
	self.title:SetText(self.formatLabel(value))
	self:GetParent().page = value
end)
page1Slider:SetScript("OnMouseWheel", function(self, delta)
	self:SetValue(math.max(1, math.min(10, (self:GetParent().page or 2) + delta)))
end)

-- 5. 특성2 페이지
local page2Slider = CreateOptionSlider("Page2", 1, 10, 1, 255, function(v) return "특성2 페이지: " .. string.format("%d", v) end)
page2Slider:SetScript("OnValueChanged", function(self, value)
	self.title:SetText(self.formatLabel(value))
	self:GetParent().page2 = value
end)
page2Slider:SetScript("OnMouseWheel", function(self, delta)
	self:SetValue(math.max(1, math.min(10, (self:GetParent().page2 or 2) + delta)))
end)

-- 6. 추가 버튼(13~18) 페이지
local pageExSlider = CreateOptionSlider("PageExtra", 1, 10, 1, 305, function(v) return "추가 버튼(13~18) 페이지: " .. string.format("%d", v) end)
pageExSlider:SetScript("OnValueChanged", function(self, value)
	self.title:SetText(self.formatLabel(value))
	self:GetParent().pageExtra = value
end)
pageExSlider:SetScript("OnMouseWheel", function(self, delta)
	self:SetValue(math.max(1, math.min(10, (self:GetParent().pageExtra or 10) + delta)))
end)

-- 우측 외형 템플릿 라디오 버튼 4개 (2x2 그리드 배치)
local template = {
	{ name = "기본형식",
		x = {-25, -29, -31, -31, -29, -25, 25, 29, 31, 31, 29, 25, -36, -38, -36, 36, 38, 36},
		y = {15, 9, 3, -3, -9, -15, 15, 9, 3, -3, -9, -15, 9, 0, -9, 9, 0, -9},
	},
	{ name = "3x3(1)",
		x = {-20, -20, -20, -15, -15, -15, 15, 15, 15, 20, 20, 20, -25, -25, -25, 25, 25, 25},
		y = {5, 0, -5, 5, 0, -5, 5, 0, -5, 5, 0, -5, 5, 0, -5, 5, 0, -5},
	},
	{ name = "3x3(2)",
		x = {-18, -18, -18, -23, -23, -23, 18, 18, 18, 23, 23, 23, -28, -28, -28, 28, 28, 28},
		y = {-5, 0, 5, 3, -2, -7, -5, 0, 5, 3, -2, -7, -5, 0, 5, -5, 0, 5},
	},
	{ name = "3x3(3)",
		x = {-20, -20, -20, -15, -15, -15, 15, 15, 15, 20, 20, 20, -25, -25, -25, 25, 25, 25},
		y = {5, 0, -5, 3, -2, -7, 3, -2, -7, 5, 0, -5, 3, -2, -7, 3, -2, -7},
	},
}

local function Template_OnClick(self)
	for i = 1, 4 do
		local rbtn = _G["CentarBar_OptionTemplateButton"..i]
		if rbtn then rbtn:SetChecked(i == self.index) end
	end
	for i = 1, NUM_BUTTONS do
		if buttons[i] and template[self.index] then
			memory(buttons[i], template[self.index].x[i], template[self.index].y[i])
		end
	end
end

for i = 1, #template do
	local l = _G["CentarBar_OptionTemplateButton"..i] or CreateFrame("CheckButton", "CentarBar_OptionTemplateButton"..i, options, "UIRadioButtonTemplate")
	local col = (i - 1) % 2
	local row = math.floor((i - 1) / 2)
	l:SetPoint("TOPLEFT", 235 + col * 100, -35 - row * 24)
	local txt = _G[l:GetName().."Text"]
	if txt then txt:SetText(template[i].name) end
	l.index = i
	l:SetScript("OnClick", Template_OnClick)
end

-- 표시 개수 선택 (6 / 12 / 18): 외형 템플릿 바로 아래
local titleCount = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleCount:SetText("표시 개수")
titleCount:SetPoint("TOPLEFT", 235, -92)

local COUNT_CHOICES = { 6, 12, 18 }

local function IsEnabled(i, count)
	local a = _G["CentarBar"]
	if a and a.IsButtonEnabled then return a.IsButtonEnabled(i, count) end
	return true
end

-- 고른 개수에 맞춰 라디오 체크와 미리보기 격자의 버튼 표시를 갱신
local function RefreshCount()
	local count = options.count or 18
	for i = 1, #COUNT_CHOICES do
		local rbtn = _G["CentarBar_OptionCountButton"..i]
		if rbtn then rbtn:SetChecked(COUNT_CHOICES[i] == count) end
	end
	for i = 1, NUM_BUTTONS do
		if buttons[i] then
			if IsEnabled(i, count) then buttons[i]:Show() else buttons[i]:Hide() end
		end
	end
end

for i = 1, #COUNT_CHOICES do
	local r = _G["CentarBar_OptionCountButton"..i] or CreateFrame("CheckButton", "CentarBar_OptionCountButton"..i, options, "UIRadioButtonTemplate")
	r:SetPoint("TOPLEFT", 235 + (i - 1) * 70, -108)
	local txt = _G[r:GetName().."Text"]
	if txt then txt:SetText(COUNT_CHOICES[i].."개") end
	r.count = COUNT_CHOICES[i]
	r:SetScript("OnClick", function(self)
		options.count = self.count
		RefreshCount()
	end)
end

-- 우측 세부 설정 체크박스들
local titleOpt = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleOpt:SetText("세부 옵션")
titleOpt:SetPoint("TOPLEFT", 235, -140)

local function CreateOptionCheck(name, label, yPos, onClick)
	local cb = _G[options:GetName()..name] or CreateFrame("CheckButton", options:GetName()..name, options, "UICheckButtonTemplate")
	cb:SetPoint("TOPLEFT", 235, -yPos)
	local txt = _G[cb:GetName().."Text"] or cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	txt:SetPoint("LEFT", cb, "RIGHT", 4, 1)
	txt:SetText(label)
	cb.label = txt
	cb:SetScript("OnClick", onClick)
	return cb
end

local decal = CreateOptionCheck("Decal", "대칭 이동", 163, function(self) self:GetParent().decal = self:GetChecked() end)
local combat = CreateOptionCheck("Combat", "전투 시 투명도 복구", 187, function(self) self:GetParent().combat = self:GetChecked() end)
local target = CreateOptionCheck("Target", "대상 선택 시 복구", 211, function(self) self:GetParent().target = self:GetChecked() end)
local mover = CreateOptionCheck("Over", "마우스오버 시 복구", 235, function(self) self:GetParent().mouseover = self:GetChecked() end)
local tooltip = CreateOptionCheck("Tooltip", "툴팁 숨김", 259, function(self) self:GetParent().hideTooltip = self:GetChecked() end)

local mounted
local vehicle = CreateOptionCheck("Vehicle", "탈것 탑승 시 숨김", 283, function(self)
	self:GetParent().vehiclehide = self:GetChecked()
	if mounted then
		if self:GetChecked() then mounted:Enable() else mounted:Disable() end
	end
end)

mounted = CreateOptionCheck("Mounted", "  - 일반 탈것 포함", 307, function(self) self:GetParent().mounthide = self:GetChecked() end)
local grid = CreateOptionCheck("Grid", "빈 버튼 항상 표시", 331, function(self) self:GetParent().showgrid = self:GetChecked() end)

-- 하단 중앙: 적용 및 닫기 버튼
local accept = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
accept:SetWidth(100)
accept:SetHeight(28)
accept:SetPoint("BOTTOM", options, "BOTTOM", -60, 16)
accept:SetText("설정 적용")
accept:SetScript("OnClick", function(self)
	local parent = self:GetParent()
	addon = _G["CentarBar"]
	if addon and addon.db then
		addon.db.x = addon.db.x or {}
		addon.db.y = addon.db.y or {}
		for i = 1, NUM_BUTTONS do
			if buttons[i] and buttons[i].x and buttons[i].y then
				addon.db.x[i] = buttons[i].x
				addon.db.y[i] = buttons[i].y
			end
		end
		addon.db.yOffset = parent.yOffset
		addon.db.alpha = parent.alpha
		addon.db.page = parent.page
		addon.db.page2 = parent.page2
		addon.db.pageExtra = parent.pageExtra
		addon.db.count = parent.count or addon.db.count
		addon.db.step = parent.step
		addon.db.showgrid = parent.showgrid
		addon.db.scale = parent.scale
		addon.db.combat = parent.combat
		addon.db.target = parent.target
		addon.db.hideTooltip = parent.hideTooltip
		addon.db.mouseover = parent.mouseover
		addon.db.vehiclehide = parent.vehiclehide
		addon.db.mounthide = parent.mounthide
		if addon.Setup then addon:Setup() end
	end
	parent:Hide()
	buttons:Hide()
end)

local cancel = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
cancel:SetWidth(100)
cancel:SetHeight(28)
cancel:SetPoint("BOTTOM", options, "BOTTOM", 60, 16)
cancel:SetText("닫기 (ESC)")
cancel:SetScript("OnClick", function(self)
	self:GetParent():Hide()
	buttons:Hide()
	addon = _G["CentarBar"]
	if addon and addon.Setup then addon:Setup() end
end)

-- ESC 등으로 창 닫힐 때 잔여 격자 프레임 정리
options:SetScript("OnHide", function(self)
	buttons:Hide()
	addon = _G["CentarBar"]
	if addon and addon.Setup then addon:Setup() end
end)

options:Hide()
buttons:Hide()

-- [핵심] CBO 옵션창 토글 전역 함수 100% 보장
local function OpenOrToggleCBO()
	addon = _G["CentarBar"]
	if options:IsShown() then
		options:Hide()
		buttons:Hide()
		return
	end
	options:Show()
	buttons:Show()
	
	local db = (addon and addon.db) or _G["CentarBarSaveData"] or {}
	options.step = db.step or 10
	options.yOffset = db.yOffset or 0
	options.scale = db.scale or 1
	options.page = db.page or 2
	options.page2 = db.page2 or 2
	options.pageExtra = db.pageExtra or 10
	options.count = db.count or 18
	options.alpha = db.alpha or 1
	options.combat = db.combat
	options.target = db.target
	options.hideTooltip = db.hideTooltip
	options.mouseover = db.mouseover
	options.vehiclehide = db.vehiclehide
	options.mounthide = db.mounthide
	options.showgrid = db.showgrid
	
	UpdateGridPositions(options.step)
	
	scaleSlider:SetValue(options.scale * 100)
	alphaSlider:SetValue(options.alpha * 100)
	stepSlider:SetValue(options.step)
	page1Slider:SetValue(options.page)
	page2Slider:SetValue(options.page2)
	pageExSlider:SetValue(options.pageExtra)
	
	decal:SetChecked(options.decal)
	combat:SetChecked(options.combat)
	target:SetChecked(options.target)
	tooltip:SetChecked(options.hideTooltip)
	mover:SetChecked(options.mouseover)
	vehicle:SetChecked(options.vehiclehide)
	mounted:SetChecked(options.mounthide)
	grid:SetChecked(options.showgrid)
	
	buttons:ClearAllPoints()
	buttons:SetPoint("CENTER", 0, (options.yOffset or 0) * (options.step or 10))
	buttons:SetText("CENTER\n"..(options.yOffset or 0))
	for i = 1, NUM_BUTTONS do
		if buttons[i] and db.x and db.x[i] then
			memory(buttons[i], db.x[i], db.y[i])
		end
	end
	RefreshCount()

	if not options.vehiclehide then
		if mounted and mounted.Disable then mounted:Disable() end
	end
end

-- 전역 노출 등록
_G["CentarBar_Option"] = OpenOrToggleCBO
_G["CentarBar_OptionFrame1"] = options

print("|cff00ff00[CentarBar]|r 설정 모듈 로드 완료. /cbo 로 설정을 열 수 있습니다.")
