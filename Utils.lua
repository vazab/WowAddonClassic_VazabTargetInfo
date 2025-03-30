local GV = _GV or getfenv(0)
local Utils = GV.Utils or {}
_GV.Utils = Utils

function Utils.Say(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00cc66VazabTargetInfo|r: "..msg)
end

function Utils.SayD(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00cc66VazabTargetInfo|r: ".."|cffFDE047"..msg)
end