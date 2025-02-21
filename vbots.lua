-- Create Date : 2020/5/12 10:00:00

-- Constants moved to top and grouped logically
local ADDON_NAME = "vbots"

-- Command constants (keep the global ones since they're used in existing code)
CMD_PARTYBOT_CLONE = ".partybot clone"
CMD_PARTYBOT_REMOVE = ".partybot remove"
CMD_PARTYBOT_ADD = ".partybot add "
CMD_PARTYBOT_SETROLE = ".partybot setrole "
CMD_BATTLEGROUND_GO = ".go "
CMD_BATTLEBOT_ADD = ".battlebot add "
CMD_PARTYBOT_GEAR = ".character premade gear "
CMD_PARTYBOT_SPEC = ".character premade spec "

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

function SubPartyBotClone(self)
    SendChatMessage(CMD_PARTYBOT_CLONE)
end

function SubPartyBotRemove(self)
    SendChatMessage(CMD_PARTYBOT_REMOVE)
end

function SubPartyBotSetRole(self, arg)
    SendChatMessage(CMD_PARTYBOT_SETROLE .. arg)
end

function SubPartyBotAdd(self, arg)
    SendChatMessage(CMD_PARTYBOT_ADD .. arg)
    DEFAULT_CHAT_FRAME:AddMessage("bot added. please search available gear and spec set.")
end

function SubBattleBotAdd(self, arg1, arg2)
    SendChatMessage(CMD_BATTLEBOT_ADD .. arg1 .. " " .. arg2)
end

function SubBattleGo(self, arg)
    SendChatMessage(CMD_BATTLEGROUND_GO .. arg)
end

function SubSendGuildMessage(self, arg)
    SendChatMessage(arg, "GUILD", "Common", 1)
end

function CloseFrame()
    vbotsFrame:Hide()
    MinimapButton.shown = false
end

function OpenFrame()
    DEFAULT_CHAT_FRAME:AddMessage("Loading " .. ADDON_NAME)
    DEFAULT_CHAT_FRAME:RegisterEvent('CHAT_MSG_SYSTEM')
    vbotsFrame:Show()
    MinimapButton.shown = true
end

-- Minimap button functions
function vbotsButtonFrame_OnClick()
    vbotsButtonFrame_Toggle()
end

function vbotsButtonFrame_Init()
    MinimapButton:Init()
end

function vbotsButtonFrame_Toggle()
    MinimapButton:Toggle()
end

function vbotsButtonFrame_UpdatePosition()
    MinimapButton:UpdatePosition()
end

function vbotsButtonFrame_BeingDragged()
    local x, y = GetCursorPosition()
    MinimapButton:CalculatePosition(x, y)
end

function vbotsButtonFrame_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("vmangos bot command, \n click to open/close, \n right mouse to drag me")
    GameTooltip:Show()
end

-- Store templates
local templates = {}

-- Simple debug function
local function Debug(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00ChatTest:|r " .. msg)
end

-- Dropdown menu initializer
function TemplateDropDown_Initialize()
    local info = {}
    -- Add header
    info.text = "Select Template"
    info.notClickable = 1
    info.isTitle = 1
    UIDropDownMenu_AddButton(info)

    -- Add all stored templates
    for id, name in pairs(templates) do
        info = {}
        info.text = id .. " - " .. name
        info.func = TemplateDropDown_OnClick
        info.value = id
        UIDropDownMenu_AddButton(info)
    end
end

-- Dropdown click handler
function TemplateDropDown_OnClick()
    local id = this.value
    local name = templates[id]
    if id and name then
        SendChatMessage(".character premade gear " .. id)
        getglobal("vbotsTemplateDropDownText"):SetText(id .. " - " .. name)
    end
end

-- Create frame and register for chat messages
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")

-- Event handler
f:SetScript("OnEvent", function()
    local message = arg1
    Debug("Got message: " .. tostring(message))
    
    -- Try to match the exact format we see
    if string.find(message, "^%d+%s*-%s*") then
        Debug("Found a line starting with number!")
        local _, _, id, name = string.find(message, "^(%d+)%s*-%s*([^%(]+)")
        if id and name then
            Debug("Found template -> ID: " .. id .. ", Name: " .. name)
            -- Store the template
            templates[id] = name
            -- Update dropdown
            UIDropDownMenu_Initialize(getglobal("vbotsTemplateDropDown"), TemplateDropDown_Initialize)
        end
    end
    
    -- Also look for the header
    if string.find(message, "Listing available premade templates") then
        Debug("=== Found header ===")
        -- Clear old templates when getting new list
        templates = {}
    end
end)

Debug("Test addon ready") 
