# VBots Addon for VMaNGOS
Original by coolzoom, enhanced by HerrTaeubler

A comprehensive bot UI for VMaNGOS with party bot management, battleground automation, and template system.
VMaNGOS is a Progressive Vanilla Core aimed at all versions from 1.2 to 1.12
https://github.com/vmangos/core

![UI](https://github.com/HerrTaeubler/vmangos-pbotaddon/blob/master/botui.jpg)

## Installation
1. Download and rename folder to `vbots`
2. Copy folder to `World of Warcraft/Interface/Addons/`
   - Final path should be: `World of Warcraft/Interface/Addons/vbots`
3. Enable addon in the lower left corner of the login screen
4. Access via ESC menu or minimap icon

## Requirements
- GM Level 6 required for all commands
- VMaNGOS server with bot support

## Features

### Core Functions
- Basic bot controls (Clone, Remove, Die, Revive)
- Role selection (Tank, DPS, Heal)
- Class-specific bot creation
- Faction-specific class support (Paladin-Alliance/Shaman-Horde)

### Battleground System
- Complete BG queue and fill system for WSG, AB, AV
- Auto-fill functionality with level requirements
- Faction-balanced team creation
- Reserved spot for player in their faction

### Template System
For bot gear and spec templates:
1. Select your bot
2. Click the question mark to view available templates
3. Click the template number to apply the gear/spec set

### UI Features
- Organized button layout in logical columns
- Minimap button with tooltip
- ESC menu integration
- Template dropdown system
- Visual feedback for actions

## Technical Details
- Command queue system with delay protection
- Faction detection and validation
- Debug system for troubleshooting
- Event handling for proper initialization
- Memory optimized functions

# Note: Some debug messages will remain in the chat until it is confirmed that everything runs stably in the long term.

 ## Credits
Original addon by coolzoom
UI improvements and feature additions by HerrTaeubler
