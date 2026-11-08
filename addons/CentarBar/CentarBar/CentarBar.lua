-- [제작자: Clamp, zico] CentarBar - 최신 와우 엔진 및 CBO 완전 호환 리뉴얼
local ADDON_NAME, addon = ...

-- 1. 기본 설정값 정의
local default = {
	x = {-14, -14, -14, -19, -19, -19, 14, 14, 14, 19, 19, 19},
	y = {-5, 0, 5, -7, -2, 3, -5, 0, 5, 3, -2, -7},
	yOffset = 0,
	alpha = 1,
	scale = 1,
	hideTooltip = true,
	combat = false,
	mouseover = false,
	vehiclehide = false,
	mounthide = false,
	step = 10,
	showgrid = false,
	page = 2,
	page2 = 2,
	page3 = 2,
	page4 = 2,
}

local UpdateBindings

-- [Forever/Midnight 대응] 전투 중 쿨다운·충전 값은 '비밀 값(secret value)'으로 내려온다.
-- 비밀 값은 비교(>, ==)나 산술을 하면 Lua 오류가 나므로, 값을 직접 다루지 않고
-- 블리자드 Cooldown 위젯(C++)에 그대로 넘겨 스와이프와 숫자를 그리게 한다.
local function IsSecret(v)
	return issecretvalue and issecretvalue(v) or false
end
-- 비밀 값이면 nil, 아니면 원래 값 (조건문에 안전하게 쓰기 위함)
local function Plain(v)
	if IsSecret(v) then return nil end
	return v
end

-- 2. CBO 글로벌 프레임 및 addon.db 상단 즉시 바인딩
_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME.."Frame", UIParent)
addon = _G[ADDON_NAME]
addon:SetWidth(400)
addon:SetHeight(300)
addon:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
addon:SetFrameStrata("MEDIUM")
addon:EnableMouse(false)
addon:Show()

_G[ADDON_NAME.."SaveData"] = _G[ADDON_NAME.."SaveData"] or default
addon.db = _G[ADDON_NAME.."SaveData"]

-- [슬래시 명령어 즉각 선행 등록]
SLASH_CENTARBAR1 = "/cbo"
SLASH_CENTARBAR2 = "/cb"
SLASH_CENTARBAR3 = "/centarbar"
SLASH_CENTARBAR4 = "/츄ㅐ"
SLASH_CENTARBAR5 = "/센타"
SLASH_CENTARBAR6 = "/중앙바"
SlashCmdList["CENTARBAR"] = function(msg)
	if type(_G["CentarBar_Option"]) == "function" then
		_G["CentarBar_Option"]()
	elseif _G["CentarBar_OptionFrame1"] then
		local opt = _G["CentarBar_OptionFrame1"]
		if opt:IsShown() then opt:Hide() else opt:Show() end
	else
		local loadFn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
		if loadFn then pcall(loadFn, "CentarBar_Option") end
		if type(_G["CentarBar_Option"]) == "function" then
			_G["CentarBar_Option"]()
		end
	end
end
for k, v in pairs(default) do
	if addon.db[k] == nil then addon.db[k] = v end
end

