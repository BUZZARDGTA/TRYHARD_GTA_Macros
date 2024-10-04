#Requires AutoHotkey v2.0
#SingleInstance Force


; Constants
DEBUG_ENABLED := false

SCRIPT_TITLE := "TRYHARD Macros"
SCRIPT_VERSION := "v1.2.4 - 04/10/2024 (23:45)"
SCRIPT_REPOSITORY := "https://github.com/BUZZARDGTA/TRYHARD_GTA_Macros"
SCRIPT_LATEST_RELEASE_URL := SCRIPT_REPOSITORY . "/releases/latest"
SCRIPT_VERSION_UPDATER_URL := "https://raw.githubusercontent.com/BUZZARDGTA/TRYHARD_GTA_Macros/refs/heads/main/VERSION.txt"
SCRIPT_WINDOW_IDENTIFIER := SCRIPT_TITLE . " ahk_class " . "AutoHotkeyGUI" . " ahk_pid " . WinGetPID(A_ScriptHwnd)
UPDATER_SCRIPT_TITLE := "Updater - " . SCRIPT_TITLE
UPDATER_FETCHING_ERROR := "Error: Failed fetching release info."
SETTINGS_SCRIPT_TITLE := "Settings - " . SCRIPT_TITLE
GTA_WINDOW_IDENTIFIER := "Grand Theft Auto V ahk_class grcWindow ahk_exe GTA5.exe"
USER_INPUT__CURRENTLY_PLAYING_MACRO__STOPPING_KEYS := ["LButton", "RButton", "Enter", "Escape", "Backspace"]
MSGBOX_SYSTEM_MODAL := 4096
CENTER_ADJUSTMENT_PIXELS := 7
DEFAULT_EDIT_RELOAD_All_WEAPONS := 8

DEFAULT_KEY_BINDING__INTERACTION_MENU := "M"

DEFAULT_HOTKEY_BST := "F1"
DEFAULT_HOTKEY_RELOAD := "F2"
DEFAULT_HOTKEY_SPAMRESPAWN := "F3"
DEFAULT_HOTKEY_THERMALVISION := "F4"
DEFAULT_HOTKEY_SUSPENDGAME := "F11"
DEFAULT_HOTKEY_TERMINATEGAME := "F12"

TOOLTIP_DISPLAY_TIME := 250
TOOLTIP_HIDE_TIME := 5000

KEY_DELAY_SLOWEST := 100
KEY_DELAY_FASTEST := 20
KEY_DELAY_DEFAULT := 40

GUI_RESOLUTIONS := {
    MAIN: {
        WIDTH: 350,
        HEIGHT: 264
    },
    SETTINGS: {
        WIDTH: 350,
        HEIGHT: 540
    }
}

; Globals
Hotkeys_Map := Map(
    "HotkeyBST", DEFAULT_HOTKEY_BST,
    "HotkeyReload", DEFAULT_HOTKEY_RELOAD,
    "HotkeySpamRespawn", DEFAULT_HOTKEY_SPAMRESPAWN,
    "HotkeyThermalVision", DEFAULT_HOTKEY_THERMALVISION,
    "HotkeySuspendGame", DEFAULT_HOTKEY_SUSPENDGAME,
    "HotkeyTerminateGame", DEFAULT_HOTKEY_TERMINATEGAME
)
KeyHold := KEY_DELAY_DEFAULT
KeyDelay := KEY_DELAY_DEFAULT
IsMacroRunning := false
gtaWindowID := 0
EditReloadAllWeapons := DEFAULT_EDIT_RELOAD_All_WEAPONS
KeyBindings_Map := Map(
    "Interaction_Menu", DEFAULT_KEY_BINDING__INTERACTION_MENU
)


class Version {
    __New(ScriptVersion) {
        this.ParseVersion(ScriptVersion)
    }

    ParseVersion(ScriptVersion) {
        static RE_SCRIPT__VERSION_DATE_TIME := "^(v(\d+)\.(\d+)\.(\d+)) - (((\d{2})\/(\d{2})\/(\d{4})) \(((\d{2}):(\d{2}))\))$"

        if not RegExMatch(ScriptVersion, RE_SCRIPT__VERSION_DATE_TIME, &matches) {
            throw Error("Invalid 'SCRIPT_VERSION' format.")
        }

        this.FullMatch := matches[0]
        this.Version := matches[1]
        this.MajorVersion := matches[2]
        this.MinorVersion := matches[3]
        this.PatchVersion := matches[4]
        this.DateTime := matches[5]
        this.Date := matches[6]
        this.Day := matches[7]
        this.Month := matches[8]
        this.Year := matches[9]
        this.Time := matches[10]
        this.Hour := matches[11]
        this.Minute := matches[12]

        this.AhkTime := this.Year . this.Month . this.Day . this.Hour . this.Minute
    }
}

