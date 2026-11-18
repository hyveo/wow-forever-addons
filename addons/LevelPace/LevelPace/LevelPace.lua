-- 레벨페이스 (LevelPace) — 와우 포에버용 레벨링 도우미
-- 만든 사람: @hyveo  /  https://github.com/hyveo/wow-forever-addons

local ADDON_NAME = ...

---------------------------------------------------------------------------
-- 문자열
---------------------------------------------------------------------------
local L
if GetLocale() == "koKR" then
	L = {
		TITLE        = "레벨페이스",
		LEVEL        = "Lv %d",
		MAX_LEVEL    = "최대 레벨",
		PER_HOUR     = "%s/시간",
		TO_LEVEL     = "레벨업까지 %s",
		CALCULATING  = "계산 중…",
		NONE         = "없음",
		TIME_HM      = "%d시간 %d분",
		TIME_M       = "%d분",
		TIME_LT1M    = "1분 미만",
		MOBS         = "약 %s마리 (마지막 %s XP 기준)",

		ROW_LEVEL    = "현재 경험치",
		ROW_REMAIN   = "남은 경험치",
		ROW_RESTED   = "휴식 경험치",
		ROW_SESSION  = "세션 시간",
		ROW_GAINED   = "세션 획득",
		ROW_RATE_S   = "시간당 (세션 평균)",
		ROW_RATE_R   = "시간당 (최근 10분)",
		ROW_ETA      = "레벨업 예상",
		ROW_SOURCES  = "퀘스트 / 사냥·기타",
		ROW_MOBS     = "남은 사냥 수",
		ROW_LVTIME   = "이번 레벨 진행 시간",
		HISTORY      = "레벨업 기록",
		HISTORY_LINE = "%d → %d레벨: %s  (%s)",
		HISTORY_NONE = "아직 기록이 없어요.",

		BTN_RESET    = "세션 초기화",
		BTN_LOCK     = "바 잠금",
		BTN_UNLOCK   = "바 잠금 해제",
		BTN_HIDE     = "바 숨기기",
		BTN_SHOW     = "바 보이기",

		TIP_DRAG     = "드래그: 위치 이동",
		TIP_LOCKED   = "바가 잠겨 있어요 (/lp 잠금)",
		TIP_CLICK    = "우클릭: 상세 창 열기",

		MSG_RESET    = "세션 기록을 초기화했어요.",
		MSG_LOCKED   = "바를 잠갔어요.",
		MSG_UNLOCKED = "바 잠금을 풀었어요. 드래그해서 옮길 수 있어요.",
		MSG_HELP     = "/lp — 상세 창  |  /lp 바 — 바 보이기/숨기기  |  /lp 잠금 — 바 잠금/해제  |  /lp 초기화 — 세션 초기화",
	}
else
	L = {
		TITLE        = "LevelPace",
		LEVEL        = "Lv %d",
		MAX_LEVEL    = "Max level",
		PER_HOUR     = "%s/h",
		TO_LEVEL     = "Level in %s",
		CALCULATING  = "Calculating…",
		NONE         = "None",
		TIME_HM      = "%dh %dm",
		TIME_M       = "%dm",
		TIME_LT1M    = "<1m",
		MOBS         = "~%s kills (last kill %s XP)",

		ROW_LEVEL    = "Current XP",
		ROW_REMAIN   = "XP to level",
		ROW_RESTED   = "Rested XP",
		ROW_SESSION  = "Session time",
		ROW_GAINED   = "Session XP",
		ROW_RATE_S   = "XP/h (session)",
		ROW_RATE_R   = "XP/h (last 10 min)",
		ROW_ETA      = "Time to level",
		ROW_SOURCES  = "Quest / Kills & other",
		ROW_MOBS     = "Kills to level",
		ROW_LVTIME   = "Time at this level",
		HISTORY      = "Level history",
		HISTORY_LINE = "%d → %d: %s  (%s)",
		HISTORY_NONE = "No level-ups recorded yet.",

		BTN_RESET    = "Reset session",
		BTN_LOCK     = "Lock bar",
		BTN_UNLOCK   = "Unlock bar",
		BTN_HIDE     = "Hide bar",
		BTN_SHOW     = "Show bar",

		TIP_DRAG     = "Drag to move",
		TIP_LOCKED   = "Bar is locked (/lp lock)",
		TIP_CLICK    = "Right-click: open details",

		MSG_RESET    = "Session reset.",
		MSG_LOCKED   = "Bar locked.",
		MSG_UNLOCKED = "Bar unlocked. Drag it to move.",
		MSG_HELP     = "/lp — details  |  /lp bar — show/hide bar  |  /lp lock — lock/unlock bar  |  /lp reset — reset session",
	}
