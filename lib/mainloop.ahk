FlashWindow(hwnd) {
    WinActivate(hwnd)

    loop 15 {
        ; Known-Bug: It has 1/2 chances that it does not effectively stop flashing
        ; when clicking on the title bar GUI, due to HWND different on flashing.
        MouseGetPos(,, &OutputVarWin)

        if GetKeyState("LButton", "P") {
            if hwnd == OutputVarWin {
                return
            }
        }

        DllCall("User32\FlashWindow", "Ptr", hwnd, "Int", True)
        Sleep(50)
    }
}


PrevHwnd := 0
clicked := false


while true {
    ; START UpdateTrayMenuShowHideOptionState
    if WinExist(SCRIPT_WINDOW_IDENTIFIER) {
        ItemName := "Hide"
        ActionFunc := (*) => MyMainGui.Hide()
        RenameFrom := "Show"
    } else {
        ItemName := "Show"
        ActionFunc := (*) => MyMainGui.Show()
        RenameFrom := "Hide"
    }

    try {
        A_TrayMenu.Rename(RenameFrom, ItemName)
    } catch error as err {
        if not (err.What == "Menu.Prototype.Rename" and err.Message == "Nonexistent menu item.") {
            throw err
        }
    } else {
        A_TrayMenu.Add(ItemName, ActionFunc)
    } finally {
        A_TrayMenu.Default := ItemName
    }
    ; END UpdateTrayMenuShowHideOptionState

    ; START Settings
    if ReloadAllWeapons_HeavyWeapon__Radio.Value == 1 {
        Settings_Map["RADIO_RELOAD_All_WEAPONS_METHOD"] := 2
    } else {
        Settings_Map["RADIO_RELOAD_All_WEAPONS_METHOD"] := 1
    }

    if ReloadAllWeapons_IterateAll__Direction_Right__Radio.Value == 1 {
        Settings_Map["RADIO_RELOAD_All_WEAPONS_ITERATE_DIRECTION"] := 2
    } else {
        Settings_Map["RADIO_RELOAD_All_WEAPONS_ITERATE_DIRECTION"] := 1
    }
    ; END Settings

    ; START IsGTARunning_Callback
    /*
    HotIfWinActive(GTA_WINDOW_IDENTIFIER)
    Known-Bug: After restarting the game this method ain't working anymore.
    So I fixed it by implementing my own one in the MainLoop just bellow.
    */
    ; Only enable Hotkeys when the GTA_WINDOW_IDENTIFIER conditions are found.
    global gtaWindowID

    gtaWindowID := GetValidGTAwinRunning()

    for HotkeyName, Data in GetHotkeysObjects_Map() {
        ToggleButton := Data.ToggleButton
        _Hotkey := Data.Hotkey

        if (ToggleButton.Text == "Disable") {
            try {
                Hotkey(_Hotkey, (gtaWindowID and WinActive(gtaWindowID)) ? "On" : "Off")
            } catch error as err {
                if not ((err.What == "Hotkey") and (err.Message == "Nonexistent hotkey.")) {
                    throw err
                }
            }
        }
    }
    ; END IsGTARunning_Callback

    ; START mainGUI
    MouseGetPos(,, &OutputVarWin, &OutputVarControl, 2)

    if (IsAnyTooltipDisplaying and not InArray(OutputVarControl, TooltipElementHwnds)) {
        HideTooltip()
    }

    PrevHwnd := OutputVarControl
    ; END mainGUI

    ; START GUI FlashWindow
    if GetKeyState("LButton", "P") {
        if not clicked and not WinActive(OutputVarWin) {
            ShouldFlash := false
            WindowToFlash := 0

            for ThisGui in MyGuis {
                if ShouldFlash {
                    Style := WinGetStyle(ThisGui.Hwnd)
                    if (Style & WindowStyles.Visible) {
                        WindowToFlash := ThisGui.Hwnd
                    }
                } else {
                    if (OutputVarWin == ThisGui.Hwnd and WinExist(ThisGui.Hwnd)) {
                        ShouldFlash := true
                    }
                }
            }

            if (ShouldFlash and WindowToFlash) {
                if OutputVarWin != WindowToFlash {
                    clicked := true
                    FlashWindow(WindowToFlash)
                }
            }
        }
    } else {
        clicked := false
    }
    ; END GUI FlashWindow
}