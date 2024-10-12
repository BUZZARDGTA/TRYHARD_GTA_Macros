/*
    callbacks.ahk
    These functions are callbacks and must be called without parameters, as AHK v2 provides the necessary arguments.
*/

On_WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    static PrevHwnd := 0

    if !hwnd == PrevHwnd {
        HideTooltip()

        CurrControl := GuiCtrlFromHwnd(hwnd)
        if CurrControl {
            if not CurrControl.HasProp("ToolTip") {
                return
            }

            Text := CurrControl.ToolTip
            SetTimer(() => ShowTooltip(Text), -TOOLTIP_DISPLAY_TIME)
            SetTimer(() => HideTooltip(), -TOOLTIP_HIDE_TIME)
        }

        PrevHwnd := hwnd
    }
}

Link_Click(Ctrl, ID, HREF) {
    Run(HREF)
}

UpdateKeyHoldMacroSpeed(GuiCtrlObj, Info) {
    global HasDisplayedKeyHoldMacroSpeedWarning1, HasDisplayedKeyHoldMacroSpeedWarning2

    UpdatedSliderValue := GuiCtrlObj.Value
    KeyHold_Text.Value := GenerateMacroSpeedText("Key-Hold", UpdatedSliderValue)
    message := ""

    if UpdatedSliderValue <= 20 {
        if not HasDisplayedKeyHoldMacroSpeedWarning2 {
            message := "Legend said, only NASA computers can run this!"
            HasDisplayedKeyHoldMacroSpeedWarning1 := true
            HasDisplayedKeyHoldMacroSpeedWarning2 := true
        }
    } else if UpdatedSliderValue <= 30 {
        if not HasDisplayedKeyHoldMacroSpeedWarning1 {
            message := "These minimal speeds are recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise."
            HasDisplayedKeyHoldMacroSpeedWarning1 := true
        }
        HasDisplayedKeyHoldMacroSpeedWarning2 := false
    } else {
        HasDisplayedKeyHoldMacroSpeedWarning1 := false
        HasDisplayedKeyHoldMacroSpeedWarning2 := false
    }

    if not message == "" {
        SetRunMacroDependencies(false, KeyHold_Slider)
        MsgBox(
            message,
            SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
        SetRunMacroDependencies(true, KeyHold_Slider)
    }

    Settings_Map["KEY_HOLD"] := UpdatedSliderValue
}

UpdateKeyReleaseMacroSpeed(GuiCtrlObj, Info) {
    global HasDisplayedKeyReleaseMacroSpeedWarning1, HasDisplayedKeyReleaseMacroSpeedWarning2

    UpdatedSliderValue := GuiCtrlObj.Value
    KeyRelease_Text.Value := GenerateMacroSpeedText("Key-Release", UpdatedSliderValue)
    message := ""

    if UpdatedSliderValue <= 20 {
        if not HasDisplayedKeyReleaseMacroSpeedWarning2 {
            message := "Legend said, only NASA computers can run this!"
            HasDisplayedKeyReleaseMacroSpeedWarning1 := true
            HasDisplayedKeyReleaseMacroSpeedWarning2 := true
        }
    } else if UpdatedSliderValue <= 30 {
        if not HasDisplayedKeyReleaseMacroSpeedWarning1 {
            message := "These minimal speeds are recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise."
            HasDisplayedKeyReleaseMacroSpeedWarning1 := true
        }
        HasDisplayedKeyReleaseMacroSpeedWarning2 := false
    } else {
        HasDisplayedKeyReleaseMacroSpeedWarning1 := false
        HasDisplayedKeyReleaseMacroSpeedWarning2 := false
    }

    if not message == "" {
        SetRunMacroDependencies(false, KeyRelease_Slider)
        MsgBox(
            message,
            SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
        SetRunMacroDependencies(true, KeyRelease_Slider)
    }

    Settings_Map["KEY_RELEASE"] := UpdatedSliderValue
}

ReloadAllWeapons_Edit_Change(GuiCtrlObj, Info) {
    Value := GuiCtrlObj.Value

    if Value == "" {
        return false
    }

    if !IsInteger(Value) or (Value < 1 or Value > 10) {
        ReloadAllWeapons_Edit__DisplayErrorAndReset(GuiCtrlObj)
        return false
    }

    Settings_Map["EDIT_RELOAD_All_WEAPONS"] := Value

    return true
}

ReloadAllWeapons_Edit_LoseFocus(GuiCtrlObj, Info) {
    Value := GuiCtrlObj.Value

    if Value == "" {
        ReloadAllWeapons_Edit__DisplayErrorAndReset(GuiCtrlObj)
        return false
    }
    return true
}

HandleGuiSize(GuiObj, MinMax, Width, Height) {
    if MinMax == -1 {
        MinimizeAllGuis()
    } else if MinMax == 0 {
        RestoreAllGuis()
    }
}