-- 3. 12개 버튼 선행 생성
for i = 1, 12 do
	local btn = CreateFrame("CheckButton", ADDON_NAME.."Button"..i, addon, "SecureActionButtonTemplate")
	addon[i] = btn
	btn:SetID(i)
	btn:SetSize(36, 36)
	btn:SetFrameStrata("MEDIUM")
	btn:SetFrameLevel(10)
	btn.buttonType = ADDON_NAME
	btn.btnIndex = i
	btn:EnableMouse(true)
	btn:Show()
	
	-- 아이콘
	local icon = btn:CreateTexture(btn:GetName().."Icon", "BACKGROUND")
	icon:SetAllPoints()
	btn.icon = icon
	
	-- 순정 퀵슬롯 테두리
	btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	local nt = btn:GetNormalTexture()
	if nt then
		nt:ClearAllPoints()
		nt:SetPoint("TOPLEFT", -14, 14)
		nt:SetPoint("BOTTOMRIGHT", 15, -15)
		nt:SetAlpha(0.4)
		nt:Show()
	end
	
	btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	btn:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
	
	local flash = btn:CreateTexture(btn:GetName().."Flash", "ARTWORK")
	flash:SetTexture("Interface\\Buttons\\UI-QuickslotRed")
	flash:SetAllPoints()
	flash:Hide()
	btn.Flash = flash
	
	-- 블리자드 스와이프 전용 Cooldown 위젯
	local cd = CreateFrame("Cooldown", btn:GetName().."Cooldown", btn, "CooldownFrameTemplate")
	cd:SetAllPoints()
	cd:SetFrameLevel(btn:GetFrameLevel() + 2)
	cd:EnableMouse(false)
	if cd.SetDrawEdge then cd:SetDrawEdge(true) end
	if cd.SetDrawSwipe then cd:SetDrawSwipe(true) end
	-- [Forever 수정] 숫자를 Lua에서 계산하지 않고 블리자드 내장 카운트다운 숫자를 사용
	-- (전투 중 비밀 값이어도 C++ 위젯은 정상적으로 숫자를 그림)
	if cd.SetHideCountdownNumbers then cd:SetHideCountdownNumbers(false) end
	if cd.SetCountdownAbbrevThreshold then pcall(cd.SetCountdownAbbrevThreshold, cd, 90) end
	-- 기존 디자인(20pt 외곽선, 골드색) 유지
	local fFile = (NumberFontNormalHuge and NumberFontNormalHuge.GetFont and NumberFontNormalHuge:GetFont()) or STANDARD_TEXT_FONT
	local cdFS = cd.GetCountdownFontString and cd:GetCountdownFontString()
	if cdFS then
		cdFS:SetFont(fFile, 20, "OUTLINE")
		cdFS:SetTextColor(1, 0.85, 0, 1)
		cdFS:ClearAllPoints()
		cdFS:SetPoint("CENTER", cd, "CENTER", 0, 0)
	end
	btn.cooldown = cd
	
	-- 핫키 폰트 (우측 상단)
	local hotkey = btn:CreateFontString(btn:GetName().."HotKey", "ARTWORK", "NumberFontNormalSmallGray")
	hotkey:SetPoint("TOPRIGHT", 0, -2)
	hotkey:SetSize(36, 10)
	hotkey:SetJustifyH("RIGHT")
	btn.HotKey = hotkey
	
	-- 카운트 / 충전 수 폰트 (우측 하단)
	local count = btn:CreateFontString(btn:GetName().."Count", "ARTWORK", "NumberFontNormal")
	local cFile = (count.GetFont and count:GetFont()) or (NumberFontNormal and NumberFontNormal.GetFont and NumberFontNormal:GetFont()) or STANDARD_TEXT_FONT
	count:SetFont(cFile, 18, "OUTLINE")
	count:SetPoint("BOTTOMRIGHT", -2, 2)
	count:SetJustifyH("RIGHT")
	btn.Count = count
	
	-- 매크로 이름 텍스트 (하단 중앙)
	local nameText = btn:CreateFontString(btn:GetName().."Name", "OVERLAY", "GameFontHighlightSmallOutline")
	nameText:SetPoint("BOTTOM", 0, 2)
	nameText:SetSize(36, 10)
	nameText:SetJustifyH("CENTER")
	btn.Name = nameText
end

-- 4. 특성별 액션바 페이지 계산 함수
local function GetCurrentPage(db)
	local spec = (GetActiveTalentGroup and GetActiveTalentGroup())
		or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization and C_SpecializationInfo.GetSpecialization())
		or (GetSpecialization and GetSpecialization())
		or 1
	if spec == 2 then return db.page2 or db.page or 2
	elseif spec == 3 then return db.page3 or db.page or 2
	elseif spec == 4 then return db.page4 or db.page or 2
	else return db.page or 2 end
end

-- 5. 보안 속성 초기화 함수
local function ClearButtonAttributes(btn)
	local attrs = {"type", "action", "spell", "item", "macro", "macrotext"}
	for _, a in ipairs(attrs) do
		btn:SetAttribute(a, nil)
		btn:SetAttribute(a.."*", nil)
		btn:SetAttribute(a.."1", nil)
		btn:SetAttribute(a.."-LeftButton", nil)
	end
	btn:SetAttribute("shift-type", "none")
	btn:SetAttribute("shift-type1", "none")
	btn:SetAttribute("shift-type*", "none")
