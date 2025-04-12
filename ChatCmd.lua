local GV = _GV or getfenv(0)
local ChatCmd = GV.ChatCmd or {}
_GV.ChatCmd = ChatCmd

-- ****************
-- Functions for chat
-- ****************

local function HandleSlashCommand(cmd)
    if (cmd == nil or cmd == "") then -- Commands list
        GV.Utils.Say("\nzab show | zab hide | zab reset\nzab scale 1 | zab alpha 0.5 | zab bg 1\nzab pos | zab pos 0 0\nzab range 0\nzab ppos 529 -500 | zab tpos 756 -500 | zab ptpos")
        return
    end
    
    cmd = string.lower(cmd)

    local args = {}
    local pos = 1
    while true do
        local nextSpace = string.find(cmd, "%s", pos)
        if (not nextSpace) then
            table.insert(args, string.sub(cmd, pos))
            break
        end
        table.insert(args, string.sub(cmd, pos, nextSpace - 1))
        pos = nextSpace + 1
    end

    if args[1] == "hide" then
        VazabTargetInfoDB.MainFrameShow = 0
        GV.Fns.RefreshMainFrame()
        GV.Utils.Say("panel hidden.")
    elseif args[1] == "show" then
        VazabTargetInfoDB.MainFrameShow = 1
        GV.Fns.RefreshMainFrame()
        GV.Utils.Say("panel shown.")
    elseif args[1] == "reset" then
        GV.Fns.ResetMainFrame()
        GV.Utils.Say("settings have been reset")
    elseif args[1] == "scale" then
        local arg2 = tonumber(args[2])
        if (not arg2) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end
        VazabTargetInfoDB.MainFrameScale = arg2
        GV.Fns.RefreshMainFrame()
        GV.Utils.Say("Set frame scale to "..arg2)
    elseif args[1] == "alpha" then
        local arg2 = tonumber(args[2])
        if (not arg2) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end
        VazabTargetInfoDB.MainFrameAlpha = arg2
        GV.Fns.RefreshMainFrame()
        GV.Utils.Say("Set frame alpha to "..arg2)
    elseif args[1] == "pos" then
        local arg2 = tonumber(args[2])
        local arg3 = tonumber(args[3])
        if (not arg2) then
            local point, relativeTo, relativePoint, xOfs, yOfs = MainFrame:GetPoint()
            GV.Utils.Say("x"..xOfs.." y"..yOfs)
            GV.Fns.GetPlatePos()
            return
        end
        if (not arg3) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end
        VazabTargetInfoDB.MainFramePosX = arg2
        VazabTargetInfoDB.MainFramePosY = arg3
        GV.Fns.RefreshMainFrame()
        GV.Utils.Say("New pos x"..arg2.." y"..arg3)
    elseif args[1] == "range" then
        local arg2 = tonumber(args[2])
        if (not arg2) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end
        
        if (arg2 == 1) then
            VazabTargetInfoDB.SpellRange = 1
            GV.Utils.Say("Range on")
        else
            VazabTargetInfoDB.SpellRange = 0
            GV.Utils.Say("Range off")
        end
    elseif args[1] == "bg" then
        local arg2 = tonumber(args[2])
        if (not arg2) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end

        if (arg2 == 0) then
            VazabTargetInfoDB.MainFrameBackdrop = 0
            GV.Utils.Say("BG off")
        else
            VazabTargetInfoDB.MainFrameBackdrop = 1
            GV.Utils.Say("BG on")
        end
        GV.Fns.RefreshMainFrame()
    elseif args[1] == "ppos" then
        local arg2 = tonumber(args[2])
        local arg3 = tonumber(args[3])

        if (not arg2) or (not arg3) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end

        GV.Fns.MovePlatePlayer(arg2, arg3)
    elseif args[1] == "tpos" then
        local arg2 = tonumber(args[2])
        local arg3 = tonumber(args[3])

        if (not arg2) or (not arg3) then
            GV.Utils.Say("Inappropriate command syntax")
            return
        end

        GV.Fns.MovePlateTarget(arg2, arg3)
    elseif args[1] == "ptpos" then
        GV.Fns.MovePlatePlayer(465, -500)
        GV.Fns.MovePlateTarget(820, -500)
    elseif args[1] == "test" then
        GV.Utils.SayD("TestStart")
        GV.Utils.SayD("TestEnd")
    end
end

function ChatCmd.InitSlashCommand()
    SLASH_RELOADUI1 = "/rl"
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_VazabTargetInfo1 = "/zab"
    SlashCmdList.VazabTargetInfo = HandleSlashCommand
    GV.Utils.Say("/zab")
end