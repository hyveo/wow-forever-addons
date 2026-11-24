# 게임 기능을 흉내 낸 가짜 환경에서 실제 애드온 코드를 돌려 보는 시나리오.
# 출력이 tests/expected/ 의 기대 결과와 같아야 한다 (tests/run_tests.py 가 비교).
import os
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
import lupa
L = lupa.LuaRuntime(unpack_returned_tuples=True)
L.execute(r'''
printed={} function print(...) local t={} for i=1,select("#",...) do t[#t+1]=tostring((select(i,...))) end table.insert(printed, table.concat(t," ")) end
function tinsert(t,v) table.insert(t,v) end
UISpecialFrames={} UIParent={}
frames={}
local function newframe()
  local f={scripts={},events={},shown=true}
  setmetatable(f,{__index=function(t,k) return function() end end})
  f.SetScript=function(self,k,v) self.scripts[k]=v end
  f.RegisterEvent=function(self,e) self.events[e]=true end
  f.UnregisterEvent=function(self,e) self.events[e]=nil end
  f.Show=function(self) self.shown=true end f.Hide=function(self) self.shown=false end f.IsShown=function(self) return self.shown end
  f.SetText=function(self,t) self.text=t end f.GetText=function(self) return self.text end
  f.CreateFontString=function() return newframe() end
  f.GetHeight=function() return 100 end f.GetVerticalScroll=function() return 0 end
  table.insert(frames,f) return f
end
function CreateFrame() return newframe() end
function fire(e,...) for _,f in ipairs(frames) do if f.events[e] and f.scripts.OnEvent then f.scripts.OnEvent(f,e,...) end end end
function GetLocale() return "koKR" end
function date() return "2026-11-25 01:30" end
function InCombatLockdown() return false end
function GetBuildInfo() return "1.60.1","12345","Nov 1",16002 end
C_AddOns={GetAddOnMetadata=function(a,f) return ({CenterBar="1.7.0",HyveoCenter="1.1.0",LevelPace="1.2.0"})[a] end, IsAddOnLoaded=function(a) return a~="LevelPace" end}
shown_default={}
local h=function(msg) table.insert(shown_default,msg) end
function geterrorhandler() return h end function seterrorhandler(f) h=f end
function debugstack() return "[Interface/AddOns/CenterBar/CenterBar.lua]:123: in function <x>" end
function raise(msg) h(msg) end
CLOSE="닫기"
''')
src=open(ROOT+"/addons/CenterBar/CenterBar/ErrorLog.lua",encoding="utf-8").read()
L.globals().SRC=src
L.execute(r'''
CenterBarGlobalDB={lang="koKR", errors={{addon="CenterBar",kind="error",msg="old saved error",time="2026-11-20 10:00",count=2}}}
NS1={locale="koKR"} NS2={locale="enUS"}
load(SRC,"ErrorLog.lua")("CenterBar",NS1)
load(SRC,"ErrorLog.lua")("HyveoCenter",NS2)
fire("ADDON_LOADED","CenterBar") fire("ADDON_LOADED","HyveoCenter") fire("PLAYER_LOGIN")
print("merged", HyveoErrorLog.Count(), "shared tables", tostring(CenterBarGlobalDB.errors==HyveoCenterDB.errors), "lang kept", CenterBarGlobalDB.lang)
raise("Interface/AddOns/CenterBar/CenterBar.lua:500: attempt to index nil")
raise("Interface/AddOns/CenterBar/CenterBar.lua:500: attempt to index nil")
raise("Interface/AddOns/SomeOther/x.lua:1: boom")
function debugstack() return "[Interface/AddOns/Blizzard_X/y.lua]:1" end
raise("Interface/AddOns/Other/z.lua:9: not ours")
fire("ADDON_ACTION_BLOCKED","HyveoCenter","SomeFunc()") fire("ADDON_ACTION_BLOCKED","Other","F()")
print("count", HyveoErrorLog.Count(), "default handler still called", #shown_default)
print(HyveoErrorLog.Report())
NS2.ShowErrorLog() print("title(en):", HyveoErrorLogFrame and "global" or "noglobal")
NS1.ShowErrorLog() NS1.ShowErrorLog()
HyveoErrorLog.Clear() print("after clear", HyveoErrorLog.Count(), #CenterBarGlobalDB.errors)
''')
for p in L.globals().printed.values(): print(p)
