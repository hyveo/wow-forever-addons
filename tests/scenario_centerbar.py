# 게임 기능을 흉내 낸 가짜 환경에서 실제 애드온 코드를 돌려 보는 시나리오.
# 출력이 tests/expected/ 의 기대 결과와 같아야 한다 (tests/run_tests.py 가 비교).
import os
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
import lupa, sys
L = lupa.LuaRuntime(unpack_returned_tuples=True)
L.execute(r'''
T=0; calls={}; wraps={}
function GetLocale() return "koKR" end
function wipe(t) for k in pairs(t) do t[k]=nil end return t end
function strlower(s) return s:lower() end function strtrim(s) return (s:gsub("^%s+",""):gsub("%s+$","")) end
function tinsert(t,v) table.insert(t,v) end
UISpecialFrames={} UIParent={GetEffectiveScale=function() return 0.64 end} Minimap={GetWidth=function() return 140 end} UIParent={GetEffectiveScale=function() return 0.64 end}
local function newframe(name)
  local f = {attrs={}, scripts={}, shown=true, pts={}}
  local mt = {__index=function(t,k)
     for _,pre in ipairs({"Set","Get","Clear","Enable","Register","Create","Hook","Update","Remove","Is","Start","Stop","Add","Unregister"}) do
       if k:sub(1,#pre)==pre then return function(self, ...) return nil end end
     end
     return nil end}
  setmetatable(f, mt)
  f.SetAttribute=function(self,k,v) self.attrs[k]=v end
  f.GetAttribute=function(self,k) return self.attrs[k] end
  f.SetScript=function(self,k,v) self.scripts[k]=v end
  f.HookScript=function(self,k,v) self.hooked=self.hooked or {} self.hooked[k]=self.hooked[k] or {} table.insert(self.hooked[k],v) end
  f.GetScript=function(self,k) return self.scripts[k] end
  f.Show=function(self) self.shown=true end
  f.Hide=function(self) self.shown=false end
  f.SetShown=function(self,v) self.shown=v and true or false end
  f.IsShown=function(self) return self.shown end
  f.GetName=function() return name or "anon" end
  f.GetFrameLevel=function() return 1 end
  f.SetPoint=function(self,...) self.pts={...} end
  f.GetAlpha=function() return 1 end
  f.GetEffectiveScale=function() return 1 end
  f.GetCenter=function() return 400,300 end
  f.IsMouseOver=function() return false end
  local tex = setmetatable({}, mt)
  f.SlotBackground=setmetatable({}, mt)
  f.CreateTexture=function() return setmetatable({}, mt) end
  f.CreateFontString=function() return setmetatable({}, mt) end
  f.GetNormalTexture=function() return tex end
  f.GetPushedTexture=function() return tex end
  f.GetHighlightTexture=function() return tex end
  f.GetCheckedTexture=function() return tex end
  f.icon=setmetatable({}, mt)
  f.cooldown=setmetatable({}, mt)
  f.CreateTexture=function() local t=setmetatable({shown=true}, mt) t.SetShown=function(self,v) self.shown=v end t.IsShown=function(self) return self.shown end t.Show=function(self) self.shown=true end t.Hide=function(self) self.shown=false end return t end
  return f
end
allframes={}
function CreateFrame(_, name) local f=newframe(name) if name then _G[name]=f end table.insert(allframes,f) return f end
GameTooltip=CreateFrame()
GameTooltip.SetSpellBookItem=function(self,slot,bank) tipcall="book "..slot end
GameTooltip.SetSpellByID=function(self,id) tipcall="id "..id end
GameTooltip.SetItemByID=function(self,id) tipcall="item "..id end
GameTooltip.NumLines=function() return 3 end
function hooksecurefunc(t,k,h) if type(t)=='table' and t[k] then local o=t[k] t[k]=function(...) local r={o(...)} h(...) return table.unpack(r) end end end
function SecureHandlerWrapScript(f, s, h, pre) table.insert(wraps, s) end
function RegisterStateDriver(f,k,v) f.driver=v end function UnregisterStateDriver() end
function InCombatLockdown() return false end
function GetCVarBool() return true end

function HasAction(s) return s==13 end
function GetActionTexture(s) if s==13 then return 136000 end end
function IsUsableAction() return true,false end function IsCurrentAction() return false end function IsAutoRepeatAction() return false end
function GetActionCooldown() return 0,0,1,1 end function GetActionCount() return 3 end
function GetBindingKey() return nil end
cursor=nil
function GetCursorInfo() if cursor then return table.unpack(cursor) end end
function ClearCursor() cursor=nil end
C_Spell={GetSpellTexture=function(id) return 1000+id end, IsSpellUsable=function() return true,false end, IsCurrentSpell=function() return false end,
 GetSpellSubtext=function(id) if id==777 or id==300 then return '2 레벨' end return '' end, GetSpellCooldown=function() return {startTime=0,duration=0,modRate=1} end}
GameTooltipTextRight1={txt=nil, IsShown=function(self) return self.txt~=nil end, GetText=function(self) return self.txt end, SetText=function(self,t) self.txt=t end, SetTextColor=function() end, Show=function() end}
C_SpellBook={FindSpellBookSlotForSpell=function(id) if id==777 then return 12,0 end end}
C_Item={GetItemIconByID=function(id) return 2000+id end, GetItemCount=function() return 5 end}
function GetMacroInfo(i) if i==3 then return "MyMacro", 555 end end
function GetMacroIndexByName(n) if n=="MyMacro" then return 4 end return 0 end
function GetActionInfo(a) if a==13 then return "spell", 100 elseif a==14 then return "item", 200 elseif a==109 then return "macro", 3 elseif a==145 then return "spell", 300 end end
function GetCursorPosition() return 500,300 end function UnitExists() return false end
function GetSpecialization() return 1 end
function GetNumSpecializations() return 3 end
printed={} function print(...) table.insert(printed, table.concat({...}," ")) end
SlashCmdList={}
''')
L.execute("NS={}")
for f in ["Locales.lua","CenterBar.lua","CenterBar_Options.lua"]:
    src=open(ROOT+"/addons/CenterBar/CenterBar/"+f,encoding="utf-8").read()
    L.globals().SRC=src
    L.execute("local fn,err=load(SRC,'"+f+"') if not fn then error(err) end fn('CenterBar',NS)")
