-- 레벨페이스 문자열 — @hyveo
-- 게임 언어(또는 hyveo 애드온 센터에서 고른 언어)에 맞춰 고르고, 번역이 없는 말은 영어로 보여 준다.
-- 번역이 어색하면 GitHub 이슈로 알려 주세요: https://github.com/hyveo/wow-forever-addons/issues

local _, ns = ...

local S = {}

S.enUS = {
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
	MSG_HELP     = "/lp — details  |  /lp bar — show/hide bar  |  /lp lock — lock/unlock bar  |  /lp reset — reset session  |  /lp minimap — show/hide minimap button",
	MM_LEFT      = "Left-click: details",
	MM_RIGHT     = "Right-click: show/hide the info bar",
	MM_DRAG      = "Drag: move this button",
	MM_HIDE      = "/lp minimap: hide this button",
	MSG_MM_ON    = "Minimap button shown.",
	MSG_MM_OFF   = "Minimap button hidden. Use /lp minimap to show it again.",
}

S.koKR = {
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
	MSG_HELP     = "/lp — 상세 창  |  /lp 바 — 바 보이기/숨기기  |  /lp 잠금 — 바 잠금/해제  |  /lp 초기화 — 세션 초기화  |  /lp 미니맵 — 미니맵 버튼 보이기/숨기기",
	MM_LEFT      = "왼쪽 클릭: 상세 창",
	MM_RIGHT     = "오른쪽 클릭: 정보 바 보이기/숨기기",
	MM_DRAG      = "드래그: 버튼 옮기기",
	MM_HIDE      = "/lp 미니맵: 이 버튼 숨기기",
	MSG_MM_ON    = "미니맵 버튼을 켰어요.",
	MSG_MM_OFF   = "미니맵 버튼을 숨겼어요. 다시 켜려면 /lp 미니맵",
}

S.deDE = {
	LEVEL        = "Stufe %d",
	MAX_LEVEL    = "Höchststufe",
	PER_HOUR     = "%s/Std.",
	TO_LEVEL     = "Stufenaufstieg in %s",
	CALCULATING  = "Wird berechnet…",
	NONE         = "Keine",
	TIME_HM      = "%d Std. %d Min.",
	TIME_M       = "%d Min.",
	TIME_LT1M    = "<1 Min.",
	MOBS         = "~%s Kills (letzter Kill %s EP)",

	ROW_LEVEL    = "Aktuelle EP",
	ROW_REMAIN   = "EP bis Stufenaufstieg",
	ROW_RESTED   = "Erholungs-EP",
	ROW_SESSION  = "Sitzungsdauer",
	ROW_GAINED   = "EP dieser Sitzung",
	ROW_RATE_S   = "EP/Std. (Sitzung)",
	ROW_RATE_R   = "EP/Std. (letzte 10 Min.)",
	ROW_ETA      = "Zeit bis Stufenaufstieg",
	ROW_SOURCES  = "Quests / Kills & Sonstiges",
	ROW_MOBS     = "Kills bis Stufenaufstieg",
	ROW_LVTIME   = "Zeit auf dieser Stufe",
	HISTORY      = "Stufenverlauf",
	HISTORY_LINE = "%d → %d: %s  (%s)",
	HISTORY_NONE = "Noch keine Stufenaufstiege aufgezeichnet.",

	BTN_RESET    = "Zurücksetzen",
	BTN_LOCK     = "Leiste sperren",
	BTN_UNLOCK   = "Entsperren",
	BTN_HIDE     = "Leiste aus",
	BTN_SHOW     = "Leiste an",

	TIP_DRAG     = "Ziehen zum Verschieben",
	TIP_LOCKED   = "Leiste ist gesperrt (/lp lock)",
	TIP_CLICK    = "Rechtsklick: Details öffnen",

	MSG_RESET    = "Sitzung zurückgesetzt.",
	MSG_LOCKED   = "Leiste gesperrt.",
	MSG_UNLOCKED = "Leiste entsperrt. Zum Verschieben ziehen.",
	MSG_HELP     = "/lp — Details  |  /lp bar — Leiste an/aus  |  /lp lock — sperren/entsperren  |  /lp reset — Sitzung zurücksetzen  |  /lp minimap — Minikartenknopf an/aus",
	MM_LEFT      = "Linksklick: Details",
	MM_RIGHT     = "Rechtsklick: Infoleiste an/aus",
	MM_DRAG      = "Ziehen: Knopf verschieben",
	MM_HIDE      = "/lp minimap: Knopf ausblenden",
	MSG_MM_ON    = "Minikartenknopf eingeblendet.",
	MSG_MM_OFF   = "Minikartenknopf ausgeblendet. Mit /lp minimap wieder einblenden.",
}

