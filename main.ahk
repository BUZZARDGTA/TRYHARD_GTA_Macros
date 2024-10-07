#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "lib\ahk_config.ahk"
#Include "lib\consts.ahk"
#Include "lib\globals.ahk"
#Include "lib\classes.ahk"
#Include "lib\funcs\utils.ahk"
#Include "lib\funcs\callbacks.ahk"
#Include "lib\funcs\core.ahk"

settings := LoadSettings()

#Include "lib\guis\main.ahk"
#Include "lib\guis\settings.ahk"

Hotkey(Hotkeys_Map["HotkeyBST"], (*) => RunMacro(DropBST, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeyReload"], (*) => RunMacro(ReloadAllWeapons, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeySpamRespawn"], (*) => RunMacro(SpamRespawn, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeyThermalVision"], (*) => RunMacro(ThermalVision, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeySuspendGame"], (*) => RunMacro(SuspendGame, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeyTerminateGame"], (*) => RunMacro(TerminateGame, "Hotkey"), "Off")

OpenMainGui()

CenterElement(MyMainGui, Speed_Text)
CenterElement(MyMainGui, Speed_Slider)
CenterElements(MyMainGui,, DropBST_Button, ReloadAllWeapons_Button, SpamRespawn_Button)
CenterElement(MyMainGui, ThermalVision_Button)
CenterElements(MyMainGui,, SuspendGame_Button, TerminateGame_Button)
CenterElements(MyMainGui, 0, ReloadAllWeapons_Edit, ReloadAllWeapons_UpDown)
CenterElements(MyMainGui, 20, Settings_Button, OpenRepo_Button, Updater_Button)

CenterElement(MyMainGui, ReloadAllWeapons_Text)
CenterElements(MyMainGui, 20, Settings_Button, OpenRepo_Button, Updater_Button)
CenterElements(MyMainGui,, KeyBindings_Button, Hotkeys_Button)
CenterElements(MyMainGui, 40, LoadSettings_Button, SaveSettings_Button)

; Fixes a visual Glitch issue, using `Hidden` and then `.Visible` works too, but this is cleaner imo.
DropBST_Button.Enabled := true
ReloadAllWeapons_Button.Enabled := true
SpamRespawn_Button.Enabled := true
ThermalVision_Button.Enabled := true
SuspendGame_Button.Enabled := true
TerminateGame_Button.Enabled := true
Settings_Button.Enabled := true
OpenRepo_Button.Enabled := true
Updater_Button.Enabled := true

OnMessage(0x0200, On_WM_MOUSEMOVE)

A_TrayMenu.Insert("1&", "Hide", (*) => MyMainGui.Hide())
A_TrayMenu.Insert("2&")

RunUpdater("STARTUP")

SetTimer(MainLoop, 100)
