-- Global table which contains global vars, funcs, tables
local GV = _GV or getfenv(0)
GV = GV or {}

_GV = GV