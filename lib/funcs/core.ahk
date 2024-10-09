/*
    core.ahk
    These are custom functions used throughout the script.
*/

AddSeparator(GuiObj, Options := {}) {
    TextOptions1 := "w0 h0" . (Options.HasOwnProp("text1") ? " " . Options.text1 : "")
    TextOptions2 := "w329 h1 Border" . (Options.HasOwnProp("text2") ? " " . Options.text2 : "")
    TextOptions3 := "w0 h0" . (Options.HasOwnProp("text3") ? " " . Options.text3 : "")

    GuiObj.AddText(TextOptions1, "")
    GuiObj.AddText(TextOptions2, "")
    GuiObj.AddText(TextOptions3, "")
}

; Function to center a GUI element
CenterElement(GuiObj, element) {
    ; Get the dimensions of the GUI
    GuiObj.GetPos(&guiX, &guiY, &guiWidth, &guiHeight)

    ; Get the dimensions of the element
    element.GetPos(&elementX, &elementY, &elementWidth, &elementHeight)

    ; Calculate the new X position to center the element horizontally
    newX := ((guiWidth - elementWidth) / 2) - CENTER_ADJUSTMENT_PIXELS

    ; Move the element to the center horizontally, keeping its original Y position
    element.Move(newX, elementY)
}

; Function to center multiple GUI elements with spacing and a left adjustment
CenterElements(GuiObj, spacing := 10, elements*) {
    ; Get the dimensions of the GUI
    GuiObj.GetPos(&guiX, &guiY, &guiWidth, &guiHeight)

    ; Calculate total width of all elements including spacing
    totalWidth := 0
    elementCount := 0
    for element in elements {
        element.GetPos(&elementX, &elementY, &elementWidth, &elementHeight)
        totalWidth += elementWidth
        elementCount++
    }
    totalWidth += spacing * (elementCount - 1) ; Add spacing between elements

    ; Calculate starting position to center all elements with adjustment
    startX := ((guiWidth - totalWidth) / 2) - CENTER_ADJUSTMENT_PIXELS

    ; Position elements with spacing
    currentX := startX
    for element in elements {
        ; Get the dimensions of the current element
        element.GetPos(&elementX, &elementY, &elementWidth, &elementHeight)

        ; Move the element to the current X position
        element.Move(currentX, elementY)

        ; Update current X position for the next element
        currentX += elementWidth + spacing
    }
}

ApplySettings() {
    for key, value in Settings_Map {
        if key == "KEY_HOLD" {
            KeyHold_Text.Value := GenerateMacroSpeedText("Key-Hold", Settings_Map["KEY_HOLD"])
            KeyHold_Slider.Value := Settings_Map["KEY_HOLD"]
        } else if key == "KEY_RELEASE" {
            KeyRelease_Text.Value := GenerateMacroSpeedText("Key-Release", Settings_Map["KEY_RELEASE"])
            KeyRelease_Slider.Value := Settings_Map["KEY_RELEASE"]
        }
        ;} else if key == "RADIO_RELOAD_All_WEAPONS_METHOD" {
        ;} else if key == "RADIO_RELOAD_All_WEAPONS_ITERATE_DIRECTION" {
        ;} else if key == "EDIT_RELOAD_All_WEAPONS" {
        ;
        ;} else if key == "HOTKEY_BST" {
        ;} else if key == "HOTKEY_RELOAD" {
        ;} else if key == "HOTKEY_SPAMRESPAWN" {
        ;} else if key == "HOTKEY_THERMALVISION" {
        ;} else if key == "HOTKEY_SUSPENDGAME" {
        ;} else if key == "HOTKEY_TERMINATEGAME" {
        ;
        ;} else if key == "KEY_BINDING__INTERACTION_MENU" {
        ;}
    }
}

