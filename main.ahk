#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "lib\ahk_config.ahk"
#Include "lib\consts.ahk"
#Include "lib\globals.ahk"
#Include "lib\classes.ahk"
#Include "lib\funcs\utils.ahk"
#Include "lib\funcs\callbacks.ahk"
#Include "lib\funcs\core.ahk"

LoadSettings({ IsScriptStartup: true })

#Include "lib\guis\main.ahk"
#Include "lib\guis\settings.ahk"

Hotkey(Settings_Map["HOTKEY_BST"], (*) => RunMacro(DropBST, "Hotkey"), "Off")
Hotkey(Settings_Map["HOTKEY_RELOAD"], (*) => RunMacro(ReloadAllWeapons, "Hotkey"), "Off")
Hotkey(Settings_Map["HOTKEY_SPAMRESPAWN"], (*) => RunMacro(SpamRespawn, "Hotkey"), "Off")
Hotkey(Settings_Map["HOTKEY_THERMALVISION"], (*) => RunMacro(ThermalVision, "Hotkey"), "Off")
Hotkey(Settings_Map["HOTKEY_SUSPENDGAME"], (*) => RunMacro(SuspendGame, "Hotkey"), "Off")
Hotkey(Settings_Map["HOTKEY_TERMINATEGAME"], (*) => RunMacro(TerminateGame, "Hotkey"), "Off")

OpenMainGui()

CenterElement(MyMainGui, KeyRelease_Text)
CenterElement(MyMainGui, KeyRelease_Slider)
CenterElement(MyMainGui, KeyHold_Text)
CenterElement(MyMainGui, KeyHold_Slider)
CenterElements(MyMainGui,, SuspendGame_Button, TerminateGame_Button)
CenterElements(MyMainGui, 0, ReloadAllWeapons_Edit, ReloadAllWeapons_UpDown)
CenterElements(MyMainGui, 20, Settings_Button, OpenRepo_Button, Updater_Button)

CenterElement(MyMainGui, ReloadAllWeapons_Text)
CenterElements(MyMainGui, 20, Settings_Button, OpenRepo_Button, Updater_Button)
CenterElements(MyMainGui,, KeyBindings_Button, Hotkeys_Button)
CenterElements(MyMainGui, 30, LoadSettings_Button, SaveSettings_Button, ResetSettings_Button)

; Fixes a visual Glitch issue, using `Hidden` and then `.Visible` works too, but this is cleaner imo.
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