S.frFR = {
	LEVEL        = "Niv. %d",
	MAX_LEVEL    = "Niveau max",
	PER_HOUR     = "%s/h",
	TO_LEVEL     = "Niveau dans %s",
	CALCULATING  = "Calcul…",
	NONE         = "Aucune",
	TIME_HM      = "%dh %dmin",
	TIME_M       = "%dmin",
	TIME_LT1M    = "<1min",
	MOBS         = "~%s ennemis (dernier : %s XP)",

	ROW_LEVEL    = "XP actuelle",
	ROW_REMAIN   = "XP restante",
	ROW_RESTED   = "XP de repos",
	ROW_SESSION  = "Durée de session",
	ROW_GAINED   = "XP de la session",
	ROW_RATE_S   = "XP/h (session)",
	ROW_RATE_R   = "XP/h (10 dernières min)",
	ROW_ETA      = "Temps avant niveau",
	ROW_SOURCES  = "Quêtes / Ennemis et autres",
	ROW_MOBS     = "Ennemis avant niveau",
	ROW_LVTIME   = "Temps à ce niveau",
	HISTORY      = "Historique des niveaux",
	HISTORY_LINE = "%d → %d : %s  (%s)",
	HISTORY_NONE = "Aucun niveau enregistré pour l'instant.",

	BTN_RESET    = "Réinitialiser",
	BTN_LOCK     = "Verrouiller",
	BTN_UNLOCK   = "Déverrouiller",
	BTN_HIDE     = "Masquer",
	BTN_SHOW     = "Afficher",

	TIP_DRAG     = "Glisser pour déplacer",
	TIP_LOCKED   = "Barre verrouillée (/lp lock)",
	TIP_CLICK    = "Clic droit : détails",

	MSG_RESET    = "Session réinitialisée.",
	MSG_LOCKED   = "Barre verrouillée.",
	MSG_UNLOCKED = "Barre déverrouillée. Faites-la glisser pour la déplacer.",
	MSG_HELP     = "/lp — détails  |  /lp bar — afficher/masquer la barre  |  /lp lock — verrouiller/déverrouiller  |  /lp reset — réinitialiser la session  |  /lp minimap — bouton de la minicarte",
	MM_LEFT      = "Clic gauche : détails",
	MM_RIGHT     = "Clic droit : afficher/masquer la barre",
	MM_DRAG      = "Glisser : déplacer ce bouton",
	MM_HIDE      = "/lp minimap : masquer ce bouton",
	MSG_MM_ON    = "Bouton de la minicarte affiché.",
	MSG_MM_OFF   = "Bouton masqué. /lp minimap pour le réafficher.",
}