class Updater {
    __New(CurrentVersion) {
        this.CurrentVersion := CurrentVersion
    }

    CheckForUpdate(LatestVersion) {
        ; Step 1: Compare major, minor, and patch versions
        if (LatestVersion.MajorVersion > this.CurrentVersion.MajorVersion)
            return True
        else if (LatestVersion.MajorVersion == this.CurrentVersion.MajorVersion) {
            if (LatestVersion.MinorVersion > this.CurrentVersion.MinorVersion)
                return True
            else if (LatestVersion.MinorVersion == this.CurrentVersion.MinorVersion) {
                if (LatestVersion.PatchVersion > this.CurrentVersion.PatchVersion)
                    return True
                else if (LatestVersion.PatchVersion == this.CurrentVersion.PatchVersion) {
                    ; Step 2: Compare date and time if versioning is equal
                    return DateDiff(LatestVersion.AhkTime, this.CurrentVersion.AhkTime, "Seconds") > 0
                }
            }
        }
        return False
    }
}


SetTitleMatchMode(3) ; Exact match mode
SetStoreCapsLockMode(false)

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0

    if not (Hwnd == PrevHwnd) {
        ToolTip()
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if not CurrControl.HasProp("ToolTip") {
                return
            }
            Text := CurrControl.ToolTip
            SetTimer(() => ToolTip(Text), -TOOLTIP_DISPLAY_TIME)
            SetTimer(() => ToolTip(), -TOOLTIP_HIDE_TIME)
        }

        PrevHwnd := Hwnd
    }
}

