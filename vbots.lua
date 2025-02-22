-- Create Date : 2020/5/12 10:00:00

-- Constants moved to top and grouped logically
local ADDON_NAME = "vbots"

-- Command constants
-- PartyBot commands
CMD_PARTYBOT_CLONE = ".partybot clone"
CMD_PARTYBOT_REMOVE = ".partybot remove"
CMD_PARTYBOT_ADD = ".partybot add "
CMD_PARTYBOT_SETROLE = ".partybot setrole "
CMD_PARTYBOT_GEAR = ".character premade gear "
CMD_PARTYBOT_SPEC = ".character premade spec "

-- BattleBot commands
CMD_BATTLEGROUND_GO = ".go "
CMD_BATTLEBOT_ADD = ".battlebot add "

-- BG sizes and level requirements
local BG_INFO = {
    warsong = {
        size = 10,
        minLevel = 10,
        maxLevel = 60
    },
    arathi = {
        size = 15,
        minLevel = 20,
        maxLevel = 60
    },
    alterac = {
        size = 40,
        minLevel = 51,
        maxLevel = 60
    }
}

-- Command queue system
local CommandQueue = {
    commands = {},
    timer = 0,
    processing = false
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

-- Change this line near the top
local playerFaction = nil  -- Initialize as nil

-- Add this function to safely get faction
local function GetPlayerFaction()
    if not playerFaction then
        local faction = UnitFactionGroup("player")
        if faction then
            playerFaction = string.lower(faction)
        end
    end
    return playerFaction or "alliance"  -- Default to alliance if faction not yet available
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

-- BattleGround function (kept for queue buttons)
function SubBattleGo(self, arg)
    SendChatMessage(CMD_BATTLEGROUND_GO .. arg)
end

-- Utility functions
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

-- Faction handling for add sham/pal
local function InitializeFactionClassButton()
    local button = getglobal("PartyBotAddFactionClass")
    if button then
        local faction = string.lower(UnitFactionGroup("player"))
        if faction == "alliance" then
            button:SetText("Add Paladin")
        else
            button:SetText("Add Shaman")
        end
        Debug("Set faction button text for: " .. faction)
    else
        Debug("Could not find faction button!")
    end
end

-- Then register events and set up event handler
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function()
    local event = event
    local message = arg1

    -- Handle chat messages for templates
    if event == "CHAT_MSG_SYSTEM" and message then
        Debug("Got message: " .. tostring(message))
        
        -- Try to match the exact format we see
        if string.find(message, "^%d+%s*-%s*") then
            Debug("Found a line starting with number!")
            local _, _, id, name = string.find(message, "^(%d+)%s*-%s*([^%(]+)")
            if id and name then
                Debug("Found template -> ID: " .. id .. ", Name: " .. name)
                templates[id] = name
                local dropdown = getglobal("vbotsTemplateDropDown")
                if dropdown then
                    UIDropDownMenu_Initialize(dropdown, TemplateDropDown_Initialize)
                end
            end
        end
        
        if string.find(message, "Listing available premade templates") then
            Debug("=== Found header ===")
            templates = {}
        end
    end

    -- Handle faction button initialization
    if event == "PLAYER_ENTERING_WORLD" then
        local faction = UnitFactionGroup("player")
        if faction then
            playerFaction = string.lower(faction)
            InitializeFactionClassButton()
            Debug("Initialized faction buttons for: " .. playerFaction)
        end
    end
end)

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
        local dropdownText = getglobal("vbotsTemplateDropDown".."Text")
        if dropdownText then
            dropdownText:SetText(id .. " - " .. name)
        end
    end
end

Debug("Test addon ready")

-- Function to add a bot command to queue
local function QueueCommand(command)
    table.insert(CommandQueue.commands, command)
    if not CommandQueue.processing then
        CommandQueue.processing = true
        CommandQueue.timer = 0
        CommandQueue.frame:Show()
    end
end

-- Create the command processing frame
CommandQueue.frame = CreateFrame("Frame")
CommandQueue.frame:Hide()
CommandQueue.frame:SetScript("OnUpdate", function()
    if table.getn(CommandQueue.commands) == 0 then
        CommandQueue.processing = false
        CommandQueue.frame:Hide()
        return
    end

    CommandQueue.timer = CommandQueue.timer + arg1
    if CommandQueue.timer >= 0.5 then -- Half second delay between commands
        local command = table.remove(CommandQueue.commands, 1)
        SendChatMessage(command)
        CommandQueue.timer = 0
        
        if table.getn(CommandQueue.commands) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("All bots have been added!")
        end
    end
end)

-- Function to fill a battleground
function SubBattleFill(self, bgType)
    Debug("Starting battleground fill for: " .. bgType)
    local playerFaction = string.lower(UnitFactionGroup("player"))
    local playerLevel = UnitLevel("player")
    local bgData = BG_INFO[bgType]
    
    if not bgData then
        DEFAULT_CHAT_FRAME:AddMessage("Invalid battleground type: " .. bgType)
        return
    end
    
    -- Check level requirements
    if playerLevel < bgData.minLevel then
        DEFAULT_CHAT_FRAME:AddMessage("You must be at least level " .. bgData.minLevel .. " to queue for " .. bgType)
        return
    end
    
    -- Clear any existing queue
    CommandQueue.commands = {}
    CommandQueue.timer = 0
    
    -- Add Alliance bots
    local allianceCount = bgData.size
    if playerFaction == "alliance" then
        allianceCount = bgData.size - 1 -- Leave one spot for the player
    end
    for i = 1, allianceCount do
        QueueCommand(CMD_BATTLEBOT_ADD .. bgType .. " alliance " .. playerLevel)
    end
    
    -- Add Horde bots
    local hordeCount = bgData.size
    if playerFaction == "horde" then
        hordeCount = bgData.size - 1 -- Leave one spot for the player
    end
    for i = 1, hordeCount do
        QueueCommand(CMD_BATTLEBOT_ADD .. bgType .. " horde " .. playerLevel)
    end
    
    -- Queue the battleground at the end
    QueueCommand(CMD_BATTLEGROUND_GO .. bgType)
    
    -- Show feedback message
    local totalBots = allianceCount + hordeCount
    DEFAULT_CHAT_FRAME:AddMessage("Queueing " .. totalBots .. " level " .. playerLevel .. " bots for " .. bgType .. " (leaving space for you in " .. playerFaction .. " team)")
end 