end

-- 6. [최신 API 규격] UseAction 배제 및 스펠/아이템/매크로 직통 매핑
local function SyncButtonAction(btn, slot)
	if not slot or InCombatLockdown() then return end
	ClearButtonAttributes(btn)
	
	local aType, aId = GetActionInfo(slot)
	if aType == "spell" and aId then
		local spellName = (GetSpellInfo and GetSpellInfo(aId)) or (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(aId)) or aId
		btn:SetAttribute("type", "spell")
		btn:SetAttribute("type1", "spell")
		btn:SetAttribute("type*", "spell")
		btn:SetAttribute("spell", spellName)
		btn:SetAttribute("spell1", spellName)
		btn:SetAttribute("spell*", spellName)
	elseif aType == "item" and aId then
		local itemName = (GetItemInfo and GetItemInfo(aId)) or aId
		btn:SetAttribute("type", "item")
		btn:SetAttribute("type1", "item")
		btn:SetAttribute("type*", "item")
		btn:SetAttribute("item", itemName)
		btn:SetAttribute("item1", itemName)
		btn:SetAttribute("item*", itemName)
	elseif aType == "macro" and aId then
		local actName = GetActionText and GetActionText(slot)
		local name, icon, body = GetMacroInfo(aId)
		if not body and actName then name, icon, body = GetMacroInfo(actName) end
		local macroTarget = name or actName or aId
		
		btn:SetAttribute("type", "macro")
		btn:SetAttribute("type1", "macro")
		btn:SetAttribute("type*", "macro")
		btn:SetAttribute("macro", macroTarget)
		btn:SetAttribute("macro1", macroTarget)
		btn:SetAttribute("macro*", macroTarget)
		
		if body and body ~= "" then
			body = body:gsub("\r\n", "\n"):gsub("\r", "\n")
			if not body:match("\n$") then body = body .. "\n" end
			btn:SetAttribute("macrotext", body)
			btn:SetAttribute("macrotext1", body)
			btn:SetAttribute("macrotext*", body)
		end
	else
		btn:SetAttribute("type", "action")
		btn:SetAttribute("action", slot)
	end
	
	btn:SetAttribute("shift-type", "none")
	btn:SetAttribute("shift-type1", "none")
	btn:SetAttribute("shift-type*", "none")
	btn:SetID(slot)
end

-- 7~9. [Forever 수정] 쿨다운 갱신
-- 기존 방식(직접 남은 시간 계산 + 자체 타이머)은 전투 중 비밀 값 때문에 비교 단계에서 멈춰 숫자가 사라졌음.
-- 이제는 DurationObject(또는 원시 값)를 Cooldown 위젯에 그대로 넘기고, 표시는 위젯이 담당한다.
local function SetCooldownFromSlot(cd, slot)
	-- 1순위: 12.0+ DurationObject 경로 (전투 중에도 동작)
	if C_ActionBar and C_ActionBar.GetActionCooldownDuration and cd.SetCooldownFromDurationObject then
		local okInfo, info = pcall(C_ActionBar.GetActionCooldown, slot)
		-- isActive / isOnGCD 는 NeverSecret 필드라 조건문에 써도 안전
		if okInfo and type(info) == "table" and info.isActive == false then
			if cd.Clear then cd:Clear() else cd:Hide() end
			return true
		end
		-- 글로벌 쿨다운(1.5초)에는 숫자를 숨기고 스와이프만 표시
		if cd.SetHideCountdownNumbers then
			cd:SetHideCountdownNumbers(okInfo and type(info) == "table" and info.isOnGCD == true)
		end
		local ok, dObj = pcall(C_ActionBar.GetActionCooldownDuration, slot)
		if ok and dObj then
			if pcall(cd.SetCooldownFromDurationObject, cd, dObj) then
				cd:Show()
				return true
			end
		end
	end
	-- 2순위: 구 API (값이 비밀이어도 위젯에 넘기는 것은 허용됨, 비교만 하지 않음)
	if GetActionCooldown then
		local start, duration, enable, modRate = GetActionCooldown(slot)
		if cd.SetCooldown and pcall(cd.SetCooldown, cd, start, duration, modRate or 1) then
			return true
		elseif CooldownFrame_Set then
			pcall(CooldownFrame_Set, cd, start, duration, enable, false, modRate)
			return true
		end
	end
	return false