S.esES = {
	LEVEL        = "Nv. %d",
	MAX_LEVEL    = "Nivel máximo",
	PER_HOUR     = "%s/h",
	TO_LEVEL     = "Nivel en %s",
	CALCULATING  = "Calculando…",
	NONE         = "Ninguna",
	TIME_HM      = "%dh %dmin",
	TIME_M       = "%dmin",
	TIME_LT1M    = "<1min",
	MOBS         = "~%s enemigos (último: %s PX)",

	ROW_LEVEL    = "PX actual",
	ROW_REMAIN   = "PX restante",
	ROW_RESTED   = "PX de descanso",
	ROW_SESSION  = "Tiempo de sesión",
	ROW_GAINED   = "PX de la sesión",
	ROW_RATE_S   = "PX/h (sesión)",
	ROW_RATE_R   = "PX/h (últimos 10 min)",
	ROW_ETA      = "Tiempo hasta nivel",
	ROW_SOURCES  = "Misiones / Enemigos y otros",
	ROW_MOBS     = "Enemigos hasta nivel",
	ROW_LVTIME   = "Tiempo en este nivel",
	HISTORY      = "Historial de niveles",
	HISTORY_LINE = "%d → %d: %s  (%s)",
	HISTORY_NONE = "Aún no hay niveles registrados.",

	BTN_RESET    = "Reiniciar",
	BTN_LOCK     = "Bloquear barra",
	BTN_UNLOCK   = "Desbloquear",
	BTN_HIDE     = "Ocultar barra",
	BTN_SHOW     = "Mostrar barra",

	TIP_DRAG     = "Arrastra para mover",
	TIP_LOCKED   = "Barra bloqueada (/lp lock)",
	TIP_CLICK    = "Clic derecho: detalles",

	MSG_RESET    = "Sesión reiniciada.",
	MSG_LOCKED   = "Barra bloqueada.",
	MSG_UNLOCKED = "Barra desbloqueada. Arrástrala para moverla.",
	MSG_HELP     = "/lp — detalles  |  /lp bar — mostrar/ocultar barra  |  /lp lock — bloquear/desbloquear  |  /lp reset — reiniciar sesión  |  /lp minimap — botón del minimapa",
	MM_LEFT      = "Clic izquierdo: detalles",
	MM_RIGHT     = "Clic derecho: mostrar/ocultar barra",
	MM_DRAG      = "Arrastrar: mover este botón",
	MM_HIDE      = "/lp minimap: ocultar este botón",
	MSG_MM_ON    = "Botón del minimapa visible.",
	MSG_MM_OFF   = "Botón oculto. Usa /lp minimap para mostrarlo.",
}

S.ptBR = {
	LEVEL        = "Nv. %d",
	MAX_LEVEL    = "Nível máximo",
	PER_HOUR     = "%s/h",
	TO_LEVEL     = "Nível em %s",
	CALCULATING  = "Calculando…",
	NONE         = "Nenhuma",
	TIME_HM      = "%dh %dmin",
	TIME_M       = "%dmin",
	TIME_LT1M    = "<1min",
	MOBS         = "~%s abates (último: %s XP)",

	ROW_LEVEL    = "XP atual",
	ROW_REMAIN   = "XP restante",
	ROW_RESTED   = "XP descansado",
	ROW_SESSION  = "Tempo de sessão",
	ROW_GAINED   = "XP da sessão",
	ROW_RATE_S   = "XP/h (sessão)",
	ROW_RATE_R   = "XP/h (últimos 10 min)",
	ROW_ETA      = "Tempo até o nível",
	ROW_SOURCES  = "Missões / Abates e outros",
	ROW_MOBS     = "Abates até o nível",
	ROW_LVTIME   = "Tempo neste nível",
	HISTORY      = "Histórico de níveis",
	HISTORY_LINE = "%d → %d: %s  (%s)",
	HISTORY_NONE = "Nenhum nível registrado ainda.",

	BTN_RESET    = "Zerar sessão",
	BTN_LOCK     = "Travar barra",
	BTN_UNLOCK   = "Destravar",
	BTN_HIDE     = "Ocultar barra",
	BTN_SHOW     = "Mostrar barra",

	TIP_DRAG     = "Arraste para mover",
	TIP_LOCKED   = "Barra travada (/lp lock)",
	TIP_CLICK    = "Clique direito: detalhes",

	MSG_RESET    = "Sessão zerada.",
	MSG_LOCKED   = "Barra travada.",
	MSG_UNLOCKED = "Barra destravada. Arraste para mover.",
	MSG_HELP     = "/lp — detalhes  |  /lp bar — mostrar/ocultar barra  |  /lp lock — travar/destravar  |  /lp reset — zerar sessão  |  /lp minimap — botão do minimapa",
	MM_LEFT      = "Clique esquerdo: detalhes",
	MM_RIGHT     = "Clique direito: mostrar/ocultar barra",
	MM_DRAG      = "Arrastar: mover este botão",
	MM_HIDE      = "/lp minimap: ocultar este botão",
	MSG_MM_ON    = "Botão do minimapa visível.",
	MSG_MM_OFF   = "Botão oculto. Use /lp minimap para mostrar de novo.",
}