LoadSettings(Options := {}) {
    Options.IsScriptStartup := Options.HasOwnProp("IsScriptStartup") ? Options.IsScriptStartup : false

    file := false
    try {
        file := FileOpen(SCRIPT_SETTINGS_FILE, "r")
    }
    if file and IsObject(file) {
        while !file.AtEOF {
            line := file.ReadLine()
            if line != "" {
                parts := StrSplit(line, "=")
                if parts.Length == 2 {
                    key := parts[1]
                    value := parts[2]
                    Settings_Map[key] := value
                }
            }
        }
        file.Close()
        if not Options.IsScriptStartup {
            ApplySettings()
            MsgBox(
                "Saved settings loaded successfully!`n`nThey are now appplied.",
                SETTINGS_SCRIPT_TITLE,
                "OK Iconi " . MSGBOX_SYSTEM_MODAL
            )
        }
        return
    }
    if not Options.IsScriptStartup {
        MsgBox(
            "Something went wrong while loading your saved settings :(",
            SETTINGS_SCRIPT_TITLE,
            "OK Iconx " . MSGBOX_SYSTEM_MODAL
        )
    }
}

SaveSettings() {
    file := false
    try {
        file := FileOpen(SCRIPT_SETTINGS_FILE, "w")
    }
    if file and IsObject(file) {
        for key, value in Settings_Map {
            file.WriteLine(key . "=" . value)
        }
        file.Close()
        MsgBox(
            "Settings saved successfully!`n`nThey will now be auto-applied upon next times.",
            SETTINGS_SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
        return
    }
    MsgBox(
        "Something went wrong while saving your settings :(",
        SETTINGS_SCRIPT_TITLE,
        "OK Iconx " . MSGBOX_SYSTEM_MODAL
    )
}

ResetSettings() {
    Settings_Map := DEFAULT_SETTINGS__MAP.Clone()

    file := false
    try {
        file := FileOpen(SCRIPT_SETTINGS_FILE, "w")
    }
    if file and IsObject(file) {
        for key, value in DEFAULT_SETTINGS__MAP {
            file.WriteLine(key . "=" . value)
        }
        file.Close()
        ApplySettings()
        MsgBox(
            "Settings reset successfully!`n`nThey will be auto-applied upon next times.",
            SETTINGS_SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
        return
    }
    MsgBox(
        "Something went wrong while reset your settings :(",
        SETTINGS_SCRIPT_TITLE,
        "OK Iconx " . MSGBOX_SYSTEM_MODAL
    )
}

GenerateMacroSpeedText(SpeedType, NewSpeed) {
    return SpeedType . " Speed [" . NewSpeed . "ms]:"
}

SetRunMacroDependencies(State, ForceFocus := "") {
    KeyHold_Slider.Enabled := State
    KeyRelease_Slider.Enabled := State
    SuspendGame_Button.Enabled := State

    ReloadAllWeapons_IterateAll__Radio.Enabled := State
    ReloadAllWeapons_HeavyWeapon__Radio.Enabled := State
    KeyBinding_Interaction_Menu__HotkeyEdit.Enabled := State
    KeyBinding_Interaction_Menu__ApplyButton.Enabled := State
    KeyBinding_Interaction_Menu__ResetButton.Enabled := State
    ReloadAllWeapons_Edit.Enabled := State
    ReloadAllWeapons_UpDown.Enabled := State

    if not ForceFocus == "" {
        ForceFocus.Focus()
    }
}

OpenMainGui() {
    MyMainGui.Show("w" . GUI_RESOLUTIONS.MAIN.WIDTH . "h" . GUI_RESOLUTIONS.MAIN.HEIGHT)
    MyMainGui.OnEvent("Size", HandleGuiSize)
}

OpenSettingsGui() {
    MySettingsGui.Show("w" . GUI_RESOLUTIONS.SETTINGS.WIDTH . "h" . GUI_RESOLUTIONS.SETTINGS.HEIGHT)
    MySettingsGui.OnEvent("Size", HandleGuiSize)
    MyMainGui.Opt("+Disabled")
}

OpenReloadSettingsGui() {
    MyReloadSettingsGui.Show("w" . GUI_RESOLUTIONS.RELOAD_SETTINGS.WIDTH . "h" . GUI_RESOLUTIONS.RELOAD_SETTINGS.HEIGHT)
    MyReloadSettingsGui.OnEvent("Size", HandleGuiSize)
    MyMainGui.Opt("+Disabled")
    MySettingsGui.Opt("+Disabled")
}

OpenKeybindSettingsGui() {
    MyKeybindSettingsGui.Show("w" . GUI_RESOLUTIONS.KEYBINDS_SETTINGS.WIDTH . "h" . GUI_RESOLUTIONS.KEYBINDS_SETTINGS.HEIGHT)
    MyKeybindSettingsGui.OnEvent("Size", HandleGuiSize)
    MyMainGui.Opt("+Disabled")
    MySettingsGui.Opt("+Disabled")
}

OpenHotkeySettingsGui() {
    MyHotkeySettingsGui.Show("w" . GUI_RESOLUTIONS.HOTKEYS_SETTINGS.WIDTH . "h" . GUI_RESOLUTIONS.HOTKEYS_SETTINGS.HEIGHT)
    MyHotkeySettingsGui.OnEvent("Size", HandleGuiSize)
    MyMainGui.Opt("+Disabled")
    MySettingsGui.Opt("+Disabled")
}

ReEnableGui(GuiToReEnable) {
    GuiToReEnable.Opt("-Disabled")
}

MinimizeAllGuis() {
    MinimizeGui(GuiObj) {
        static WS_VISIBLE := 0x10000000

        if not WinExist(GuiObj.Hwnd) {
            return
        }

        Style := WinGetStyle(GuiObj.Hwnd)
        if not (Style & WS_VISIBLE) {
            return
        }

        GuiObj.Minimize()
    }

    MinimizeGui(MyMainGui)
    MinimizeGui(MySettingsGui)
    MinimizeGui(MyReloadSettingsGui)
    MinimizeGui(MyKeybindSettingsGui)
    MinimizeGui(MyHotkeySettingsGui)
}

RestoreAllGuis() {
    RestoreGui(GuiObj) {
        static WS_VISIBLE := 0x10000000

        if not WinExist(GuiObj.Hwnd) {
            return
        }

        Style := WinGetStyle(GuiObj.Hwnd)
        if not (Style & WS_VISIBLE)  {
            return
        }

        GuiObj.Show()
    }

    RestoreGui(MyMainGui)
    RestoreGui(MySettingsGui)
    RestoreGui(MyReloadSettingsGui)
    RestoreGui(MyKeybindSettingsGui)
    RestoreGui(MyHotkeySettingsGui)
}

OpenRepo() {
    Run(SCRIPT_REPOSITORY)
}

RunUpdater(Source) {
    GetLatestReleaseInfo() {
        try {
            Response := WebRequest("GET", SCRIPT_VERSION_UPDATER_URL)

            if Response.Status == 200 {
                return Version(Response.Text)
            }
        }

        throw Error(UPDATER_FETCHING_ERROR)
    }

    static CurrentVersion := Version(SCRIPT_VERSION)

    try {
        LatestVersion := GetLatestReleaseInfo()
    } catch error as err {
        if (err.Message == UPDATER_FETCHING_ERROR) {
            MsgBox(
                UPDATER_FETCHING_ERROR,
                UPDATER_SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return
        }
        throw err
    }

    if Updater(CurrentVersion).CheckForUpdate(LatestVersion) {
        MsgBox_Text := "New version found. Do you want to update ?`n`n"
        MsgBox_Text .= "Current Version: " . SCRIPT_VERSION . "`n"
        MsgBox_Text .= "Latest Version: " . LatestVersion.Version . " - " . LatestVersion.DateTime
        MsgBox_Result := MsgBox(
            MsgBox_Text,
            UPDATER_SCRIPT_TITLE,
            "YesNo Iconi " . MSGBOX_SYSTEM_MODAL
        )
        if MsgBox_Result == "Yes" {
            Run(SCRIPT_LATEST_RELEASE_URL)
            ExitApp
        }
    } else {
        if Source == "MANUAL" {
            MsgBox_Text := "You are up-to-date :)`n`n"
            MsgBox_Text .= "Current Version: " . SCRIPT_VERSION . "`n"
            MsgBox_Text .= "Latest Version: " . LatestVersion.Version . " - " . LatestVersion.DateTime
            MsgBox(
                MsgBox_Text,
                UPDATER_SCRIPT_TITLE,
                "Ok Iconi " . MSGBOX_SYSTEM_MODAL
            )
        }
    }
}

GetValidGTAwinRunning(Options := {}) {
    ; Get the HWND of the first window matching GTA_WINDOW_IDENTIFIER or uses the one supplied from user.
    gtaWindowID := Options.HasOwnProp("hwnd") ? Options.hwnd : ""
    CheckIsActive := Options.HasOwnProp("AndActive") ? Options.AndActive : ""

    if gtaWindowID == 0 {
        return 0
    }

    if not gtaWindowID == "" {
        gtaWindowID := WinExist(GTA_WINDOW_IDENTIFIER . " ahk_id " . gtaWindowID)
    } else {
        gtaWindowID := WinExist(GTA_WINDOW_IDENTIFIER)
    }

    if not gtaWindowID {
        return 0
    }

    if not CheckIsActive == "" {
        isGTAwindowActive := WinActive("ahk_id " gtaWindowID)

        if CheckIsActive == true {
            if not isGTAwindowActive {
                return 0
            }
        } else if CheckIsActive == false {
            if isGTAwindowActive {
                return 0
            }
        }
    }

    return gtaWindowID
}

RunMacro(macroFunc, triggerSource) {
    ; If Alt + F4 is pressed, prevent the macro from running and pass the keystroke back to the system.
    if GetKeyState("Alt", "P") and GetKeyState("F4", "P") {
        SendEvent("{Alt Down}{F4}{Alt Up}")
        return false
    }

    global isMacroRunning

    if isMacroRunning {
        return false
    }
    isMacroRunning := true
    SetRunMacroDependencies(false)
    result := macroFunc(triggerSource)
    SetRunMacroDependencies(true)
    isMacroRunning := false

    return result
}

SendKeyWithDelay(key, holdTime, releaseTime) {
    Send("{Blind}{" . key . " down}")
    Sleep(holdTime)
    Send("{Blind}{" . key . " up}")
    Sleep(releaseTime)
}

/*
Processes a sequence of keystrokes for the game.
Takes a list of keystrokes where each keystroke includes:
- `count`: Number of times the key should be pressed
- `key`: The key to be pressed
- `hold`: Duration to hold the key
- `release`: Time to wait between key presses

Checks if the GTA V window is active before sending each keystroke.
Displays an error message and aborts if either the user interrupted the macro, or if the GTA V window is no longer active or .
*/
ProcessGTAKeystrokes(triggerSource, Keystrokes) {
    static CheckUserInputStopConditions() {
        for StopKey in USER_INPUT__CURRENTLY_PLAYING_MACRO__STOPPING_KEYS {
            if GetKeyState(StopKey, "P") {
                return true
            }
        }

        return false
    }


    ThisGtaWindowID := gtaWindowID

    if not GetValidGTAwinRunning({ hwnd: ThisGtaWindowID }) {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        return false
    }

    if triggerSource == "Button" and not WinActive("ahk_id " ThisGtaWindowID) {
        MyMainGui.Minimize()
        WinActivate("ahk_id " ThisGtaWindowID)
        Sleep(100)
        if not WinActive("ahk_id " ThisGtaWindowID) {
            MsgBox(
                "ERROR: Failed to activate GTA V window, aborting process.",
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return false
        }
        ToolTip()
        Sleep(500)
    }

    for index, Keystroke in Keystrokes {
        ; Apply default values if not provided in the Keystroke properties.
        Keystroke.count := Keystroke.HasOwnProp("count") ? Keystroke.count : 1
        Keystroke.hold := Keystroke.HasOwnProp("hold") ? Keystroke.hold : Settings_Map["KEY_HOLD"]
        Keystroke.release := Keystroke.HasOwnProp("release") ? Keystroke.release : Settings_Map["KEY_RELEASE"]

        loop Keystroke.count {
            if not GetValidGTAwinRunning({ hwnd: ThisGtaWindowID, AndActive: true }) {
                MsgBox(
                    "ERROR: GTA V window is no longer active, aborting process.",
                    SCRIPT_TITLE,
                    "OK Icon! " . MSGBOX_SYSTEM_MODAL
                )
                return false
            }

            ; Set release to 0 for the last Keystroke
            if (A_Index == Keystroke.count and index == Keystrokes.Length) {
                Keystroke.release := 0
            }

            if CheckUserInputStopConditions() {
                return false
            }

            SendKeyWithDelay(Keystroke.key, Keystroke.hold, Keystroke.release)
        }
    }

    return true
}

DropBST(triggerSource) {
    BST_Keystrokes := [
        { key: Settings_Map["KEY_BINDING__INTERACTION_MENU"] }, ; in [Interaction Menu]
        { key: "Enter" }, ; in [SecuroServ CEO]
        { key: "Down", count: 4 }, ; hover [CEO Abilities]
        { key: "Enter" }, ; in [CEO Abilities]
        { key: "Down" }, ; hover [Drop Bull Shark]
        { key: "Enter" } ; select [Drop Bull Shark]
    ]

    return ProcessGTAKeystrokes(triggerSource, BST_Keystrokes)
}

ReloadAllWeapons(triggerSource) {
    direction := ""
    if ReloadAllWeapons_IterateAll__Direction_Right__Radio.Value == 1 {
        direction := "Right"
    } else {
        direction := "Left"
    }

    Reload_Keystrokes := []

    Reload_Keystrokes.Push(
        { key: Settings_Map["KEY_BINDING__INTERACTION_MENU"] }, ; in [Interaction Menu]
        { key: "Down", count: 4 }, ; hover [Health and Ammo]
        { key: "Enter", count: 2 } ; in [Health and Ammo] and [Ammo]
    )

    if ReloadAllWeapons_HeavyWeapon__Radio.Value == 1 {
        Reload_Keystrokes.Push(
            { key: "Enter" }, ; hover [Ammo Type < All >]
            { key: "Up" }, ; hover [Full Ammo $x]
            { key: "Enter" } ; select [Full Ammo $x]
        )
    } else {
        NumOfWeaponTypesToIterate := Settings_Map["EDIT_RELOAD_All_WEAPONS"]

        ; Iterate through each [Ammo Type] and select the [Full Ammo $x] option for each
        Loop NumOfWeaponTypesToIterate {
            Reload_Keystrokes.Push(
                { key: "Up" }, ; hover [Full Ammo $x]
                { key: "Enter" } ; select [Full Ammo $x]
            )

            ; Only add "Down" and "Left" if it's not the last iteration
            if (A_Index < NumOfWeaponTypesToIterate) {
                Reload_Keystrokes.Push(
                    { key: "Down" }, ; hover [Ammo Type < x >]
                    { key: direction } ; hover [Ammo Type < y >]
                )
            }
        }
    }

    Reload_Keystrokes.Push({ key: Settings_Map["KEY_BINDING__INTERACTION_MENU"] }) ; exit [Interaction Menu]

    return ProcessGTAKeystrokes(triggerSource, Reload_Keystrokes)
}

SpamRespawn(triggerSource) {
    SpamRespawn_Keystrokes := [
        { key: "LButton", count: 20 } ; select [Respawn]
    ]

    return ProcessGTAKeystrokes(triggerSource, SpamRespawn_Keystrokes)
}

ThermalVision(triggerSource) {
    ThermalVision_Keystrokes := [
        { key: Settings_Map["KEY_BINDING__INTERACTION_MENU"] }, ; in [Interaction Menu]
        { key: "Down", count: 5 }, ; hover [Appearance]
        { key: "Enter" }, ; select [Appearance]
        { key: "Down" }, ; hover [Accessories]
        { key: "Enter" }, ; select [Accessories]
        { key: "Down", count: 4 }, ; hover [Helmets]
        { key: "Space" }, ; select [Helmets]
        { key: Settings_Map["KEY_BINDING__INTERACTION_MENU"] } ; exit [Interaction Menu]
    ]

    return ProcessGTAKeystrokes(triggerSource, ThermalVision_Keystrokes)
}

SuspendGame(triggerSource) {
    OpenProcess(PID) {
        h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID)
        return h ? h : -1
    }

    SuspendProcess(h) {
        DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
    }

    ResumeProcess(h) {
        DllCall("ntdll.dll\NtResumeProcess", "Int", h)
    }

    CloseProcess(h) {
        DllCall("CloseHandle", "Int", h)
    }


    ReturnState := false

    SetRunMacroDependencies(false)
    TerminateGame_Button.Enabled := false

    Result := MsgBox(
        'Are you sure you want to suspend GTA V ?',
        SCRIPT_TITLE,
        "YesNo Iconi " . MSGBOX_SYSTEM_MODAL
    )
    if Result == "Yes" {
        if gtaWindowID {
            h := OpenProcess(WinGetPID(gtaWindowID))
            if h {
                SuspendProcess(h)
                Sleep(8000)
                ResumeProcess(h)
                CloseProcess(h)
            }
            ReturnState := true
        } else {
            MsgBox(
                'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
        }
    } else {
        TerminateGame_Button.Enabled := true
        SetRunMacroDependencies(true)
    }

    TerminateGame_Button.Enabled := true
    SetRunMacroDependencies(true)

    return ReturnState
}

TerminateGame(triggerSource) {
    ReturnState := false

    SetRunMacroDependencies(false)
    TerminateGame_Button.Enabled := false

    Result := MsgBox(
        'Are you sure you want to terminate GTA V ?',
        SCRIPT_TITLE,
        "YesNo Iconi " . MSGBOX_SYSTEM_MODAL
    )
    if Result == "Yes" {
        if gtaWindowID {
            ProcessClose(WinGetPID(gtaWindowID))
            ReturnState := true
        } else {
            MsgBox(
                'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
        }
    } else {
        TerminateGame_Button.Enabled := true
        SetRunMacroDependencies(true)
    }

    TerminateGame_Button.Enabled := true
    SetRunMacroDependencies(true)

    return ReturnState
}

GetHotkeysObjects_Map(HotkeyName := "") {
    HotkeysObjects_Map := Map(
        "HOTKEY_BST", {
            Hotkey: Settings_Map["HOTKEY_BST"],
            DefaultHotkey: DEFAULT_SETTINGS__MAP["HOTKEY_BST"],
            HotkeyEdit: HotkeyBST_HotkeyEdit,
            ApplyButton: HotkeyBST_ApplyButton,
            ResetButton: HotkeyBST_ResetButton,
            ToggleButton: HotkeyBST_ToggleButton,
            MacroFunc: DropBST
        },
        "HOTKEY_RELOAD", {
            Hotkey: Settings_Map["HOTKEY_RELOAD"],
            DefaultHotkey: DEFAULT_SETTINGS__MAP["HOTKEY_RELOAD"],
            HotkeyEdit: HotkeyReload_HotkeyEdit,
            ApplyButton: HotkeyReload_ApplyButton,
            ResetButton: HotkeyReload_ResetButton,
            ToggleButton: HotkeyReload_ToggleButton,
            MacroFunc: ReloadAllWeapons
        },
        "HOTKEY_SPAMRESPAWN", {
            Hotkey: Settings_Map["HOTKEY_SPAMRESPAWN"],
            DefaultHotkey: DEFAULT_SETTINGS__MAP["HOTKEY_SPAMRESPAWN"],
            HotkeyEdit: HotkeySpamRespawn_HotkeyEdit,
            ApplyButton: HotkeySpamRespawn_ApplyButton,
            ResetButton: HotkeySpamRespawn_ResetButton,
            ToggleButton: HotkeySpamRespawn_ToggleButton,
            MacroFunc: SpamRespawn
        },
        "HOTKEY_THERMALVISION", {
            Hotkey: Settings_Map["HOTKEY_THERMALVISION"],
            DefaultHotkey: DEFAULT_SETTINGS__MAP["HOTKEY_THERMALVISION"],
            HotkeyEdit: HotkeyThermalVision_HotkeyEdit,
            ApplyButton: HotkeyThermalVision_ApplyButton,
            ResetButton: HotkeyThermalVision_ResetButton,
            ToggleButton: HotkeyThermalVision_ToggleButton,
            MacroFunc: ThermalVision
        },
        "HOTKEY_SUSPENDGAME", {
            Hotkey: Settings_Map["HOTKEY_SUSPENDGAME"],
            DefaultHotkey: DEFAULT_SETTINGS__MAP["HOTKEY_SUSPENDGAME"],
            Button: SuspendGame_Button,
            HotkeyEdit: HotkeySuspendGame_HotkeyEdit,
            ApplyButton: HotkeySuspendGame_ApplyButton,
            ResetButton: HotkeySuspendGame_ResetButton,
            ToggleButton: HotkeySuspendGame_ToggleButton,
            MacroFunc: SuspendGame
        },
        "HOTKEY_TERMINATEGAME", {
            Hotkey: Settings_Map["HOTKEY_TERMINATEGAME"],
            DefaultHotkey: DEFAULT_SETTINGS__MAP["HOTKEY_TERMINATEGAME"],
            Button: TerminateGame_Button,
            HotkeyEdit: HotkeyTerminateGame_HotkeyEdit,
            ApplyButton: HotkeyTerminateGame_ApplyButton,
            ResetButton: HotkeyTerminateGame_ResetButton,
            ToggleButton: HotkeyTerminateGame_ToggleButton,
            MacroFunc: TerminateGame
        }
    )
    if (HotkeyName != "") {
        return HotkeysObjects_Map[HotkeyName]
    }

    return HotkeysObjects_Map
}

RemoveHotkey(HotkeyToRemove) {
    HotkeyObjects_Map := GetHotkeysObjects_Map(HotkeyToRemove)

    if not (HotkeyObjects_Map.Hotkey == false) {
        Hotkey(HotkeyObjects_Map.Hotkey, "Off")
    }
    HotkeyObjects_Map.HotkeyEdit.Value := ""
    HotkeyObjects_Map.ToggleButton.Enabled := false
    Settings_Map[HotkeyToRemove] := false
}

ApplyHotkey(HotkeyToApply) {
    CheckHotkeyConflict(HotkeyEdit, CurrentHotkeyName, OriginalValue) {
        for HotkeyName, Data in GetHotkeysObjects_Map() {
            if not CurrentHotkeyName == HotkeyName and HotkeyEdit.Value == Data.Hotkey {
                MsgBox(
                    "Error: You cannot assign a hotkey to more than one macro.",
                    SCRIPT_TITLE,
                    "OK Icon! " . MSGBOX_SYSTEM_MODAL
                )
                HotkeyEdit.Value := OriginalValue
                return true
            }
        }
        return false
    }

    HotkeyObjects_Map := GetHotkeysObjects_Map(HotkeyToApply)

    if not (HotkeyObjects_Map.Hotkey == false) {
        if CheckHotkeyConflict(HotkeyObjects_Map.HotkeyEdit, HotkeyToApply, HotkeyObjects_Map.Hotkey) {
            return false
        }

        Hotkey(HotkeyObjects_Map.Hotkey, "Off")
    }

    if (HotkeyObjects_Map.HotkeyEdit.Value == "") {
        RemoveHotkey(HotkeyToApply)
        return true
    }

    try {
        Hotkey(HotkeyObjects_Map.HotkeyEdit.Value, (*) => RunMacro(HotkeyObjects_Map.MacroFunc, "Hotkey"))
    } catch error as err {
        if ((err.What == "Hotkey") and ((err.Message == "Invalid key name.") or (err.Message == "Invalid hotkey."))) {
            MsgBox(
                "Error: " . err.Message,
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )

            if (HotkeyObjects_Map.Hotkey == false) {
                HotkeyObjects_Map.HotkeyEdit.Value := ""
                return true
            }

            Hotkey(HotkeyObjects_Map.Hotkey, (*) => RunMacro(HotkeyObjects_Map.MacroFunc, "Hotkey"))
            Hotkey(HotkeyObjects_Map.Hotkey, "On")
            HotkeyObjects_Map.HotkeyEdit.Value := HotkeyObjects_Map.Hotkey

            return false
        }
        throw err
    }

    Hotkey(HotkeyObjects_Map.HotkeyEdit.Value, "On")
    HotkeyObjects_Map.ToggleButton.Enabled := true
    Settings_Map[HotkeyToApply] := HotkeyObjects_Map.HotkeyEdit.Value

    return true
}

ResetHotkey(HotkeyToReset) {
    HotkeyObjects_Map := GetHotkeysObjects_Map(HotkeyToReset)

    if not (HotkeyObjects_Map.Hotkey == false) {
        Hotkey(HotkeyObjects_Map.Hotkey, "Off")
    }
    Hotkey(HotkeyObjects_Map.DefaultHotkey, "On")
    HotkeyObjects_Map.HotkeyEdit.Value := HotkeyObjects_Map.DefaultHotkey
    HotkeyObjects_Map.ToggleButton.Enabled := true
    Settings_Map[HotkeyToReset] := HotkeyObjects_Map.DefaultHotkey
}

ToggleHotkey(HotkeyToToggle) {
    HotkeyObjects_Map := GetHotkeysObjects_Map(HotkeyToToggle)

    if (HotkeyObjects_Map.ToggleButton.Text == "Enable") {
        try {
            Hotkey(HotkeyObjects_Map.Hotkey, "On")
        } catch error as err {
            if not ((err.What == "Hotkey") and (err.Message == "Nonexistent hotkey.")) {
                throw err
            }
        } else {
            HotkeyObjects_Map.ToggleButton.Text := "Disable"
        }
        HotkeyObjects_Map.HotkeyEdit.Enabled := true
        HotkeyObjects_Map.ApplyButton.Enabled := true
        HotkeyObjects_Map.ResetButton.Enabled := true
    } else if (HotkeyObjects_Map.ToggleButton.Text == "Disable") {
        try {
            Hotkey(HotkeyObjects_Map.Hotkey, "Off")
        } catch error as err {
            if not ((err.What == "Hotkey") and (err.Message == "Nonexistent hotkey.")) {
                throw err
            }
        } else {
            HotkeyObjects_Map.ToggleButton.Text := "Enable"
        }
        HotkeyObjects_Map.HotkeyEdit.Enabled := false
        HotkeyObjects_Map.ApplyButton.Enabled := false
        HotkeyObjects_Map.ResetButton.Enabled := false
    }
}

OnEdit_Focus(ApplyButton) {
    ApplyButton.Opt("+Default")
}

OnEdit_LoseFocus(EditField, ApplyButton, FallbackValue) {
    if not ApplyButton.Focused {
        EditField.Value := FallbackValue
    }
    ApplyButton.Opt("-Default")
}

ReloadAllWeapons_IterateAll__Click() {
    MyReloadSettingsGui.Hide()
    ReloadSettings_Button.Enabled := false
}

ReloadAllWeapons_HeavyWeapon__Click() {
    ReloadSettings_Button.Enabled := true
}

ReloadAllWeapons_Edit__DisplayErrorAndReset(GuiCtrlObj) {
    SetRunMacroDependencies(false)
    MsgBox(
        "Error: The value must be a number between 1 and 10.",
        SETTINGS_SCRIPT_TITLE,
        "OK Icon! " . MSGBOX_SYSTEM_MODAL
    )
    GuiCtrlObj.Value := Settings_Map["EDIT_RELOAD_All_WEAPONS"]
    SetRunMacroDependencies(true)
}

MainLoop() {
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
    global MyMainGui, prevX, prevY, prevW, prevH

    MyMainGui.GetPos(&x, &y, &w, &h)

    if (x != prevX || y != prevY || w != prevW || h != prevH) {
        ToolTip()
        prevX := x, prevY := y, prevW := w, prevH := h
    }
    ; END mainGUI
}

ApplyKeyBinding(KeyBindingToApply) {
    KeyBind := KeyBinding_Interaction_Menu__HotkeyEdit.Value

    if GetKeySC(KeyBind) {
        Settings_Map[KeyBindingToApply] := KeyBind
        return true
    }

    MsgBox(
        "Error: Invalid key name.",
        SCRIPT_TITLE,
        "OK Icon! " . MSGBOX_SYSTEM_MODAL
    )
    KeyBinding_Interaction_Menu__HotkeyEdit.Value := Settings_Map[KeyBindingToApply]
    return false
}

ResetKeyBinding(KeyBindingToReset) {
    KeyBinding_Interaction_Menu__HotkeyEdit.Value := DEFAULT_SETTINGS__MAP[KeyBindingToReset]
    Settings_Map[KeyBindingToReset] := DEFAULT_SETTINGS__MAP[KeyBindingToReset]
}