end

local function UpdateButtonCooldown(btn)
	if not btn then return end
	local cd = btn.cooldown
	local slot = btn.actionSlot or btn.action or btn:GetID()

	if not cd or not slot or not HasAction(slot) then
		if cd then if cd.Clear then cd:Clear() end cd:Hide() end
		if btn.chargeCooldown then btn.chargeCooldown:Hide() end
		return
	end

	SetCooldownFromSlot(cd, slot)

	-- 충전(Charges) 스킬: 충전 재생 스와이프 (숫자 없이 테두리만)
	local chargeOK = false
	if C_ActionBar and C_ActionBar.GetActionChargeDuration then
		local ok, dObj = pcall(C_ActionBar.GetActionChargeDuration, slot)
		if ok and dObj then
			if not btn.chargeCooldown then
				btn.chargeCooldown = CreateFrame("Cooldown", btn:GetName().."ChargeCooldown", btn, "CooldownFrameTemplate")
				btn.chargeCooldown:SetAllPoints()
				btn.chargeCooldown:SetFrameLevel(btn:GetFrameLevel() + 2)
				btn.chargeCooldown:EnableMouse(false)
				if btn.chargeCooldown.SetDrawEdge then btn.chargeCooldown:SetDrawEdge(true) end
				if btn.chargeCooldown.SetDrawSwipe then btn.chargeCooldown:SetDrawSwipe(false) end
				if btn.chargeCooldown.SetHideCountdownNumbers then btn.chargeCooldown:SetHideCountdownNumbers(true) end
			end
			chargeOK = pcall(btn.chargeCooldown.SetCooldownFromDurationObject, btn.chargeCooldown, dObj)
		end
	end
	if not chargeOK and btn.chargeCooldown then btn.chargeCooldown:Hide() end
end

-- 9. 스택 및 충전 횟수 표시 (비밀 값은 비교하지 않고 그대로 SetText)
local maxChargeCache = {}
local function UpdateButtonCount(btn)
	local slot = btn.actionSlot or btn.action or btn:GetID()
	local count = btn.Count
	if not count then return end
	if not slot or not HasAction(slot) then
		count:Hide()
		return
	end

	-- 충전형 스킬
	if GetActionCharges then
		local ok, charges, maxCharges = pcall(GetActionCharges, slot)
		if ok then
			local m = Plain(maxCharges)
			if type(m) == "number" then maxChargeCache[slot] = m end
			m = m or maxChargeCache[slot]
			if type(m) == "number" and m > 1 and charges ~= nil then
				count:SetText(charges) -- 비밀 값도 표시는 가능
				count:Show()
				return
			end
		end
	end

	-- 소모품/중첩 아이템
	local isConsumable = Plain(IsConsumableAction and IsConsumableAction(slot)) or Plain(IsStackableAction and IsStackableAction(slot))
	if isConsumable then
		local c = GetActionCount(slot)
		if IsSecret(c) then
			count:SetText(c)
			count:Show()
			return
		elseif type(c) == "number" and c > 1 then
			count:SetText(c > 999 and "*" or tostring(c))
			count:Show()
			return
		end
	end
	count:Hide()
end

-- 10. 체크 상태 동기화
local function UpdateCheckedState(btn)
	local slot = btn.actionSlot or btn.action or btn:GetID()
	local checked = false
	if slot and HasAction(slot) then
		checked = Plain(IsCurrentAction and IsCurrentAction(slot)) or Plain(IsAutoRepeatAction and IsAutoRepeatAction(slot)) or false
	end
	if btn.SetChecked then
		btn:SetChecked(checked and true or false)
	end
end

