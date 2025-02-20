-- Create Date : 2020/5/12 10:00:00

-- Constants moved to top and grouped logically
local ADDON_NAME = "vbots"


-- Battleground constants
local BG = {
    ARATHI = "arathi",
    ALTERAC = "alterac",
    WARSONG = "warsong"
}

-- Team constants
local TEAM = {
    HORDE = "horde",
    ALLIANCE = "alliance"
}

-- Role constants
local ROLE = {
    HEALER = "healer",
    DPS = "dps",
    TANK = "tank"
}

-- Class constants
local CLASS = {
    WARRIOR = "warrior",   -- 战士
    PALADIN = "paladin",   -- 圣骑士
    HUNTER = "hunter",     -- 猎人
    ROGUE = "rogue",      -- 潜行者
    PRIEST = "priest",     -- 牧师
    SHAMAN = "shaman",    -- 萨满
    MAGE = "mage",        -- 法师
    WARLOCK = "warlock",   -- 术士
    DRUID = "druid"       -- 德鲁伊
}

-- Command constants
local CMD = {
    PARTYBOT = {
        CLONE = ".partybot clone",
        REMOVE = ".partybot remove",
        ADD = ".partybot add ",
        SETROLE = ".partybot setrole "
    },
    BATTLEBOT = {
        ADD = ".battlebot add ",
        GO = ".go "
    },
    CHARACTER = {
        GEAR = ".character premade gear ",
        SPEC = ".character premade spec "
    }
}

-- Local variables for minimap button
local MinimapButton = {
    shown = true,
    position = 268,
    radius = 78,  -- Distance from minimap center
    -- Cached math functions for better performance
    cos = math.cos,
    sin = math.sin,
    deg = math.deg,
    atan2 = math.atan2
}

-- Utility functions
local function SendCommand(command, ...)
    local fullCommand = command .. table.concat({...}, " ")
    SendChatMessage(fullCommand)
end

-- Minimap button position calculation optimization
function MinimapButton:UpdatePosition()
    local radian = self.position * (math.pi/180)
    vbotsButtonFrame:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        54 - (self.radius * self.cos(radian)),
        (self.radius * self.sin(radian)) - 55
    )
    self:Init()
end

function MinimapButton:CalculatePosition(xpos, ypos)
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    xpos = xmin - xpos/UIParent:GetScale() + 70
    ypos = ypos/UIParent:GetScale() - ymin - 70
    
    local angle = self.deg(self.atan2(ypos, xpos))
    if angle < 0 then
        angle = angle + 360
    end
    
    self.position = angle
    self:UpdatePosition()
end

function MinimapButton:Init()
    if self.shown then
        vbotsFrame:Show()
    else
        vbotsFrame:Hide()
    end
end

function MinimapButton:Toggle()
    self.shown = not self.shown
    self:Init()
end

-- PartyBot functions
local PartyBot = {
    function Clone(self)
        SendCommand(CMD.PARTYBOT.CLONE)
    end,
    
    function Remove(self)
        SendCommand(CMD.PARTYBOT.REMOVE)
    end,
    
    function SetRole(self, role)
        SendCommand(CMD.PARTYBOT.SETROLE, role)
    end,
    
    function Add(self, class)
        SendCommand(CMD.PARTYBOT.ADD, class)
        DEFAULT_CHAT_FRAME:AddMessage("Bot added. Please search available gear and spec set.")
    end
}

-- Frame management functions
local function CloseFrame()
    vbotsFrame:Hide()
    MinimapButton.shown = false
end

local function OpenFrame()
    DEFAULT_CHAT_FRAME:AddMessage("Loading " .. ADDON_NAME .. " v" .. ADDON_VERSION)
    DEFAULT_CHAT_FRAME:RegisterEvent('CHAT_MSG_SYSTEM')
    vbotsFrame:Show()
    MinimapButton.shown = true
end

-- Hook up the global functions needed by XML
_G.SubPartyBotClone = function(self) PartyBot:Clone() end
_G.SubPartyBotRemove = function(self) PartyBot:Remove() end
_G.SubPartyBotSetRole = function(self, role) PartyBot:SetRole(role) end
_G.SubPartyBotAdd = function(self, class) PartyBot:Add(class) end
_G.CloseFrame = CloseFrame
_G.OpenFrame = OpenFrame