end

local function Print(msg)
	print("|cff66ccff" .. L.TITLE .. "|r: " .. msg)
end

---------------------------------------------------------------------------
-- 상태
---------------------------------------------------------------------------
local RECENT_WINDOW = 600   -- 최근 10분
local QUEST_MATCH_TIME = 3  -- 퀘스트 완료 후 이 시간 안에 들어온 경험치는 퀘스트로 분류
local HISTORY_MAX = 20

local db                    -- LevelPaceDB (캐릭터별 저장)
local session
local recent = {}           -- { {시각, 경험치}, ... }
local lastXP, lastMax, lastLevel
local questPending, questPendingTime = 0, 0
local levelTimeMark
local initialized = false

local function NewSession()
	session = { start = GetTime(), xp = 0, questXP = 0, killXP = 0, lastKillXP = nil }
	wipe(recent)
end
NewSession()

---------------------------------------------------------------------------
-- 도우미
---------------------------------------------------------------------------
-- 포에버(한밤 기반)는 일부 값을 비밀 값(secret value)으로 넘겨줄 수 있음 → 계산 전에 확인
local function IsSecret(v)
	return issecretvalue and issecretvalue(v) or false
end

local function ReadXP()
	local cur, max = UnitXP("player"), UnitXPMax("player")
	if IsSecret(cur) or IsSecret(max) then return nil end
	return cur, max
end

local function ReadRested()
	local rested = GetXPExhaustion()
	if not rested or IsSecret(rested) then return 0 end
	return rested
end

local function AtMaxLevel()
	local level = UnitLevel("player")
	if IsLevelAtEffectiveMaxLevel then
		return IsLevelAtEffectiveMaxLevel(level)
	end
	local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion()) or MAX_PLAYER_LEVEL
	if maxLevel and level >= maxLevel then return true end
	return (UnitXPMax("player") or 0) == 0
end

local function Num(n)
	n = math.floor((n or 0) + 0.5)
	if BreakUpLargeNumbers then return BreakUpLargeNumbers(n) end
	return tostring(n)
end

local function FormatTime(sec)
	if not sec or sec < 60 then return L.TIME_LT1M end
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	if h > 0 then return L.TIME_HM:format(h, m) end
	return L.TIME_M:format(m)
end

-- 이번 레벨에 머문 시간 (접속해 있던 시간만, 로그아웃 사이에도 이어짐)
local function FlushLevelTime()
	local now = GetTime()
	if levelTimeMark then
		db.levelTime = (db.levelTime or 0) + (now - levelTimeMark)
	end
	levelTimeMark = now
end

local function CurrentLevelTime()
	local extra = levelTimeMark and (GetTime() - levelTimeMark) or 0
	return (db.levelTime or 0) + extra
end

local function SessionRate()
	local elapsed = GetTime() - session.start
	if elapsed < 60 or session.xp <= 0 then return nil end
	return session.xp / elapsed * 3600
end

local function RecentRate()
	local now = GetTime()
	while recent[1] and (now - recent[1][1]) > RECENT_WINDOW do
		table.remove(recent, 1)
	end
	local span = math.min(RECENT_WINDOW, now - session.start)
	if span < 60 then return nil end
	local sum = 0
	for _, g in ipairs(recent) do sum = sum + g[2] end
	if sum <= 0 then return nil end
	return sum / span * 3600
end

-- 바와 레벨업 예상에 쓰는 속도: 최근 10분 우선, 없으면 세션 평균
local function BestRate()
	return RecentRate() or SessionRate()
end

---------------------------------------------------------------------------
-- 정보 바
---------------------------------------------------------------------------
local Refresh -- 아래에서 정의
local ToggleWindow

local bar = CreateFrame("Frame", "LevelPaceBar", UIParent, "BackdropTemplate")
bar:SetSize(280, 22)
bar:SetPoint("TOP", UIParent, "TOP", 0, -120)
bar:SetFrameStrata("MEDIUM")
bar:SetClampedToScreen(true)
bar:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	edgeSize = 1,
})
bar:SetBackdropColor(0, 0, 0, 0.6)
bar:SetBackdropBorderColor(0, 0, 0, 0.9)

bar.rested = bar:CreateTexture(nil, "BORDER")
bar.rested:SetColorTexture(0.0, 0.39, 0.88, 0.35)
bar.rested:SetPoint("TOPLEFT", 1, -1)
bar.rested:SetPoint("BOTTOMLEFT", 1, 1)