-- 11. 비주얼 및 텍스처 갱신 (빈 버튼 가시성 보장)
local function UpdateButtonVisual(btn)
	local slot = btn.actionSlot or btn.action or (btn.GetAttribute and btn:GetAttribute("action"))
	local db = addon.db or _G[ADDON_NAME.."SaveData"] or default
	
	if not slot or not HasAction(slot) then
		if btn.icon then
			btn.icon:SetTexture("")
			btn.icon:Hide()
		end
		if btn.cooldown then btn.cooldown:Hide() end
		if btn.chargeCooldown then btn.chargeCooldown:Hide() end
		if btn.Count then btn.Count:Hide() end
		if btn.Name then btn.Name:Hide() end
		if btn.Flash then btn.Flash:Hide() end
		
		local nt = btn:GetNormalTexture()
		if db and db.showgrid then
			if nt then
				nt:SetAlpha(0.6)
				nt:SetVertexColor(1, 1, 1, 1)
				nt:Show()
			end
			btn:SetAlpha(db.alpha or 1)
		else
			if nt then
				nt:SetAlpha(0)
				nt:Hide()
			end
			btn:SetAlpha(0)
		end
		btn:SetChecked(false)
		return
	end
	
	-- 쿨다운을 가장 먼저 갱신 (아래 코드에서 문제가 생겨도 재사용 대기시간은 표시되도록)
	if btn.UpdateCooldown then btn:UpdateCooldown() end

	local aType, aId = GetActionInfo(slot)
	local icon = GetActionTexture(slot)
	if not icon and aType == "macro" and aId then
		local mName, mIcon = GetMacroInfo(aId)
		icon = mIcon
	end
	
	if btn.icon then
		btn.icon:SetTexture(icon)
		if icon then
			btn.icon:Show()
		else
			btn.icon:Hide()
		end
	end
	
	if aType == "macro" and aId then
		local mName = GetMacroInfo(aId) or (GetActionText and GetActionText(slot))
		if btn.Name then
			btn.Name:SetText(mName or "")
			btn.Name:Show()
		end
	else
		if btn.Name then btn.Name:Hide() end
	end
	
	local nt = btn:GetNormalTexture()
	if nt then
		nt:Show()
		if Plain(IsEquippedAction(slot)) then
			nt:SetVertexColor(0, 1, 0, 1)
			nt:SetAlpha(1)
		else
			nt:SetVertexColor(1, 1, 1, 1)
			nt:SetAlpha(0)
		end
	end
	
	if btn.Flash then
		if Plain(IsAttackAction(slot)) and Plain(IsCurrentAction(slot)) then
			btn.Flash:Show()
		elseif Plain(IsAutoRepeatAction(slot)) then
			btn.Flash:Show()
		else
			btn.Flash:Hide()
		end
	end
	
	btn:SetAlpha(db and db.alpha or 1)
	local isUsable, notEnoughMana = IsUsableAction(slot)
	isUsable, notEnoughMana = Plain(isUsable), Plain(notEnoughMana)
	if isUsable then
		if btn.icon then btn.icon:SetVertexColor(1, 1, 1) end
	elseif notEnoughMana then
		if btn.icon then btn.icon:SetVertexColor(0.5, 0.5, 1) end
	else
		if btn.icon then btn.icon:SetVertexColor(0.4, 0.4, 0.4) end
	end
	
	if btn.UpdateCount then btn:UpdateCount() end
	if btn.UpdateChecked then btn:UpdateChecked() end
end