On_WM_MOUSEWHEEL(wParam, lParam, msg, Hwnd) {
    static GET_WHEEL_DELTA_WPARAM(wParam) => (
        ; Credit: https://github.com/Seven0528/ScrollableGui
        wParam<<32>>48
    )

    ; Get the cursor position (to check if it's over the slider)
    MouseGetPos(,,, &ControlHwnd, 2)

    ; Check if the mouse is over the slider
    if ((Speed_Slider.Enabled == true) and (ControlHwnd = Speed_Slider.Hwnd)) {
        delta := GET_WHEEL_DELTA_WPARAM(wParam) ; Get scroll direction (up or down)

        ; Adjust the slider value based on scroll direction
        if (delta == 120) { ; Scrolled up
            Speed_Slider.Value := Speed_Slider.Value - 10
        } else if (delta == -120) { ; Scrolled down
            Speed_Slider.Value := Speed_Slider.Value + 10
        }
    }
}

Link_Click(Ctrl, ID, HREF) {
    Run(HREF)
}

WebRequest(method, url) {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")

    whr.Open(method, url, true)
    whr.Send()
    ; Using 'true' above and the call below allows the script to remain responsive.
    whr.WaitForResponse()

    return { Status: whr.Status, Text: whr.ResponseText }
}

Pluralize(count, singular, plural := "") {
    if count > 1 {
        return plural ? plural : singular . "s"
    }
    return singular
}

InArray(value, arr) {
    for element in arr {
        if (value == element)
            return true
    }
    return false
}

Print(str) {
    if DEBUG_ENABLED {
        OutputDebug("[" . A_ScriptName . "]: " . str)
    }
}

ShowGui(gui) {
    gui.Show()
}

HideGui(gui) {
    gui.Hide()
}

AddSeparator(gui, Options := {}) {
    TextOptions1 := "w0 h0" . (Options.HasOwnProp("text1") ? " " . Options.text1 : "")
    TextOptions2 := "w329 h1 Border" . (Options.HasOwnProp("text2") ? " " . Options.text2 : "")
    TextOptions3 := "w0 h0" . (Options.HasOwnProp("text3") ? " " . Options.text3 : "")

    gui.AddText(TextOptions1, "")
    gui.AddText(TextOptions2, "")
    gui.AddText(TextOptions3, "")
}

; Function to center a GUI element
CenterElement(gui, element) {
    ; Get the dimensions of the GUI
    gui.GetPos(&guiX, &guiY, &guiWidth, &guiHeight)

    ; Get the dimensions of the element
    element.GetPos(&elementX, &elementY, &elementWidth, &elementHeight)

    ; Calculate the new X position to center the element horizontally
    newX := ((guiWidth - elementWidth) / 2) - CENTER_ADJUSTMENT_PIXELS

    ; Move the element to the center horizontally, keeping its original Y position
    element.Move(newX, elementY)
}

; Function to center multiple GUI elements with spacing and a left adjustment
CenterElements(gui, spacing := 10, elements*) {
    ; Get the dimensions of the GUI
    gui.GetPos(&guiX, &guiY, &guiWidth, &guiHeight)

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

GenerateMacroSpeedText(NewSpeed) {
    return "Macro Speed [" . NewSpeed . "ms]:"
}

SetRunMacroDependencies(State, ForceFocus := "") {
    Speed_Slider.Enabled := State
    DropBST_Button.Enabled := State
    ReloadAllWeapons_Button.Enabled := State
    SpamRespawn_Button.Enabled := State
    ThermalVision_Button.Enabled := State
    SuspendGame_Button.Enabled := State

    ReloadAllWeapons_Iterate_All__Radio.Enabled := State
    ReloadAllWeapons_Heavy_Weapon__Radio.Enabled := State
    KeyBinding_Interaction_Menu__HotkeyEdit.Enabled := State
    KeyBinding_Interaction_Menu__ApplyButton.Enabled := State
    KeyBinding_Interaction_Menu__ResetButton.Enabled := State
    ReloadAllWeapons_Edit.Enabled := State
    ReloadAllWeapons_UpDown.Enabled := State

    if not ForceFocus == "" {
        ForceFocus.Focus()
    }
}

UpdateMacroSpeed(GuiCtrlObj, Info) {
    static RoundToNearestTen(value) {
        return Round(value / 10) * 10
    }

    global KeyDelay, KeyHold

    UpdatedSliderValue := RoundToNearestTen(GuiCtrlObj.Value)
    GuiCtrlObj.Value := UpdatedSliderValue
    ; Whenver it's 3 of len (ex: 100) it breaks, this bug drives me crazy
    Speed_Text.Value := GenerateMacroSpeedText(UpdatedSliderValue)

    ; This fixes an issue where the user can still scroll with the default properties while a message box is displayed.
    message := ""
    if (UpdatedSliderValue <= 20) {
        message := "Legend said, only NASA computers can run this!"
    } else if (UpdatedSliderValue <= 30) {
        message := "This method is recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise."
    }

    if not message == "" {
        SetRunMacroDependencies(false, Speed_Slider)
        MsgBox(
            message,
            SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
        SetRunMacroDependencies(true, Speed_Slider)
    }

    KeyDelay := UpdatedSliderValue
    KeyHold := UpdatedSliderValue
}

OpenSettings(*) {
    MySettingsGui.Show("w" . GUI_RESOLUTIONS.SETTINGS.WIDTH . "h" . GUI_RESOLUTIONS.SETTINGS.HEIGHT)
}

OpenRepo(*) {
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

; Define a function to send key press, hold, and release
SendKeyWithDelay(key, holdTime, releaseTime) {
    Send("{" key " down}")
    Sleep(holdTime)
    Send("{" key " up}")
    Sleep(releaseTime)
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
    global isMacroRunning

    if isMacroRunning {
        return false
    }
    isMacroRunning := true
    SetRunMacroDependencies(false)

    result := macroFunc(triggerSource)

    isMacroRunning := false
    SetRunMacroDependencies(true)


    return result
}

/*
Processes a sequence of keystrokes for the game.
Takes a list of keystrokes where each keystroke includes:
- `count`: Number of times the key should be pressed
- `key`: The key to be pressed
- `hold`: Duration to hold the key
- `delay`: Time to wait between key presses

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
        MyGui.Minimize()
        WinActivate("ahk_id " ThisGtaWindowID)
        Sleep(KeyDelay * 5)
        if not WinActive("ahk_id " ThisGtaWindowID) {
            MsgBox(
                "ERROR: Failed to activate GTA V window, aborting process.",
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return false
        }
        ToolTip()
        Sleep(KeyDelay * 10)
    }

    for index, Keystroke in Keystrokes {
        ; Apply default values if not provided in the Keystroke properties.
        Keystroke.count := Keystroke.HasOwnProp("count") ? Keystroke.count : 1
        Keystroke.hold := Keystroke.HasOwnProp("hold") ? Keystroke.hold : KeyHold
        Keystroke.delay := Keystroke.HasOwnProp("delay") ? Keystroke.delay : KeyDelay

        if Keystroke.key == KeyBindings_Map["Interaction_Menu"] {
            Keystroke.delay := KeyDelay * 4
        } else if Keystroke.key == "Enter" {
            Keystroke.delay := KeyDelay * 2
        }

        loop Keystroke.count {
            if not GetValidGTAwinRunning({ hwnd: ThisGtaWindowID, AndActive: true }) {
                MsgBox(
                    "ERROR: GTA V window is no longer active, aborting process.",
                    SCRIPT_TITLE,
                    "OK Icon! " . MSGBOX_SYSTEM_MODAL
                )
                return false
            }

            ; Forces default delay for the last Keystroke
            if (A_Index == Keystroke.count and index == Keystrokes.Length) {
                Keystroke.delay := KeyDelay
            }

            if CheckUserInputStopConditions() {
                return false
            }

            SendKeyWithDelay(Keystroke.key, Keystroke.hold, Keystroke.delay)
        }
    }

    return true
}

DropBST(triggerSource) {
    BST_Keystrokes := [
        { key: KeyBindings_Map["Interaction_Menu"] }, ; in [Interaction Menu]
        { key: "Enter" }, ; in [SecuroServ CEO]
        { key: "Down", count: 4 }, ; hover [CEO Abilities]
        { key: "Enter" }, ; in [CEO Abilities]
        { key: "Down" }, ; hover [Drop Bull Shark]
        { key: "Enter" } ; select [Drop Bull Shark]
    ]

    return ProcessGTAKeystrokes(triggerSource, BST_Keystrokes)
}

ReloadAllWeapons(triggerSource) {
    Reload_Keystrokes := []

    Reload_Keystrokes.Push(
        { key: KeyBindings_Map["Interaction_Menu"] }, ; in [Interaction Menu]
        { key: "Down", count: 4 }, ; hover [Health and Ammo]
        { key: "Enter", count: 2 } ; in [Health and Ammo] and [Ammo]
    )

    if ReloadAllWeapons_Heavy_Weapon__Radio.Value {
        Reload_Keystrokes.Push(
            { key: "Enter" }, ; hover [Ammo Type < All >]
            { key: "Up" }, ; hover [Full Ammo $x]
            { key: "Enter" } ; select [Full Ammo $x]
        )
    } else {
        NumOfWeaponTypesToIterate := EditReloadAllWeapons

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
                    { key: "Left" } ; hover [Ammo Type < y >]
                )
            }
        }
    }

    Reload_Keystrokes.Push({ key: KeyBindings_Map["Interaction_Menu"] }) ; exit [Interaction Menu]

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
        { key: KeyBindings_Map["Interaction_Menu"] }, ; in [Interaction Menu]
        { key: "Down", count: 5 }, ; hover [Appearance]
        { key: "Enter" }, ; select [Appearance]
        { key: "Down" }, ; hover [Accessories]
        { key: "Enter" }, ; select [Accessories]
        { key: "Down", count: 4 }, ; hover [Helmets]
        { key: "Space" }, ; select [Helmets]
        { key: KeyBindings_Map["Interaction_Menu"] } ; exit [Interaction Menu]
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
        "HotkeyBST", {
            Hotkey: Hotkeys_Map["HotkeyBST"],
            DefaultHotkey: DEFAULT_HOTKEY_BST,
            Button: DropBST_Button,
            HotkeyEdit: HotkeyBST_HotkeyEdit,
            ApplyButton: HotkeyBST_ApplyButton,
            ResetButton: HotkeyBST_ResetButton,
            ToggleButton: HotkeyBST_ToggleButton,
            MacroFunc: DropBST
        },
        "HotkeyReload", {
            Hotkey: Hotkeys_Map["HotkeyReload"],
            DefaultHotkey: DEFAULT_HOTKEY_RELOAD,
            Button: ReloadAllWeapons_Button,
            HotkeyEdit: HotkeyReload_HotkeyEdit,
            ApplyButton: HotkeyReload_ApplyButton,
            ResetButton: HotkeyReload_ResetButton,
            ToggleButton: HotkeyReload_ToggleButton,
            MacroFunc: ReloadAllWeapons
        },
        "HotkeySpamRespawn", {
            Hotkey: Hotkeys_Map["HotkeySpamRespawn"],
            DefaultHotkey: DEFAULT_HOTKEY_SPAMRESPAWN,
            Button: SpamRespawn_Button,
            HotkeyEdit: HotkeySpamRespawn_HotkeyEdit,
            ApplyButton: HotkeySpamRespawn_ApplyButton,
            ResetButton: HotkeySpamRespawn_ResetButton,
            ToggleButton: HotkeySpamRespawn_ToggleButton,
            MacroFunc: SpamRespawn
        },
        "HotkeyThermalVision", {
            Hotkey: Hotkeys_Map["HotkeyThermalVision"],
            DefaultHotkey: DEFAULT_HOTKEY_THERMALVISION,
            Button: ThermalVision_Button,
            HotkeyEdit: HotkeyThermalVision_HotkeyEdit,
            ApplyButton: HotkeyThermalVision_ApplyButton,
            ResetButton: HotkeyThermalVision_ResetButton,
            ToggleButton: HotkeyThermalVision_ToggleButton,
            MacroFunc: ThermalVision
        },
        "HotkeySuspendGame", {
            Hotkey: Hotkeys_Map["HotkeySuspendGame"],
            DefaultHotkey: DEFAULT_HOTKEY_SUSPENDGAME,
            Button: SuspendGame_Button,
            HotkeyEdit: HotkeySuspendGame_HotkeyEdit,
            ApplyButton: HotkeySuspendGame_ApplyButton,
            ResetButton: HotkeySuspendGame_ResetButton,
            ToggleButton: HotkeySuspendGame_ToggleButton,
            MacroFunc: SuspendGame
        },
        "HotkeyTerminateGame", {
            Hotkey: Hotkeys_Map["HotkeyTerminateGame"],
            DefaultHotkey: DEFAULT_HOTKEY_TERMINATEGAME,
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
    Hotkeys_Map[HotkeyToRemove] := false
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
    Hotkeys_Map[HotkeyToApply] := HotkeyObjects_Map.HotkeyEdit.Value

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
    Hotkeys_Map[HotkeyToReset] := HotkeyObjects_Map.DefaultHotkey
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

UpdateTrayMenuShowHideOptionState(MyGui) {
    if WinExist(SCRIPT_WINDOW_IDENTIFIER) {
        ItemName := "Hide"
        ActionFunc := (*) => HideGui(MyGui)
        RenameFrom := "Show"
    } else {
        ItemName := "Show"
        ActionFunc := (*) => ShowGui(MyGui)
        RenameFrom := "Hide"
    }

    try {
        A_TrayMenu.Rename(RenameFrom, ItemName)
    } catch error as err {
        if not ((err.What == "Menu.Prototype.Rename") and (err.Message == "Nonexistent menu item.")) {
            throw err
        }
    } else {
        A_TrayMenu.Add(ItemName, ActionFunc)
    } finally {
        A_TrayMenu.Default := ItemName
    }
}

IsGTARunning_Callback() {
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
}

ReloadAllWeapons_Edit__DisplayErrorAndReset(GuiCtrlObj) {
    SetRunMacroDependencies(false)
    MsgBox(
        "Error: The value must be a number between 1 and 10.",
        SETTINGS_SCRIPT_TITLE,
        "OK Icon! " . MSGBOX_SYSTEM_MODAL
    )
    GuiCtrlObj.Value := EditReloadAllWeapons
    SetRunMacroDependencies(true)
}

ReloadAllWeapons_Edit_Change__Callback(GuiCtrlObj, Info) {
    Value := GuiCtrlObj.Value

    if Value == "" {
        return false
    }

    if !IsInteger(Value) or (Value < 1 or Value > 10) {
        ReloadAllWeapons_Edit__DisplayErrorAndReset(GuiCtrlObj)
        return false
    }

    global EditReloadAllWeapons
    EditReloadAllWeapons := Value

    return true
}

ReloadAllWeapons_Edit_LoseFocus__Callback(GuiCtrlObj, Info) {
    Value := GuiCtrlObj.Value

    if Value == "" {
        ReloadAllWeapons_Edit__DisplayErrorAndReset(GuiCtrlObj)
        return false
    }
    return true
}


; Start Main GUI
MyGui := Gui()
MyGui.Opt("+AlwaysOnTop")
MyGui.Title := SCRIPT_TITLE

; Oh please do not ask me what the fuck I've done with x and y I just tried to make it works and it does.
Speed_Text := MyGui.AddText("y+10 w108", GenerateMacroSpeedText(KEY_DELAY_DEFAULT)) ; here keeping w108 is important to keep (e.g., a 3-digit number like 100) showing up correctly.
MyGui.AddText("xm x32 y35", "[" . KEY_DELAY_SLOWEST . "ms]")
Speed_Slider := MyGui.AddSlider("yp y30 w200", KEY_DELAY_SLOWEST - KEY_DELAY_DEFAULT + 20)
Speed_Slider.Opt("Invert")
Speed_Slider.Opt("Line10")
Speed_Slider.Opt("Page25")
Speed_Slider.Opt("Range" . KEY_DELAY_FASTEST . "-" . KEY_DELAY_SLOWEST)
Speed_Slider.Opt("Thick30")
Speed_Slider.Opt("TickInterval10")
Speed_Slider.Opt("ToolTip")
Speed_Slider.OnEvent("Change", UpdateMacroSpeed)
MyGui.AddText("yp y35", "[" . KEY_DELAY_FASTEST . "ms]")
; Dev-Note: alternative code --> https://discord.com/channels/288498150145261568/866440127320817684/1288240872630259815

AddSeparator(MyGui, {text1: "x10"})

DropBST_Button := MyGui.AddButton("Disabled", "Drop BST*")
DropBST_Button.OnEvent("Click", (*) => RunMacro(DropBST, "Button"))
DropBST_Button.ToolTip := "*Ensure you are in a CEO Organization."
ReloadAllWeapons_Button := MyGui.AddButton("Disabled x+10", "Reload All Weapons*")
ReloadAllWeapons_Button.OnEvent("Click", (*) => RunMacro(ReloadAllWeapons, "Button"))
ReloadAllWeapons_Button.ToolTip := "*You can adjust the number of weapon type iterations in the Settings."
SpamRespawn_Button := MyGui.AddButton("Disabled x+10", "Spam Respawn*")
SpamRespawn_Button.OnEvent("Click", (*) => RunMacro(SpamRespawn, "Button"))
SpamRespawn_Button.ToolTip := "*Use this on the death screen after being killed to speed up your respawn time."
ThermalVision_Button := MyGui.AddButton("Disabled x10", "Thermal Vision*")
ThermalVision_Button.OnEvent("Click", (*) => RunMacro(ThermalVision, "Button"))
ThermalVision_Button.ToolTip := "*Toogles your Thermal Vision ON/OFF.`nYou must wear a thermal helmet with the visor in the down position.`n`nPlease note that there is a game bug where the helmet doesn't appear in the 'Interaction Menu' > 'Accessories'.`nYou will need to resolve this issue on your own."

MyGui.AddText("x10")

SuspendGame_Button := MyGui.AddButton("Disabled", "Suspend Game*")
SuspendGame_Button.OnEvent("Click", (*) => RunMacro(SuspendGame, "Button"))
SuspendGame_Button.ToolTip := "*You can use this to force yourself into a solo public session.`nThis is especially useful when making risky sales in public lobbies."
TerminateGame_Button := MyGui.AddButton("Disabled x+0", "Terminate Game*")
TerminateGame_Button.OnEvent("Click", (*) => RunMacro(TerminateGame, "Button"))
TerminateGame_Button.ToolTip := "*You can use this to select the Casino Lucky Wheel slot you want.`nIf it doesn't match your choice, close the game and try again as many times as needed."

AddSeparator(MyGui, {text1: "x10"})

Settings_Button := MyGui.AddButton("Disabled x+0", "Settings")
Settings_Button.OnEvent("Click", OpenSettings)

OpenRepo_Button := MyGui.AddButton("Disabled x+0", "Open Repository")
OpenRepo_Button.OnEvent("Click", OpenRepo)

Updater_Button := MyGui.AddButton("Disabled x+0", "Check For Updates")
Updater_Button.OnEvent("Click", (*) => RunUpdater("MANUAL"))
; END Main GUI

; START Settings GUI
MySettingsGui := Gui()
MySettingsGui.Opt("+AlwaysOnTop")
MySettingsGui.Title := SETTINGS_SCRIPT_TITLE

ReloadAllWeapons_Iterate_All__Radio := MySettingsGui.AddRadio("Checked", " Reload All Weapons (Method: Iterate All)")
ReloadAllWeapons_Heavy_Weapon__Radio := MySettingsGui.AddRadio(, " Reload All Weapons (Method: Heavy Weapon)")
ReloadAllWeapons_Text := MySettingsGui.AddText("y50", 'Number of iterations for "Reload All Weapons" (Method: Iterate All) :')
ReloadAllWeapons_Edit := MySettingsGui.AddEdit("w40")
ReloadAllWeapons_Edit.OnEvent("Change", ReloadAllWeapons_Edit_Change__Callback)
ReloadAllWeapons_Edit.OnEvent("LoseFocus", ReloadAllWeapons_Edit_LoseFocus__Callback)
ReloadAllWeapons_UpDown := MySettingsGui.AddUpDown("Range1-10", DEFAULT_EDIT_RELOAD_All_WEAPONS)

AddSeparator(MySettingsGui, {text1: "x10"})

ApplyKeyBinding(KeyBindingToApply) {
    KeyBind := KeyBinding_Interaction_Menu__HotkeyEdit.Value

    if GetKeySC(KeyBind) {
        KeyBindings_Map[KeyBindingToApply] := KeyBind
        return true
    }

    MsgBox(
        "Error: Invalid key name.",
        SCRIPT_TITLE,
        "OK Icon! " . MSGBOX_SYSTEM_MODAL
    )
    KeyBinding_Interaction_Menu__HotkeyEdit.Value := KeyBindings_Map[KeyBindingToApply]
    return false
}

ResetKeyBinding(KeyBindingToReset) {
    KeyBinding_Interaction_Menu__HotkeyEdit.Value := DEFAULT_KEY_BINDING__INTERACTION_MENU
    KeyBindings_Map[KeyBindingToReset] := DEFAULT_KEY_BINDING__INTERACTION_MENU
}

MySettingsGui.AddText(, 'In-game key binding for "Interaction Menu" :')
KeyBinding_Interaction_Menu__HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", KeyBindings_Map["Interaction_Menu"])
KeyBinding_Interaction_Menu__HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(KeyBinding_Interaction_Menu__ApplyButton))
KeyBinding_Interaction_Menu__HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(KeyBinding_Interaction_Menu__HotkeyEdit, KeyBinding_Interaction_Menu__ApplyButton, KeyBindings_Map["Interaction_Menu"]))
KeyBinding_Interaction_Menu__ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
KeyBinding_Interaction_Menu__ApplyButton.OnEvent("Click", (*) => ApplyKeyBinding("Interaction_Menu"))
KeyBinding_Interaction_Menu__ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
KeyBinding_Interaction_Menu__ResetButton.OnEvent("Click", (*) => ResetKeyBinding("Interaction_Menu"))

AddSeparator(MySettingsGui, {text1: "x10"})

MySettingsGui.AddText(, 'Hotkey for "Drop BST" :')
HotkeyBST_HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_BST)
HotkeyBST_HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeyBST_ApplyButton))
HotkeyBST_HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeyBST_HotkeyEdit, HotkeyBST_ApplyButton, Hotkeys_Map["HotkeyBST"]))
HotkeyBST_ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
HotkeyBST_ApplyButton.OnEvent("Click", (*) => ApplyHotkey("HotkeyBST"))
HotkeyBST_ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
HotkeyBST_ResetButton.OnEvent("Click", (*) => ResetHotkey("HotkeyBST"))
HotkeyBST_ToggleButton := MySettingsGui.AddButton("w66 x+10", "Disable")
HotkeyBST_ToggleButton.OnEvent("Click", (*) => ToggleHotkey("HotkeyBST"))
MySettingsGui.AddText("x10", 'Hotkey for "Reload All Weapons" :')
HotkeyReload_HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_RELOAD)
HotkeyReload_HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeyReload_ApplyButton))
HotkeyReload_HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeyReload_HotkeyEdit, HotkeyReload_ApplyButton, Hotkeys_Map["HotkeyReload"]))
HotkeyReload_ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
HotkeyReload_ApplyButton.OnEvent("Click", (*) => ApplyHotkey("HotkeyReload"))
HotkeyReload_ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
HotkeyReload_ResetButton.OnEvent("Click", (*) => ResetHotkey("HotkeyReload"))
HotkeyReload_ToggleButton := MySettingsGui.AddButton("w66 x+10", "Disable")
HotkeyReload_ToggleButton.OnEvent("Click", (*) => ToggleHotkey("HotkeyReload"))
MySettingsGui.AddText("x10", 'Hotkey for "Spam Respawn" :')
HotkeySpamRespawn_HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_SPAMRESPAWN)
HotkeySpamRespawn_HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeySpamRespawn_ApplyButton))
HotkeySpamRespawn_HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeySpamRespawn_HotkeyEdit, HotkeySpamRespawn_ApplyButton, Hotkeys_Map["HotkeySpamRespawn"]))
HotkeySpamRespawn_ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
HotkeySpamRespawn_ApplyButton.OnEvent("Click", (*) => ApplyHotkey("HotkeySpamRespawn"))
HotkeySpamRespawn_ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
HotkeySpamRespawn_ResetButton.OnEvent("Click", (*) => ResetHotkey("HotkeySpamRespawn"))
HotkeySpamRespawn_ToggleButton := MySettingsGui.AddButton("w66 x+10", "Disable")
HotkeySpamRespawn_ToggleButton.OnEvent("Click", (*) => ToggleHotkey("HotkeySpamRespawn"))
MySettingsGui.AddText("x10", 'Hotkey for "Thermal Vision" :')
HotkeyThermalVision_HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_THERMALVISION)
HotkeyThermalVision_HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeyThermalVision_ApplyButton))
HotkeyThermalVision_HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeyThermalVision_HotkeyEdit, HotkeyThermalVision_ApplyButton, Hotkeys_Map["HotkeyThermalVision"]))
HotkeyThermalVision_ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
HotkeyThermalVision_ApplyButton.OnEvent("Click", (*) => ApplyHotkey("HotkeyThermalVision"))
HotkeyThermalVision_ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
HotkeyThermalVision_ResetButton.OnEvent("Click", (*) => ResetHotkey("HotkeyThermalVision"))
HotkeyThermalVision_ToggleButton := MySettingsGui.AddButton("w66 x+10", "Disable")
HotkeyThermalVision_ToggleButton.OnEvent("Click", (*) => ToggleHotkey("HotkeyThermalVision"))
MySettingsGui.AddText("x10", 'Hotkey for "Suspend Game" :')
HotkeySuspendGame_HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_SUSPENDGAME)
HotkeySuspendGame_HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeySuspendGame_ApplyButton))
HotkeySuspendGame_HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeySuspendGame_HotkeyEdit, HotkeySuspendGame_ApplyButton, Hotkeys_Map["HotkeySuspendGame"]))
HotkeySuspendGame_HotkeyEdit.Enabled := false
HotkeySuspendGame_ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
HotkeySuspendGame_ApplyButton.OnEvent("Click", (*) => ApplyHotkey("HotkeySuspendGame"))
HotkeySuspendGame_ApplyButton.Enabled := false
HotkeySuspendGame_ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
HotkeySuspendGame_ResetButton.OnEvent("Click", (*) => ResetHotkey("HotkeySuspendGame"))
HotkeySuspendGame_ResetButton.Enabled := false
HotkeySuspendGame_ToggleButton := MySettingsGui.AddButton("w66 x+10", "Enable")
HotkeySuspendGame_ToggleButton.OnEvent("Click", (*) => ToggleHotkey("HotkeySuspendGame"))
MySettingsGui.AddText("x10", 'Hotkey for "Terminate Game" :')
HotkeyTerminateGame_HotkeyEdit := MySettingsGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_TERMINATEGAME)
HotkeyTerminateGame_HotkeyEdit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeyTerminateGame_ApplyButton))
HotkeyTerminateGame_HotkeyEdit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeyTerminateGame_HotkeyEdit, HotkeyTerminateGame_ApplyButton, Hotkeys_Map["HotkeyTerminateGame"]))
HotkeyTerminateGame_HotkeyEdit.Enabled := false
HotkeyTerminateGame_ApplyButton := MySettingsGui.AddButton("w66 x+10", "Apply")
HotkeyTerminateGame_ApplyButton.OnEvent("Click", (*) => ApplyHotkey("HotkeyTerminateGame"))
HotkeyTerminateGame_ApplyButton.Enabled := false
HotkeyTerminateGame_ResetButton := MySettingsGui.AddButton("w66 x+10", "Reset")
HotkeyTerminateGame_ResetButton.OnEvent("Click", (*) => ResetHotkey("HotkeyTerminateGame"))
HotkeyTerminateGame_ResetButton.Enabled := false
HotkeyTerminateGame_ToggleButton := MySettingsGui.AddButton("w66 x+10", "Enable")
HotkeyTerminateGame_ToggleButton.OnEvent("Click", (*) => ToggleHotkey("HotkeyTerminateGame"))
HotkeysHelp_Link := MySettingsGui.AddLink("x10", 'Full list of possible Hotkeys:`n<a id="KeyListHelp" href="https://www.autohotkey.com/docs/v2/KeyList.htm">https://www.autohotkey.com/docs/v2/KeyList.htm</a>')
HotkeysHelp_Link.OnEvent("Click", Link_Click)
; END Settings GUI

Hotkey(Hotkeys_Map["HotkeyBST"], (*) => RunMacro(DropBST, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeyReload"], (*) => RunMacro(ReloadAllWeapons, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeySpamRespawn"], (*) => RunMacro(SpamRespawn, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeyThermalVision"], (*) => RunMacro(ThermalVision, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeySuspendGame"], (*) => RunMacro(SuspendGame, "Hotkey"), "Off")
Hotkey(Hotkeys_Map["HotkeyTerminateGame"], (*) => RunMacro(TerminateGame, "Hotkey"), "Off")

MyGui.Show("w" . GUI_RESOLUTIONS.MAIN.WIDTH . "h" . GUI_RESOLUTIONS.MAIN.HEIGHT)

CenterElement(MyGui, Speed_Text)
CenterElement(MyGui, Speed_Slider)
CenterElements(MyGui,, DropBST_Button, ReloadAllWeapons_Button, SpamRespawn_Button)
CenterElement(MyGui, ThermalVision_Button)
CenterElements(MyGui,, SuspendGame_Button, TerminateGame_Button)
CenterElements(MyGui, 0, ReloadAllWeapons_Edit, ReloadAllWeapons_UpDown)
CenterElements(MyGui, 20, Settings_Button, OpenRepo_Button, Updater_Button)

CenterElement(MyGui, ReloadAllWeapons_Text)

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
OnMessage(0x020A, On_WM_MOUSEWHEEL)

A_TrayMenu.Insert("1&", "Hide", (*) => HideGui(MyGui))
A_TrayMenu.Insert("2&")

RunUpdater("STARTUP")

SetTimer(() => UpdateTrayMenuShowHideOptionState(MyGui), 100)

/*
HotIfWinActive(GTA_WINDOW_IDENTIFIER)
Known-Bug: After restarting the game this method ain't working anymore.
So I fixed it by implementing my own one just below.
*/
SetTimer(IsGTARunning_Callback, 100) ; Only enable Hotkeys when the GTA_WINDOW_IDENTIFIER conditions are found.
