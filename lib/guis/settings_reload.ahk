MyReloadSettingsGui := Gui()
MyReloadSettingsGui.OnEvent("Close", (*) => ReEnableGui(MySettingsGui))
MyReloadSettingsGui.Opt("+AlwaysOnTop")
MyReloadSettingsGui.Title := SETTINGS_SCRIPT_TITLE
MyGuis.Push(MyReloadSettingsGui)

MyReloadSettingsGui.AddText("x100", "Direction: ")
ReloadAllWeapons_IterateAll__Direction_Left__Radio := MyReloadSettingsGui.AddRadio("x+10", " Left")
ReloadAllWeapons_IterateAll__Direction_Right__Radio := MyReloadSettingsGui.AddRadio("x+5", " Right")
if Settings_Map["RADIO_RELOAD_All_WEAPONS_ITERATE_DIRECTION"] == 2 {
    ReloadAllWeapons_IterateAll__Direction_Right__Radio.Value := 1
} else {
    ReloadAllWeapons_IterateAll__Direction_Left__Radio.Value := 1
}

ReloadAllWeapons_Text := MyReloadSettingsGui.AddText("x10 y+16", 'Number of iterations:')
ReloadAllWeapons_Edit := MyReloadSettingsGui.AddEdit("w40")
ReloadAllWeapons_Edit.OnEvent("Change", ReloadAllWeapons_Edit_Change)
ReloadAllWeapons_Edit.OnEvent("LoseFocus", ReloadAllWeapons_Edit_LoseFocus)
ReloadAllWeapons_UpDown := MyReloadSettingsGui.AddUpDown("Range1-10", Settings_Map["EDIT_RELOAD_All_WEAPONS"])