-- 12. 마우스 드래그 픽업 & 배치 인터랙션
local function SetupButtonDrag(btn)
	btn:RegisterForClicks("AnyDown", "AnyUp")
	btn:RegisterForDrag("LeftButton")

	btn:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end
		local slot = self.action or self.actionSlot or self:GetID()
		local isLocked = (LOCK_ACTIONBAR == "1" or LOCK_ACTIONBAR == 1) or (GetCVarBool and GetCVarBool("lockActionBars"))
		if slot and (not isLocked or IsShiftKeyDown() or IsModifiedClick("PICKUPACTION")) then
			self.justPickedUpTime = GetTime()
			PickupAction(slot)
		end
	end)

	btn:SetScript("OnReceiveDrag", function(self)
		if InCombatLockdown() then return end
		if self.justPickedUpTime and (GetTime() - self.justPickedUpTime < 0.35) then return end
		local slot = self.action or self.actionSlot or self:GetID()
		if slot and GetCursorInfo() then
			PlaceAction(slot)
			SyncButtonAction(self, slot)
			UpdateButtonVisual(self)
		end
	end)

	btn:SetScript("PreClick", function(self, button, down)
		if InCombatLockdown() then return end
		if button == "LeftButton" and GetCursorInfo() then
			if self.justPickedUpTime and (GetTime() - self.justPickedUpTime < 0.35) then return end
			local slot = self.action or self.actionSlot or self:GetID()
			if slot then
				PlaceAction(slot)
				SyncButtonAction(self, slot)
				UpdateButtonVisual(self)
			end
		end
	end)

	btn:SetScript("PostClick", function(self, button, down)
		UpdateCheckedState(self)
		if self.UpdateCooldown then self:UpdateCooldown() end
		if C_Timer and C_Timer.After then
			C_Timer.After(0.05, function()
				if self.UpdateCooldown then self:UpdateCooldown() end
			end)
		end
	end)
	
	btn:SetScript("OnEnter", function(self)
		local db = addon.db or _G[ADDON_NAME.."SaveData"] or default
		if db and db.mouseover then
			for j = 1, 12 do
				if addon[j] then addon[j]:SetAlpha(db.alpha or 1) end
			end
		end
		if db and db.hideTooltip then return end
		if InCombatLockdown() then return end
		local slot = self.actionSlot or self.action or self:GetID()
		if slot and HasAction(slot) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetAction(slot)
		end
	end)
	
	btn:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		local db = addon.db or _G[ADDON_NAME.."SaveData"] or default
		if db and db.mouseover and not InCombatLockdown() then
			for j = 1, 12 do
				if addon[j] then addon[j]:SetAlpha(0) end
			end
		end
	end)
end

-- 13. [CBO 핵심 인터페이스] Setup() 함수 구현
function addon:Setup()
	if InCombatLockdown() then return end
	
	if SetCVar then
		pcall(SetCVar, "countdownForCooldowns", "1")
	end
	
	_G[ADDON_NAME.."SaveData"] = _G[ADDON_NAME.."SaveData"] or default
	self.db = _G[ADDON_NAME.."SaveData"]
	for k, v in pairs(default) do
		if self.db[k] == nil then self.db[k] = v end
	end
	
	local step = self.db.step or 10
	local scale = self.db.scale or 1
	local alpha = self.db.alpha or 1
	local yOffset = (self.db.yOffset or 0) * step
	
	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "CENTER", 0, yOffset)
	self:SetScale(scale)
	self:SetAlpha(alpha)
	self:Show()
	
	local curPage = GetCurrentPage(self.db)
	
	for i = 1, 12 do
		local slot = (curPage - 1) * 12 + i
		local btn = self[i]
		if btn then
			btn.actionSlot = slot
			btn.action = slot
			btn:SetID(slot)
			SyncButtonAction(btn, slot)
			
			btn.UpdateCooldown = UpdateButtonCooldown
			btn.UpdateCount = UpdateButtonCount
			btn.UpdateChecked = UpdateCheckedState
			
			local rawX = (self.db.x and self.db.x[i]) or default.x[i] or 0
			local rawY = (self.db.y and self.db.y[i]) or default.y[i] or 0
			local bx = rawX * step
			local by = rawY * step
			
			btn:ClearAllPoints()
			btn:SetPoint("CENTER", self, "CENTER", bx, by)
			btn:SetAlpha(alpha)
			btn:SetScale(1)
			btn:Show()
			
			SetupButtonDrag(btn)
			UpdateButtonVisual(btn)
			
			local key = GetBindingKey("CENTARBARBUTTON"..i)
			if btn.HotKey then
				if key and key ~= "" then
					btn.HotKey:SetText(key)
				else
					btn.HotKey:SetText("")
				end
			end
		end
	end
	
	if UpdateBindings then UpdateBindings() end
end

