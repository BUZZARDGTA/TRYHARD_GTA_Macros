MyReloadSettingsGui := Gui()
MyReloadSettingsGui.OnEvent("Close", (*) => ReEnableGui(MySettingsGui))
MyReloadSettingsGui.Opt("+AlwaysOnTop")
MyReloadSettingsGui.Title := SETTINGS_SCRIPT_TITLE


MyReloadSettingsGui.AddText("x100", "Direction: ")
ReloadAllWeapons_Iterate_All__Direction__Radio__Left := MyReloadSettingsGui.AddRadio("x+10 Checked", " Left")
ReloadAllWeapons_Iterate_All__Direction__Radio__Right := MyReloadSettingsGui.AddRadio("x+5", " Right")

ReloadAllWeapons_Text := MyReloadSettingsGui.AddText("x10 y+16", 'Number of iterations:')
ReloadAllWeapons_Edit := MyReloadSettingsGui.AddEdit("w40")
ReloadAllWeapons_Edit.OnEvent("Change", ReloadAllWeapons_Edit_Change)
ReloadAllWeapons_Edit.OnEvent("LoseFocus", ReloadAllWeapons_Edit_LoseFocus)
ReloadAllWeapons_UpDown := MyReloadSettingsGui.AddUpDown("Range1-10", DEFAULT_EDIT_RELOAD_All_WEAPONS)