S.ruRU = {
	LEVEL        = "Ур. %d",
	MAX_LEVEL    = "Макс. уровень",
	PER_HOUR     = "%s/ч",
	TO_LEVEL     = "До уровня %s",
	CALCULATING  = "Расчёт…",
	NONE         = "Нет",
	TIME_HM      = "%d ч %d мин",
	TIME_M       = "%d мин",
	TIME_LT1M    = "<1 мин",
	MOBS         = "~%s убийств (последнее: %s опыта)",

	ROW_LEVEL    = "Текущий опыт",
	ROW_REMAIN   = "Осталось опыта",
	ROW_RESTED   = "Бонус отдыха",
	ROW_SESSION  = "Время сессии",
	ROW_GAINED   = "Опыт за сессию",
	ROW_RATE_S   = "Опыт/ч (сессия)",
	ROW_RATE_R   = "Опыт/ч (10 мин)",
	ROW_ETA      = "До уровня",
	ROW_SOURCES  = "Задания / Убийства и прочее",
	ROW_MOBS     = "Убийств до уровня",
	ROW_LVTIME   = "Время на уровне",
	HISTORY      = "История уровней",
	HISTORY_LINE = "%d → %d: %s  (%s)",
	HISTORY_NONE = "Пока нет записей.",

	BTN_RESET    = "Сбросить",
	BTN_LOCK     = "Закрепить",
	BTN_UNLOCK   = "Открепить",
	BTN_HIDE     = "Скрыть",
	BTN_SHOW     = "Показать",

	TIP_DRAG     = "Перетащите, чтобы переместить",
	TIP_LOCKED   = "Панель закреплена (/lp lock)",
	TIP_CLICK    = "ПКМ: подробности",

	MSG_RESET    = "Сессия сброшена.",
	MSG_LOCKED   = "Панель закреплена.",
	MSG_UNLOCKED = "Панель откреплена. Перетащите, чтобы переместить.",
	MSG_HELP     = "/lp — подробности  |  /lp bar — показать/скрыть панель  |  /lp lock — закрепить/открепить  |  /lp reset — сброс сессии  |  /lp minimap — кнопка у миникарты",
	MM_LEFT      = "ЛКМ: подробности",
	MM_RIGHT     = "ПКМ: показать/скрыть панель",
	MM_DRAG      = "Перетаскивание: переместить кнопку",
	MM_HIDE      = "/lp minimap: скрыть кнопку",
	MSG_MM_ON    = "Кнопка у миникарты показана.",
	MSG_MM_OFF   = "Кнопка скрыта. Вернуть: /lp minimap",
}

S.zhCN = {
	LEVEL        = "等级 %d",
	MAX_LEVEL    = "满级",
	PER_HOUR     = "%s/小时",
	TO_LEVEL     = "升级还需 %s",
	CALCULATING  = "计算中…",
	NONE         = "无",
	TIME_HM      = "%d小时%d分",
	TIME_M       = "%d分",
	TIME_LT1M    = "不到1分",
	MOBS         = "约 %s 只（上次 %s 经验）",

	ROW_LEVEL    = "当前经验",
	ROW_REMAIN   = "剩余经验",
	ROW_RESTED   = "休息经验",
	ROW_SESSION  = "本次时长",
	ROW_GAINED   = "本次获得经验",
	ROW_RATE_S   = "每小时（本次平均）",
	ROW_RATE_R   = "每小时（最近10分钟）",
	ROW_ETA      = "预计升级",
	ROW_SOURCES  = "任务 / 击杀及其他",
	ROW_MOBS     = "升级所需击杀",
	ROW_LVTIME   = "本级已用时间",
	HISTORY      = "升级记录",
	HISTORY_LINE = "%d → %d级：%s  (%s)",
	HISTORY_NONE = "还没有记录。",

	BTN_RESET    = "重置本次",
	BTN_LOCK     = "锁定信息条",
	BTN_UNLOCK   = "解锁信息条",
	BTN_HIDE     = "隐藏信息条",
	BTN_SHOW     = "显示信息条",

	TIP_DRAG     = "拖动：移动位置",
	TIP_LOCKED   = "信息条已锁定 (/lp lock)",
	TIP_CLICK    = "右键：打开详情",

	MSG_RESET    = "已重置本次记录。",
	MSG_LOCKED   = "信息条已锁定。",
	MSG_UNLOCKED = "信息条已解锁，可拖动移动。",
	MSG_HELP     = "/lp — 详情  |  /lp bar — 显示/隐藏信息条  |  /lp lock — 锁定/解锁  |  /lp reset — 重置本次  |  /lp minimap — 小地图按钮",
	MM_LEFT      = "左键：详情",
	MM_RIGHT     = "右键：显示/隐藏信息条",
	MM_DRAG      = "拖动：移动此按钮",
	MM_HIDE      = "/lp minimap：隐藏此按钮",
	MSG_MM_ON    = "已显示小地图按钮。",
	MSG_MM_OFF   = "已隐藏小地图按钮。用 /lp minimap 重新显示。",
}