_G.vbotsButtonFrame_Init = function() MinimapButton:Init() end
_G.vbotsButtonFrame_Toggle = function() MinimapButton:Toggle() end
_G.vbotsButtonFrame_UpdatePosition = function() MinimapButton:UpdatePosition() end
_G.vbotsButtonFrame_BeingDragged = function()
    local x, y = GetCursorPosition()
    MinimapButton:CalculatePosition(x, y)
end

-- cmd
CMD_PARTYBOT_CLONE = ".partybot clone";
CMD_PARTYBOT_REMOVE = ".partybot remove";
CMD_PARTYBOT_ADD = ".partybot add ";
CMD_PARTYBOT_SETROLE = ".partybot setrole ";
CMD_BATTLEGROUND_GO = ".go ";
CMD_BATTLEBOT_ADD = ".battlebot add ";

CMD_PARTYBOT_GEAR = ".character premade gear ";
CMD_PARTYBOT_SPEC = ".character premade spec ";

-- command frame
function SubPartyBotClone(self)
	SendChatMessage(CMD_PARTYBOT_CLONE);
end

function SubPartyBotRemove(self)
	SendChatMessage(CMD_PARTYBOT_REMOVE);
end

function SubPartyBotSetRole(self, arg)
	SendChatMessage(CMD_PARTYBOT_SETROLE .. arg);
end

function SubPartyBotAdd(self, arg)
	SendChatMessage(CMD_PARTYBOT_ADD .. arg);
	DEFAULT_CHAT_FRAME:AddMessage("bot added. please search available gear and spec set.");
	-- SendChatMessage(CMD_PARTYBOT_GEAR);
	-- SendChatMessage(CMD_PARTYBOT_SPEC);
end

function SubBattleBotAdd(self, arg1, arg2)
	SendChatMessage(CMD_BATTLEBOT_ADD .. arg1 .. " " .. arg2);
end

function SubBattleGo(self, arg)
	SendChatMessage(CMD_BATTLEGROUND_GO .. arg);
end

function CloseFrame()
	vbotsFrame:Hide();
end

function OpenFrame()

	DEFAULT_CHAT_FRAME:AddMessage("Loading vmangos bot ui...");
	DEFAULT_CHAT_FRAME:RegisterEvent('CHAT_MSG_SYSTEM')
	vbotsFrame:Show();
end

function SubSendGuildMessage(self, arg)
	SendChatMessage(arg, "GUILD", "Common" , 1);
end

-- minimap button
local vbotsFrameShown = true -- show frame by default
local vbotsButtonPosition = 268

function vbotsButtonFrame_OnClick()
	vbotsButtonFrame_Toggle();
end

function vbotsButtonFrame_Init()
    -- show frame by default
	if(vbotsFrameShown) then
		vbotsFrame:Show();
	else
		vbotsFrame:Hide();
	end
end

function vbotsButtonFrame_Toggle()
	if(vbotsFrame:IsVisible()) then
		vbotsFrame:Hide();
		vbotsFrameShown = false;
	else
		vbotsFrame:Show();
		vbotsFrameShown = true;
	end
	vbotsButtonFrame_Init();
end

function vbotsButtonFrame_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:SetText("vmangos bot command, \n click to open/close, \n right mouse to drag me");
    GameTooltip:Show();
end

function vbotsButtonFrame_UpdatePosition()
	vbotsButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		54 - (78 * cos(vbotsButtonPosition)),
		(78 * sin(vbotsButtonPosition)) - 55
	);
	vbotsButtonFrame_Init();
end

-- Thanks to Yatlas for this code
function vbotsButtonFrame_BeingDragged()
    -- Thanks to Gello for this code
    local xpos,ypos = GetCursorPosition() 
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom() 

    xpos = xmin-xpos/UIParent:GetScale()+70 
    ypos = ypos/UIParent:GetScale()-ymin-70 

    vbotsButtonFrame_SetPosition(math.deg(math.atan2(ypos,xpos)));
end

function vbotsButtonFrame_SetPosition(v)
    if(v < 0) then
        v = v + 360;
    end

    vbotsButtonPosition = v;
    vbotsButtonFrame_UpdatePosition();
end

-- PREMADE GEAR
function SubPreMadeGearSearch(self)
	SendChatMessage(CMD_PARTYBOT_GEAR);
end
function SubPreMadeGearSet(self, arg)
	SendChatMessage(CMD_PARTYBOT_GEAR .. arg);
end

-- PREMADE SPEC
function SubPreMadeSPECSearch(self)
	SendChatMessage(CMD_PARTYBOT_SPEC);
end
function SubPreMadeSPECSet(self, arg)
	SendChatMessage(CMD_PARTYBOT_SPEC .. arg);
end
