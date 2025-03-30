local GV = _GV or getfenv(0)
local Fns = GV.Fns or {}
_GV.Fns = Fns

-- ****************
-- Database
-- ****************

local function SetDefaultDB()
    if (not VazabTargetInfoDB) then
        VazabTargetInfoDB = {}
    end

    VazabTargetInfoDB.MainFrameShow = 0
    VazabTargetInfoDB.MainFrameScale = 1
    VazabTargetInfoDB.MainFrameAlpha = 0.5
    VazabTargetInfoDB.MainFramePosX = 0
    VazabTargetInfoDB.MainFramePosY = 0
    VazabTargetInfoDB.SpellRange = 0
    VazabTargetInfoDB.MainFrameBackdrop = 1
end

function Fns.InitDB()
    if (not VazabTargetInfoDB) then
        SetDefaultDB()
        GV.Utils.SayD("InitDB")
    end
end

-- ****************
-- Vars
-- ****************

local MainFrame
local TargetStatsText
local TargetRangeText

function Fns.CheckVars()
    if (not MainFrame)
    or (not TargetFrame) 
    or (not TargetRangeText) then
        return false
    else
        return true
    end
end

-- ****************
-- Functions common
-- ****************

-- ****************MainFrameRefresh

local function DrawBackdrop()
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile="false", tileSize="8", edgeSize="8",
        insets = { left="2", right="2", top="2", bottom="2", },
    }
    if (VazabTargetInfoDB.MainFrameBackdrop == 1) then
        MainFrame:SetBackdrop(backdrop)
        MainFrame:SetBackdropColor(0, 0, 0, 1)
    else
        MainFrame:SetBackdrop(nil)
    end
end

function Fns.RefreshMainFrame()
    DrawBackdrop()
    
    if (VazabTargetInfoDB.MainFrameShow == 1) then
        MainFrame:Show()
    else
        MainFrame:Hide()
    end
    
    MainFrame:SetScale(VazabTargetInfoDB.MainFrameScale)
    MainFrame:SetAlpha(VazabTargetInfoDB.MainFrameAlpha)
    MainFrame:SetPoint("CENTER", UIParent, "CENTER", VazabTargetInfoDB.MainFramePosX, VazabTargetInfoDB.MainFramePosY)
end

function Fns.ResetMainFrame()
    MainFrame:ClearAllPoints()
    SetDefaultDB()
    Fns.RefreshMainFrame()
end

-- ****************DrawMainFrame

function Fns.DrawMainFrame()
    MainFrame = CreateFrame("Frame", "MainFrame", UIParent)
    
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile="false", tileSize="8", edgeSize="8",
        insets = { left="2", right="2", top="2", bottom="2", },
    }
    
    MainFrame:SetWidth(230)
    MainFrame:SetHeight(160)
    MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    MainFrame:SetFrameStrata("BACKGROUND")
    
    local fontSize = 14
    local font, size, flags = GameFontNormal:GetFont()
    TargetStatsText = MainFrame:CreateFontString()
    TargetStatsText:SetFontObject(GameFontNormal)
    TargetStatsText:SetPoint("Topleft", MainFrame, "Topleft", 8, -8)
    TargetStatsText:SetJustifyH("LEFT")
    TargetStatsText:SetJustifyV("TOP")
    TargetStatsText:SetFont(font, fontSize, "OUTLINE");

    TargetRangeText = MainFrame:CreateFontString()
    TargetRangeText:SetFontObject(GameFontNormal)
    TargetRangeText:SetPoint("Topleft", MainFrame, "Topleft", 8, 18)
    TargetRangeText:SetJustifyH("LEFT")
    TargetRangeText:SetJustifyV("TOP")
    TargetRangeText:SetFont(font, fontSize, "OUTLINE");
end

-- ****************DpsStats

local function GetMitigatedDmg(dmg)
    local armor = UnitResistance("player", 0)
    if armor < 0 then armor = 0 end
    local targetLevel = UnitLevel("target")
    local tmpvalue = 0.1 * armor / (8.5 * targetLevel + 40)
    tmpvalue = tmpvalue / (1 + tmpvalue)
    if tmpvalue < 0 then tmpvalue = 0 end
    if tmpvalue > 0.75 then tmpvalue = 0.75 end
    return dmg - (dmg * tmpvalue)
end