L.execute(r"""
local n=0 local evf for _,f in ipairs(allframes) do if f.scripts.OnEvent then n=n+1 if n==2 then evf=f end end end
CenterBarDB={version=1, specPages={[1]=7}}
evf.scripts.OnEvent(evf,"ADDON_LOADED","CenterBar")
evf.scripts.OnEvent(evf,"CVAR_UPDATE")
evf.scripts.OnEvent(evf,"PLAYER_LOGIN")
evf.scripts.OnEvent(evf,"PLAYER_ENTERING_WORLD")
local function show(i) local b=_G["CenterBarButton"..i] return string.format("b%d type=%s spell=%s item=%s macro=%s", i, tostring(b.attrs.type), tostring(b.attrs.spell), tostring(b.attrs.item), tostring(b.attrs.macro)) end
print("b1", CenterBarButton1.pts[4], CenterBarButton1.pts[5], "b4", CenterBarButton4.pts[4], CenterBarButton4.pts[5], "preset", CenterBar.Get("preset"))
print("import:", show(1), show(2), show(13), show(3))
SlashCmdList.CENTERBAR("2") print("slot2:", show(1), show(2))
-- place a spell on button 2 of slot 2 through the catcher
cursor={"spell", 7, "spell", 777, 778}
local catch for _,f in ipairs(allframes) do if f.scripts.OnReceiveDrag and f.scripts.OnClick then catch=catch or {} table.insert(catch,f) end end
catch[2].scripts.OnReceiveDrag(catch[2])
print("placed:", show(2), "cursor cleared:", tostring(cursor==nil))

-- spellbook mock
SpellBookItemMixin={} 
function SpellBookItemMixin:UpdateActionBarAnim() self.Button.ActionBarHighlight.Anim.playing = self.missing end
local function item(id, missing) local a={playing=false} a.IsPlaying=function(s) return s.playing end a.Stop=function(s) s.playing=false end
  local it=setmetatable({missing=missing, spellBookItemInfo={spellID=id, actionID=id}, Button={ActionBarHighlight={Anim=a}}},{__index=SpellBookItemMixin}) return it end
local pre=item(777,true)  -- created before hook (copies old method like Mixin would)
pre.UpdateActionBarAnim=SpellBookItemMixin.UpdateActionBarAnim
local items={pre}
PlayerSpellsFrame={SpellBookFrame={IsVisible=function() return true end, HookScript=function(self,k,f) self.onshow=f end,
  ForEachDisplayedSpell=function(self,f) for _,it in ipairs(items) do f(it) end end}}
C_Timer={After=function(t,f) f() end}
C_Spell.GetBaseSpell=function(id) if id==778 then return 777 end return id end
C_Spell.GetSpellName=function(id) return "n"..id end
evf.scripts.OnEvent(evf,"ADDON_LOADED","Blizzard_PlayerSpells")
local a=item(777,true) local b=item(999,true) local c=item(778,true) table.insert(items,a) table.insert(items,b) table.insert(items,c)
a:UpdateActionBarAnim() b:UpdateActionBarAnim() c:UpdateActionBarAnim() pre:UpdateActionBarAnim()
print("hooked: in-bar glow", tostring(a.Button.ActionBarHighlight.Anim.playing), "override glow", tostring(c.Button.ActionBarHighlight.Anim.playing), "not-in-bar glow", tostring(b.Button.ActionBarHighlight.Anim.playing), "pre(unhooked) glow", tostring(pre.Button.ActionBarHighlight.Anim.playing))
PlayerSpellsFrame.SpellBookFrame.onshow()
print("after show: pre glow", tostring(pre.Button.ActionBarHighlight.Anim.playing))
-- remove from bar -> glow returns; put 999 -> glow off
cursor={"spell", 9, "spell", 999, 999}
catch[2].scripts.OnReceiveDrag(catch[2])
print("after swap: 777 glow", tostring(a.Button.ActionBarHighlight.Anim.playing), "999 glow", tostring(b.Button.ActionBarHighlight.Anim.playing), "cursor", cursor and cursor[1])

-- mount placement
C_MountJournal={GetMountInfoByID=function(id) if id==55 then return "곰", 9001, 123 end end, GetNumDisplayedMounts=function() return 3 end,
  GetDisplayedMountID=function(i) return ({11,55,77})[i] end, Pickup=function(i) cursor={"mount",55,i} picked="mount"..i end}
cursor={"mount",55,2}
catch[3].scripts.OnReceiveDrag(catch[3])
print("mount placed:", show(3), "cursor", tostring(cursor))
C_PetJournal={GetPetInfoByPetID=function(g) return 1,"",1,0,0,0,false,"고양이",777 end, SummonPetByGUID=function(g) summoned=(summoned or 0)+1 end, PickupPet=function(g) picked="pet" end}
cursor={"battlepet","BattlePet-0-1"} catch[5].scripts.OnReceiveDrag(catch[5]) print("pet placed:", CenterBarButton5.content.t, CenterBarButton5.content.name, show(5))
function GetCVarBool() return true end
for _,h in ipairs(CenterBarButton5.hooked.OnClick) do h(CenterBarButton5,"LeftButton",true) h(CenterBarButton5,"LeftButton",false) end print("pet summons per click:", tostring(summoned))
picked=nil shift=true function IsShiftKeyDown() return true end function IsModifiedClick() return false end for _,h in ipairs(CenterBarButton5.hooked.OnDragStart) do h(CenterBarButton5) end print("pet removed:", tostring(CenterBarButton5.content), tostring(picked)) cursor=nil
cursor={"flyout",1} catch[4].scripts.OnReceiveDrag(catch[4]) print("other refused:", printed[#printed]) cursor=nil
-- item that game won't pick up: drag-out must still clear
cursor={"item", 4242, "link"} catch[4].scripts.OnReceiveDrag(catch[4]) print("item placed:", show(4))
C_Container={GetContainerNumSlots=function(b) return 4 end, GetContainerItemID=function(b,sl) if b==1 and sl==3 then return 4242 end end, PickupContainerItem=function(b,sl) picked="bag"..b.."/"..sl end}
shift=false function IsShiftKeyDown() return shift end function IsModifiedClick() return false end
CenterBarButton4.attrs["cb-lock"]=true
for _,f in ipairs(CenterBarButton4.hooks or {}) do end
local function drag(b) if b.hooked and b.hooked.OnDragStart then for _,h in ipairs(b.hooked.OnDragStart) do h(b) end end end
drag(CenterBarButton4) print("locked, no shift:", show(4))
shift=true drag(CenterBarButton4) print("locked + shift:", show(4), "picked", tostring(picked))
picked=nil drag(CenterBarButton3) print("mount removed:", show(3), "picked", tostring(picked))

local function full(i) local b=_G["CenterBarButton"..i] local a=b.attrs return string.format("b%d t=%s type=%s spell=%s toy=%s set=%s action=%s", i, tostring(b.content and b.content.t), tostring(a.type), tostring(a.spell), tostring(a.toy), tostring(a.equipmentset), tostring(a.action)) end
function PlayerHasToy(id) return id==8080 end C_Item.GetItemCount=function(id) if id==8080 then return 0 end return 5 end
cursor={"item",8080,"link"} catch[6].scripts.OnReceiveDrag(catch[6]) print(full(6))
cursor={"equipmentset","탱킹"} catch[7].scripts.OnReceiveDrag(catch[7]) print(full(7))
cursor={"petaction",3110,4} catch[8].scripts.OnReceiveDrag(catch[8]) print(full(8))
function GetPetActionInfo(i) return "PET_ACTION_ATTACK","tex" end
cursor={"petaction",0,1} catch[9].scripts.OnReceiveDrag(catch[9]) print(full(9))
cursor={"flyout",12,555} catch[10].scripts.OnReceiveDrag(catch[10]) print(full(10))
cursor={"money",100} catch[11].scripts.OnReceiveDrag(catch[11]) print(full(11), printed[#printed]) cursor=nil
cursor={"item",4242,"l"} catch[11].scripts.OnReceiveDrag(catch[11]) print(full(11))
""")
for p in L.globals().printed.values(): print(p)
