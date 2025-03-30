-- Setup to wrap our stuff in a table so we don't pollute the global environment

local GV = _GV or getfenv(0)
local Core = GV.Core or {}
_GV.Core = Core

-- ****************
-- EntryPoint
-- ****************

local EventsFrame = CreateFrame("Frame")
EventsFrame:RegisterEvent("ADDON_LOADED")

-- ****************
-- Functions for event
-- ****************

local function OnAddonLoaded()
    EventsFrame:RegisterEvent("PLAYER_LOGIN")
    EventsFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    EventsFrame:RegisterEvent("UNIT_AURA")
    EventsFrame:RegisterEvent("UNIT_ATTACK")
    EventsFrame:RegisterEvent("UNIT_ATTACK_POWER")
    EventsFrame:RegisterEvent("UNIT_ATTACK_SPEED")
    EventsFrame:RegisterEvent("UNIT_DAMAGE")
    EventsFrame:RegisterEvent("UNIT_RESISTANCES")

    if (GV.Fns.CheckVars() == false) then
        GV.Fns.InitDB()
        GV.ChatCmd.InitSlashCommand()
        GV.Fns.DrawMainFrame()
        GV.Fns.SetTargetStats()
        GV.Fns.RefreshMainFrame()
    end
end

local function OnPlayerLogin()
end

local function OnPlayerTargetChanged()
    GV.Fns.SetTargetStats()
end

local function OnUnitAura()
    GV.Fns.SetTargetStats()
end

local function OnUnitAttack()
    GV.Fns.SetTargetStats()
end

local function OnUnitAttackPower()
    GV.Fns.SetTargetStats()
end

local function OnUnitAttackSpeed()
    GV.Fns.SetTargetStats()
end

local function OnUnitDamage()
    GV.Fns.SetTargetStats()
end

local function OnUnitResistance()
    GV.Fns.SetTargetStats()
end

-- ****************
-- Functions call when event trigger
-- ****************

local function Init()
    if (not event) then
        GV.Utils.SayD("event: nill")
    else
        GV.Utils.SayD("event: "..event)
    end

    if (event == "ADDON_LOADED") then OnAddonLoaded() end
    if (event == "PLAYER_LOGIN") then OnPlayerLogin() end
    if (event == "PLAYER_TARGET_CHANGED") then OnPlayerTargetChanged() end
    if (event == "UNIT_AURA") then OnUnitAura() end
    if (event == "UNIT_ATTACK") then OnUnitAttack() end
    if (event == "UNIT_ATTACK_POWER") then OnUnitAttackPower() end
    if (event == "UNIT_ATTACK_SPEED") then OnUnitAttackSpeed() end
    if (event == "UNIT_DAMAGE") then OnUnitDamage() end
    if (event == "UNIT_RESISTANCES") then OnUnitResistance() end
end
EventsFrame:SetScript("OnEvent", Init)

-- ****************
-- Function call every fps
-- ****************

local UpdateFrame = CreateFrame("Frame")

local function OnTick()
    --GV.Utils.Say("tick")
    GV.Fns.PrintSpellRange()
end

local timer = 0
local function Tick(...)
    timer = timer + arg1
    if timer > 0.25 then
        OnTick()
        timer = 0
    end
end
UpdateFrame:SetScript("OnUpdate", Tick)