function Fns.SetTargetStats()
    if (UnitExists("target")) and (not UnitIsPlayer("target")) then
        -- Swing damage
        MainFrame:SetAlpha(VazabTargetInfoDB.MainFrameAlpha)
        local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("target")

        local lowDmgMiti = floor(GetMitigatedDmg(lowDmg))
        local hiDmgMiti = ceil(GetMitigatedDmg(hiDmg))

        local swingstring = "|cffFFFFFFSwing:"..floor(lowDmg).."-"..ceil(hiDmg)
        local swingstringMiti = "|cff74B72E"..floor(lowDmgMiti).."-"..ceil(hiDmgMiti)

        if (offlowDmg > 1) then -- means the mob has an offhand weapon
            swingstring = swingstring.." |cffFF0000DW!"
            swingstringMiti = swingstringMiti.." |cffFF0000DW!"
        end
        
        --Attack power
        base, buff, debuff = UnitAttackPower("target");
        local currentap = base + buff + debuff;
        local apstring = "|cffFFFFFFAP: "..currentap.."/"..base;
        local apdiff = base - currentap
        
        if UnitLevel("player") == 60 and apdiff <= 110 then -- warns when mob does not have demo shout or demo roar
            apstring = apstring.." |cffFF0000DEMO!";
        end
        
        --Attack Speed
        mainSpeed = UnitAttackSpeed("target");
        local speedstring = "|cffFFFFFFAS: "..string.format("%.2f", mainSpeed);
        
        --Estimated DPS
        local dpscalc = floor(lowDmg*0.5/mainSpeed + hiDmg*0.5/mainSpeed)
        local dpscalcMiti = floor(lowDmgMiti*0.5/mainSpeed + hiDmgMiti*0.5/mainSpeed)
        dpscalcMiti = "|cff74B72E"..dpscalcMiti
        
        local finalTextDps =
        swingstring.." ("..swingstringMiti..")\n"
        ..apstring.."\n"
        ..speedstring.." | DPS: "..dpscalc.." ("..dpscalcMiti..")"

        local physres = UnitResistance("target", 0)
        local holyres = UnitResistance("target", 1)
        local fireres = UnitResistance("target", 2)
        local natures = UnitResistance("target", 3)
        local frosres = UnitResistance("target", 4)
        local shadres = UnitResistance("target", 5)
        local arcares = UnitResistance("target", 6)
        local finalTextRes = ""

        if (physres > 0) then finalTextRes = finalTextRes.."|cffFFFFFFarmor: "..physres end
        if (holyres > 0) then finalTextRes = finalTextRes.."\nholy: "..holyres end
        if (fireres > 0) then finalTextRes = finalTextRes.."\nfire: "..fireres end
        if (natures > 0) then finalTextRes = finalTextRes.."\nnature: "..natures end
        if (frosres > 0) then finalTextRes = finalTextRes.."\nfrost: "..frosres end
        if (shadres > 0) then finalTextRes = finalTextRes.."\nshadow: "..shadres end
        if (arcares > 0) then finalTextRes = finalTextRes.."\narcane: "..arcares end

        -- Print combined text
        TargetStatsText:SetText(
            finalTextDps.."\n"
            ..finalTextRes
        )
    else
        MainFrame:SetAlpha(0)
        TargetStatsText:SetText(" ") -- if not targeting an enemy mob, print nothing.
    end
end

-- ****************SpellRange

local function ReportActionButtons()
    -- 25-36 most vert right bar
    local actionSlot = 0;
    for actionSlot = 1, 120 do
        local slotText = GetActionText(actionSlot);
        local slotTexture = GetActionTexture(actionSlot);
        if slotTexture then
            local slotReport = "Slot " .. actionSlot .. ": [" .. slotTexture .. "]";
            if slotText then
                slotReport = slotReport .. " \"" .. slotText .. "\"";
            end
            GV.Utils.Say(slotReport);
        end
    end
end

local function GetSpellRange()
    local isYard9 = CheckInteractDistance("target", 3);
    local isYard11 = CheckInteractDistance("target", 2);
    local isYard28 = CheckInteractDistance("target", 4);
    local actionSlot1 = IsActionInRange(25);
    local actionSlot2 = IsActionInRange(26);
    local actionSlot3 = IsActionInRange(27);    
    local report = ""

    if (isYard9) then report = "(9y) "
    elseif (isYard11) then report = "(11y) "
    elseif (isYard28) then report = "(28y) "
    else report = ""
    end

    if (actionSlot1 == 1) then report = report.."="
    elseif (actionSlot2 == 1) then report = report.."=="
    elseif (actionSlot3 == 1) then report = report.."==="
    else report = report..""
    end

    if (report == "") then report = "OOR" end
    
    return report
end

function Fns.PrintSpellRange()
    if (VazabTargetInfoDB.SpellRange == 1) then
        local finalTextSpellRange = ""

        if (not UnitIsFriend("player", "target")) then
            finalTextSpellRange = GetSpellRange()
        end
        
        TargetRangeText:SetText(finalTextSpellRange)
    else
        TargetRangeText:SetText("")
    end
end

-- ****************

function Fns.MovePlatePlayer(xPos, yPos)
    PlayerFrame:SetPoint("TOPLEFT", PlayerFrame:GetParent(), "TOPLEFT", xPos, yPos)
end

function Fns.MovePlateTarget(xPos, yPos)
    TargetFrame:SetPoint("TOPLEFT", PlayerFrame:GetParent(), "TOPLEFT", xPos, yPos)
end

function Fns.GetPlatePos()
    local point, relativeTo, relativePoint, xOfs, yOfs = PlayerFrame:GetPoint()
    GV.Utils.Say("PlayerPlate x"..xOfs.." y"..yOfs)
    point, relativeTo, relativePoint, xOfs, yOfs = TargetFrame:GetPoint()
    GV.Utils.Say("TargetPlate x"..xOfs.." y"..yOfs)
end