S.zhTW = {
	LEVEL        = "等級 %d",
	MAX_LEVEL    = "滿級",
	PER_HOUR     = "%s/小時",
	TO_LEVEL     = "升級還需 %s",
	CALCULATING  = "計算中…",
	NONE         = "無",
	TIME_HM      = "%d小時%d分",
	TIME_M       = "%d分",
	TIME_LT1M    = "不到1分",
	MOBS         = "約 %s 隻（上次 %s 經驗）",

	ROW_LEVEL    = "目前經驗",
	ROW_REMAIN   = "剩餘經驗",
	ROW_RESTED   = "休息經驗",
	ROW_SESSION  = "本次時長",
	ROW_GAINED   = "本次獲得經驗",
	ROW_RATE_S   = "每小時（本次平均）",
	ROW_RATE_R   = "每小時（最近10分鐘）",
	ROW_ETA      = "預計升級",
	ROW_SOURCES  = "任務 / 擊殺及其他",
	ROW_MOBS     = "升級所需擊殺",
	ROW_LVTIME   = "本級已用時間",
	HISTORY      = "升級紀錄",
	HISTORY_LINE = "%d → %d級：%s  (%s)",
	HISTORY_NONE = "還沒有紀錄。",

	BTN_RESET    = "重設本次",
	BTN_LOCK     = "鎖定資訊列",
	BTN_UNLOCK   = "解鎖資訊列",
	BTN_HIDE     = "隱藏資訊列",
	BTN_SHOW     = "顯示資訊列",

	TIP_DRAG     = "拖曳：移動位置",
	TIP_LOCKED   = "資訊列已鎖定 (/lp lock)",
	TIP_CLICK    = "右鍵：開啟詳情",

	MSG_RESET    = "已重設本次紀錄。",
	MSG_LOCKED   = "資訊列已鎖定。",
	MSG_UNLOCKED = "資訊列已解鎖，可拖曳移動。",
	MSG_HELP     = "/lp — 詳情  |  /lp bar — 顯示/隱藏資訊列  |  /lp lock — 鎖定/解鎖  |  /lp reset — 重設本次  |  /lp minimap — 小地圖按鈕",
	MM_LEFT      = "左鍵：詳情",
	MM_RIGHT     = "右鍵：顯示/隱藏資訊列",
	MM_DRAG      = "拖曳：移動此按鈕",
	MM_HIDE      = "/lp minimap：隱藏此按鈕",
	MSG_MM_ON    = "已顯示小地圖按鈕。",
	MSG_MM_OFF   = "已隱藏小地圖按鈕。用 /lp minimap 重新顯示。",
}

-- 중남미 스페인어: 스페인 스페인어 위에 다른 말만 덮어쓴다
-- 중남미 스페인어: 스페인 스페인어를 그대로 쓴다
S.esMX = {}

-- 언어를 바꿀 때는 표를 새로 만들지 않고 내용만 바꾼다 (다른 곳에서 같은 표를 쓰고 있으므로)
local L = {}
ns.L = L

function ns.GameLocale()
	local g = GetLocale()
	if g == "enGB" then g = "enUS" end
	return g
end

-- choice: nil 또는 "auto" = 게임 언어, 아니면 언어 코드
function ns.ApplyLocale(choice)
	local code = (choice and choice ~= "auto" and S[choice]) and choice or ns.GameLocale()
	if not S[code] then code = "enUS" end
	ns.locale = code
	wipe(L)
	local chain = { "enUS" }
	if code == "esMX" then chain[#chain + 1] = "esES" end
	if code ~= "enUS" then chain[#chain + 1] = code end
	for _, c in ipairs(chain) do
		for k, v in pairs(S[c]) do L[k] = v end
	end
end

ns.ApplyLocale()