bar.fill = bar:CreateTexture(nil, "ARTWORK")
bar.fill:SetColorTexture(0.58, 0.0, 0.55, 0.55)
bar.fill:SetPoint("TOPLEFT", 1, -1)
bar.fill:SetPoint("BOTTOMLEFT", 1, 1)

bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
bar.text:SetPoint("CENTER")

bar:SetMovable(true)
bar:EnableMouse(true)
bar:RegisterForDrag("LeftButton")
bar:SetScript("OnDragStart", function(self)
	if not db.bar.locked then self:StartMoving() end
end)
bar:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	local point, _, relPoint, x, y = self:GetPoint()
	db.bar.point, db.bar.relPoint, db.bar.x, db.bar.y = point, relPoint, x, y
end)
bar:SetScript("OnMouseUp", function(_, button)
	if button == "RightButton" then ToggleWindow() end
end)
bar:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
	GameTooltip:AddLine(L.TITLE)
	GameTooltip:AddLine(db.bar.locked and L.TIP_LOCKED or L.TIP_DRAG, 1, 1, 1)
	GameTooltip:AddLine(L.TIP_CLICK, 1, 1, 1)
	GameTooltip:Show()
end)
bar:SetScript("OnLeave", function() GameTooltip:Hide() end)

local function UpdateBar()
	local level = UnitLevel("player")
	if AtMaxLevel() then
		bar.text:SetText(L.LEVEL:format(level) .. "  ·  " .. L.MAX_LEVEL)
		bar:SetWidth(math.max(160, bar.text:GetStringWidth() + 24))
		bar.fill:Hide()
		bar.rested:Hide()
		return
	end

	local cur, max = ReadXP()
	if not cur or max <= 0 then return end

	local pct = cur / max * 100
	local parts = { L.LEVEL:format(level), ("%.1f%%"):format(pct) }
	local rate = BestRate()
	if rate then
		parts[#parts + 1] = L.PER_HOUR:format(Num(rate))
		parts[#parts + 1] = L.TO_LEVEL:format(FormatTime((max - cur) / rate * 3600))
	else
		parts[#parts + 1] = L.CALCULATING
	end
	bar.text:SetText(table.concat(parts, "  ·  "))

	local width = math.max(220, bar.text:GetStringWidth() + 24)
	bar:SetWidth(width)
	local inner = width - 2

	local fillW = inner * cur / max
	if fillW < 1 then bar.fill:Hide() else bar.fill:SetWidth(fillW); bar.fill:Show() end

	local rested = ReadRested()
	local restedW = inner * math.min(cur + rested, max) / max
	if rested > 0 and restedW >= 1 then
		bar.rested:SetWidth(restedW)
		bar.rested:Show()
	else
		bar.rested:Hide()
	end
end

---------------------------------------------------------------------------
-- 상세 창
---------------------------------------------------------------------------
local win = CreateFrame("Frame", "LevelPaceWindow", UIParent, "BasicFrameTemplateWithInset")
win:SetSize(360, 470)
win:SetPoint("CENTER")
win:SetFrameStrata("DIALOG")
win:SetClampedToScreen(true)
win:SetMovable(true)
win:EnableMouse(true)
win:RegisterForDrag("LeftButton")
win:SetScript("OnDragStart", win.StartMoving)
win:SetScript("OnDragStop", win.StopMovingOrSizing)
win:Hide()
tinsert(UISpecialFrames, "LevelPaceWindow") -- Esc로 닫기

win.title = win:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
win.title:SetPoint("TOP", 0, -6)
win.title:SetText(L.TITLE)

local rows = {}
local ROW_KEYS = {
	"ROW_LEVEL", "ROW_REMAIN", "ROW_RESTED",
	"ROW_SESSION", "ROW_GAINED", "ROW_RATE_S", "ROW_RATE_R", "ROW_ETA",
	"ROW_SOURCES", "ROW_MOBS", "ROW_LVTIME",
}
for i, key in ipairs(ROW_KEYS) do
	local y = -36 - (i - 1) * 22
	local label = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", 18, y)
	label:SetText(L[key])
	local value = win:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	value:SetPoint("TOPRIGHT", -18, y)
	value:SetJustifyH("RIGHT")
	rows[key] = value
end

local historyTop = -36 - #ROW_KEYS * 22 - 8
win.historyTitle = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
win.historyTitle:SetPoint("TOPLEFT", 18, historyTop)
win.historyTitle:SetText(L.HISTORY)

win.history = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
win.history:SetPoint("TOPLEFT", 18, historyTop - 20)
win.history:SetPoint("RIGHT", -18, 0)
win.history:SetJustifyH("LEFT")
win.history:SetJustifyV("TOP")
win.history:SetSpacing(3)

local function MakeButton(text, x, onClick)
	local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
	b:SetSize(104, 22)
	b:SetPoint("BOTTOMLEFT", x, 12)
	b:SetText(text)
	b:SetScript("OnClick", onClick)
	return b
end

local SetBarLocked, SetBarShown, ResetSession

win.resetBtn = MakeButton(L.BTN_RESET, 14, function() ResetSession() end)
win.lockBtn  = MakeButton(L.BTN_LOCK, 128, function() SetBarLocked(not db.bar.locked) end)
win.showBtn  = MakeButton(L.BTN_HIDE, 242, function() SetBarShown(not db.bar.shown) end)

local function UpdateWindow()
	if not win:IsShown() then return end

	win.lockBtn:SetText(db.bar.locked and L.BTN_UNLOCK or L.BTN_LOCK)
	win.showBtn:SetText(db.bar.shown and L.BTN_HIDE or L.BTN_SHOW)

	local level = UnitLevel("player")
	local maxed = AtMaxLevel()
	local cur, max = ReadXP()
	local sRate, rRate = SessionRate(), RecentRate()
	local rate = rRate or sRate

	if maxed or not cur or max <= 0 then
		rows.ROW_LEVEL:SetText(L.LEVEL:format(level) .. (maxed and ("  ·  " .. L.MAX_LEVEL) or ""))
		rows.ROW_REMAIN:SetText("-")
		rows.ROW_RESTED:SetText("-")
		rows.ROW_ETA:SetText("-")
		rows.ROW_MOBS:SetText("-")
	else
		local remain = max - cur
		rows.ROW_LEVEL:SetText(("%s  ·  %s / %s (%.1f%%)"):format(L.LEVEL:format(level), Num(cur), Num(max), cur / max * 100))
		rows.ROW_REMAIN:SetText(Num(remain))

		local rested = ReadRested()
		rows.ROW_RESTED:SetText(rested > 0 and ("%s (%.1f%%)"):format(Num(rested), rested / max * 100) or L.NONE)

		rows.ROW_ETA:SetText(rate and FormatTime(remain / rate * 3600) or L.CALCULATING)

		local lastKill = session.lastKillXP
		if lastKill and lastKill > 0 then
			rows.ROW_MOBS:SetText(L.MOBS:format(Num(math.ceil(remain / lastKill)), Num(lastKill)))
		else
			rows.ROW_MOBS:SetText(L.CALCULATING)
		end
	end

	rows.ROW_SESSION:SetText(FormatTime(GetTime() - session.start))
	rows.ROW_GAINED:SetText(Num(session.xp))
	rows.ROW_RATE_S:SetText(sRate and Num(sRate) or L.CALCULATING)
	rows.ROW_RATE_R:SetText(rRate and Num(rRate) or L.CALCULATING)
	rows.ROW_SOURCES:SetText(Num(session.questXP) .. " / " .. Num(session.killXP))
	rows.ROW_LVTIME:SetText(maxed and "-" or FormatTime(CurrentLevelTime()))

	local lines = {}
	for i = 1, math.min(6, #db.history) do
		local h = db.history[i]
		lines[#lines + 1] = L.HISTORY_LINE:format(h.level - 1, h.level, FormatTime(h.seconds), h.date or "")
	end
	win.history:SetText(#lines > 0 and table.concat(lines, "\n") or L.HISTORY_NONE)
end

win:SetScript("OnShow", UpdateWindow)

---------------------------------------------------------------------------
-- 동작
---------------------------------------------------------------------------
Refresh = function()
	if not db then return end
	if db.bar.shown then UpdateBar() end
	UpdateWindow()
end

ToggleWindow = function()
	win:SetShown(not win:IsShown())
end

SetBarLocked = function(locked)
	db.bar.locked = locked
	Print(locked and L.MSG_LOCKED or L.MSG_UNLOCKED)
	UpdateWindow()
end

SetBarShown = function(shown)
	db.bar.shown = shown
	bar:SetShown(shown)
	Refresh()
end

ResetSession = function()
	NewSession()
	Print(L.MSG_RESET)
	Refresh()
end

local function ClassifyGain(delta)
	if questPending > 0 and (GetTime() - questPendingTime) <= QUEST_MATCH_TIME then
		session.questXP = session.questXP + delta
		questPending = math.max(0, questPending - delta)
	else
		session.killXP = session.killXP + delta
		session.lastKillXP = delta
		questPending = 0
	end
	Refresh()
end

local function AddGain(delta)
	session.xp = session.xp + delta
	recent[#recent + 1] = { GetTime(), delta }
	-- 퀘스트 완료 이벤트가 경험치 이벤트보다 늦게 올 수 있어서 잠깐 기다렸다 분류
	C_Timer.After(0.5, function() ClassifyGain(delta) end)
end

local function OnXPUpdate()
	local cur, max = ReadXP()
	if not cur then return end
	local level = UnitLevel("player")

	if lastXP and not AtMaxLevel() then
		local delta
		if level > lastLevel or cur < lastXP then
			delta = (lastMax - lastXP) + cur -- 레벨업으로 경험치가 0부터 다시 시작
		else
			delta = cur - lastXP
		end
		if delta > 0 then AddGain(delta) end
	end

	lastXP, lastMax, lastLevel = cur, max, level
	Refresh()
end

local function OnLevelUp(newLevel)
	FlushLevelTime()
	table.insert(db.history, 1, {
		level = newLevel,
		seconds = db.levelTime or 0,
		date = date("%m/%d"),
	})
	while #db.history > HISTORY_MAX do table.remove(db.history) end
	db.levelTime = 0
	levelTimeMark = GetTime()
	Refresh()
end

local function ApplyBarPosition()
	bar:ClearAllPoints()
	if db.bar.point then
		bar:SetPoint(db.bar.point, UIParent, db.bar.relPoint or db.bar.point, db.bar.x or 0, db.bar.y or 0)
	else
		bar:SetPoint("TOP", UIParent, "TOP", 0, -120)
	end
	bar:SetShown(db.bar.shown)
end

---------------------------------------------------------------------------
-- 이벤트
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_XP_UPDATE")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("QUEST_TURNED_IN")
events:RegisterEvent("UPDATE_EXHAUSTION")
events:RegisterEvent("PLAYER_LOGOUT")

events:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" then
		if ... ~= ADDON_NAME then return end
		LevelPaceDB = LevelPaceDB or {}
		db = LevelPaceDB
		db.bar = db.bar or {}
		if db.bar.shown == nil then db.bar.shown = true end
		if db.bar.locked == nil then db.bar.locked = false end
		db.history = db.history or {}
		db.levelTime = db.levelTime or 0
		ApplyBarPosition()

	elseif event == "PLAYER_ENTERING_WORLD" then
		if initialized then return end
		initialized = true
		local cur, max = ReadXP()
		lastXP, lastMax, lastLevel = cur, max, UnitLevel("player")
		levelTimeMark = GetTime()
		C_Timer.NewTicker(1, Refresh)
		Refresh()

	elseif event == "PLAYER_XP_UPDATE" then
		if initialized then OnXPUpdate() end

	elseif event == "PLAYER_LEVEL_UP" then
		if initialized then OnLevelUp(...) end

	elseif event == "QUEST_TURNED_IN" then
		local _, xpReward = ...
		if xpReward and not IsSecret(xpReward) and xpReward > 0 then
			questPending = questPending + xpReward
			questPendingTime = GetTime()
		end

	elseif event == "UPDATE_EXHAUSTION" then
		Refresh()

	elseif event == "PLAYER_LOGOUT" then
		if db and levelTimeMark then FlushLevelTime() end
	end
end)

---------------------------------------------------------------------------
-- 명령어
---------------------------------------------------------------------------
SLASH_LEVELPACE1 = "/lp"
SLASH_LEVELPACE2 = "/levelpace"
SLASH_LEVELPACE3 = "/레벨"
SLASH_LEVELPACE4 = "/레벨페이스"

SlashCmdList.LEVELPACE = function(msg)
	msg = strlower(strtrim(msg or ""))
	if msg == "" then
		ToggleWindow()
	elseif msg == "bar" or msg == "바" then
		SetBarShown(not db.bar.shown)
	elseif msg == "lock" or msg == "잠금" then
		SetBarLocked(not db.bar.locked)
	elseif msg == "reset" or msg == "초기화" then
		ResetSession()
	else
		Print(L.MSG_HELP)
	end
end

---------------------------------------------------------------------------
-- 다른 애드온(hyveo 애드온 센터 등)에서 쓰는 공개 API
---------------------------------------------------------------------------
LevelPace = {
	ToggleWindow = function() ToggleWindow() end,
	IsBarShown   = function() return db and db.bar.shown or false end,
	SetBarShown  = function(v) if db then SetBarShown(v and true or false) end end,
	IsBarLocked  = function() return db and db.bar.locked or false end,
	SetBarLocked = function(v) if db and db.bar.locked ~= (v and true or false) then SetBarLocked(v and true or false) end end,
}
