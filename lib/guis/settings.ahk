MySettingsGui := Gui()
MySettingsGui.OnEvent("Close", (*) => ReEnableGui(MyMainGui))
MySettingsGui.Opt("+AlwaysOnTop")
MySettingsGui.Title := SETTINGS_SCRIPT_TITLE

#Include "settings_reload.ahk"

ReloadAllWeapons_IterateAll__Radio := MySettingsGui.AddRadio("x50 y10", " Reload All Weapons (Method: Iterate)")
ReloadAllWeapons_IterateAll__Radio.OnEvent("Click", (*) => ReloadAllWeapons_HeavyWeapon__Click())
ReloadAllWeapons_HeavyWeapon__Radio := MySettingsGui.AddRadio("x50", " Reload All Weapons (Method: Heavy Weapon)")
ReloadAllWeapons_HeavyWeapon__Radio.OnEvent("Click", (*) => ReloadAllWeapons_IterateAll__Click())

MySettingsGui.SetFont("s10")
ReloadSettings_Button := MySettingsGui.AddButton("Disabled x254 y6 w21 h21", "⚙")
ReloadSettings_Button.OnEvent("Click", (*) => OpenReloadSettingsGui())
MySettingsGui.SetFont()

if Settings_Map["RADIO_RELOAD_All_WEAPONS_METHOD"] == 2 {
    ReloadAllWeapons_HeavyWeapon__Radio.Value := 1
} else {
    ReloadAllWeapons_IterateAll__Radio.Value := 1
    ReloadSettings_Button.Enabled := true
}

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
