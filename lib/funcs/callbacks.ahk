/*
    callbacks.ahk
    These functions are callbacks and must be called without parameters, as AHK v2 provides the necessary arguments.
*/

On_WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    static PrevHwnd := 0

    if not (hwnd == PrevHwnd) {
        ToolTip()
        CurrControl := GuiCtrlFromHwnd(hwnd)
        if CurrControl {
            if not CurrControl.HasProp("ToolTip") {
                return
            }
            Text := CurrControl.ToolTip
            SetTimer(() => ToolTip(Text), -TOOLTIP_DISPLAY_TIME)
            SetTimer(() => ToolTip(), -TOOLTIP_HIDE_TIME)
        }

        PrevHwnd := hwnd
    }
}

Link_Click(Ctrl, ID, HREF) {
    Run(HREF)
}

UpdateKeyHoldMacroSpeed(GuiCtrlObj, Info) {
    global HasDisplayedMacroSpeedWarning1, HasDisplayedMacroSpeedWarning2

    UpdatedSliderValue := GuiCtrlObj.Value
    KeyHold_Text.Value := GenerateMacroSpeedText("Key-Hold", UpdatedSliderValue)
    message := ""

    if UpdatedSliderValue <= 20 {
        if not HasDisplayedMacroSpeedWarning2 {
            message := "Legend said, only NASA computers can run this!"
            HasDisplayedMacroSpeedWarning2 := true
            HasDisplayedMacroSpeedWarning1 := true
        }
    } else if UpdatedSliderValue <= 30 {
        if not HasDisplayedMacroSpeedWarning1 {
            message := "These minimal speeds are recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise."
            HasDisplayedMacroSpeedWarning1 := true
        }
        HasDisplayedMacroSpeedWarning2 := false
    } else {
        HasDisplayedMacroSpeedWarning1 := false
        HasDisplayedMacroSpeedWarning2 := false
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
    global HasDisplayedMacroSpeedWarning1, HasDisplayedMacroSpeedWarning2

    UpdatedSliderValue := GuiCtrlObj.Value
    KeyRelease_Text.Value := GenerateMacroSpeedText("Key-Release", UpdatedSliderValue)
    message := ""

    if UpdatedSliderValue <= 20 {
        if not HasDisplayedMacroSpeedWarning2 {
            message := "Legend said, only NASA computers can run this!"
            HasDisplayedMacroSpeedWarning2 := true
            HasDisplayedMacroSpeedWarning1 := true
        }
    } else if UpdatedSliderValue <= 30 {
        if not HasDisplayedMacroSpeedWarning1 {
            message := "These minimal speeds are recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise."
            HasDisplayedMacroSpeedWarning1 := true
        }
        HasDisplayedMacroSpeedWarning2 := false
    } else {
        HasDisplayedMacroSpeedWarning1 := false
        HasDisplayedMacroSpeedWarning2 := false
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