-- 15. 풀 라이프사이클 이벤트 리스너 등록
addon:SetScript("OnEvent", function(self, event, ...)
	local arg1, arg2, arg3 = ...
	if event == "VARIABLES_LOADED" or event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		self:Setup()
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		for i = 1, 12 do
			local btn = self[i]
			if btn and (not arg1 or btn.actionSlot == arg1 or btn:GetID() == arg1) then
				SyncButtonAction(btn, btn.actionSlot or btn:GetID())
				UpdateButtonVisual(btn)
			end
		end
	elseif event == "UPDATE_MACROS" or event == "UPDATE_BINDINGS" or event == "ACTIONBAR_UPDATE_STATE" or event == "ACTIONBAR_UPDATE_USABLE" or event == "SPELL_UPDATE_USABLE" then
		for i = 1, 12 do
			local btn = self[i]
			if btn then UpdateButtonVisual(btn) end
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_CHARGES" or event == "SPELL_UPDATE_CHARGES" or event == "BAG_UPDATE_COOLDOWN" or event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
		for i = 1, 12 do
			local btn = self[i]
			if btn then
				UpdateButtonCooldown(btn)
				UpdateButtonCount(btn)
				UpdateButtonVisual(btn)
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		self:SetAlpha(1)
		for j = 1, 12 do
			local btn = self[j]
			if btn then
				UpdateButtonVisual(btn)
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		local db = self.db or _G[ADDON_NAME.."SaveData"]
		if db and db.combat then
			for j = 1, 12 do
				if self[j] then self[j]:SetAlpha(0) end
			end
		else
			for j = 1, 12 do
				if self[j] then self[j]:SetAlpha(db and db.alpha or 1) end
			end
		end
		for i = 1, 12 do
			local btn = self[i]
			if btn then
				SyncButtonAction(btn, btn.actionSlot or btn:GetID())
				UpdateButtonVisual(btn)
			end
		end
	end
end)

addon:RegisterEvent("VARIABLES_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
addon:RegisterEvent("UPDATE_MACROS")
addon:RegisterEvent("UPDATE_BINDINGS")
addon:RegisterEvent("ACTIONBAR_UPDATE_STATE")
addon:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
addon:RegisterEvent("SPELL_UPDATE_USABLE")
addon:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
addon:RegisterEvent("SPELL_UPDATE_COOLDOWN")
addon:RegisterEvent("ACTIONBAR_UPDATE_CHARGES")
addon:RegisterEvent("SPELL_UPDATE_CHARGES")
addon:RegisterEvent("BAG_UPDATE_COOLDOWN")
addon:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
addon:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")

-- 파일 로드 즉시 초기화 1회 실행
addon:Setup()

-- 16. [CBO 슬래시 명령어 완전 보장] 강제 활성화 및 100% 오픈
local function HandleCentarBarSlash(msg)
	if type(_G["CentarBar_Option"]) == "function" then
		local ok, err = pcall(_G["CentarBar_Option"])
		if not ok then
			print("|cffff0000[CentarBar 오류]|r 옵션창 실행 실패: " .. tostring(err))
		end
		return
	end
	
	local opt = _G["CentarBar_OptionFrame1"]
	if opt then
		if opt:IsShown() then opt:Hide() else opt:Show() end
		return
	end
	
	-- 동적 로드 시도
	if C_AddOns and C_AddOns.EnableAddOn then
		pcall(C_AddOns.EnableAddOn, "CentarBar_Option")
	elseif EnableAddOn then
		pcall(EnableAddOn, "CentarBar_Option")
	end
	local loadFn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
	if loadFn then
		pcall(loadFn, "CentarBar_Option")
	end
	
	if type(_G["CentarBar_Option"]) == "function" then
		_G["CentarBar_Option"]()
	elseif _G["CentarBar_OptionFrame1"] then
		_G["CentarBar_OptionFrame1"]:Show()
	else
		print("|cff00ff00[CentarBar]|r 옵션창(/cbo) 모듈을 불러오는 중입니다. 잠시 후 다시 시도해주세요.")
	end
end

SlashCmdList["CENTARBAR"] = HandleCentarBarSlash
SLASH_CENTARBAR1 = "/cbo"
SLASH_CENTARBAR2 = "/cb"
SLASH_CENTARBAR3 = "/centarbar"
SLASH_CENTARBAR4 = "/츄ㅐ"
SLASH_CENTARBAR5 = "/센타"
SLASH_CENTARBAR6 = "/중앙바"
