MySettingsGui := Gui()
MySettingsGui.OnEvent("Close", (*) => ReEnableGui(MyMainGui))
MySettingsGui.Opt("+AlwaysOnTop")
MySettingsGui.Title := SETTINGS_SCRIPT_TITLE

#Include "settings_reload.ahk"

ReloadAllWeapons_Iterate_All__Radio := MySettingsGui.AddRadio("x50 y10 Checked", " Reload All Weapons (Method: Iterate)")
ReloadAllWeapons_Iterate_All__Radio.OnEvent("Click", (*) => ReloadAllWeapons_Radio1_Click())
ReloadAllWeapons_Heavy_Weapon__Radio := MySettingsGui.AddRadio("x50", " Reload All Weapons (Method: Heavy Weapon)")
ReloadAllWeapons_Heavy_Weapon__Radio.OnEvent("Click", (*) => ReloadAllWeapons_Radio2_Click())

MySettingsGui.SetFont("s10")
ReloadSettings_Button := MySettingsGui.AddButton("x254 y6 w21 h21", "⚙")
ReloadSettings_Button.OnEvent("Click", (*) => OpenReloadSettingsGui())
MySettingsGui.SetFont()

AddSeparator(MySettingsGui, {text1: "x10"})

#Include "settings_keybinds.ahk"

KeyBindings_Button := MySettingsGui.AddButton(, "Key-Bindings")
KeyBindings_Button.OnEvent("Click", (*) => OpenKeybindSettingsGui())

#Include "settings_hotkeys.ahk"

Hotkeys_Button := MySettingsGui.AddButton("x+0", "Hotkeys")
Hotkeys_Button.OnEvent("Click", (*) => OpenHotkeySettingsGui())

AddSeparator(MySettingsGui, {text1: "x10"})

LoadSettings_Button := MySettingsGui.AddButton(, "Load Settings")
LoadSettings_Button.OnEvent("Click", (*) => LoadSettings())
SaveSettings_Button := MySettingsGui.AddButton("x+0", "Save Settings")
SaveSettings_Button.OnEvent("Click", (*) => SaveSettings())
ResetSettings_Button := MySettingsGui.AddButton("x+0", "Reset Settings")
ResetSettings_Button.OnEvent("Click", (*) => ResetSettings())
