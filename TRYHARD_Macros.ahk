#Requires AutoHotkey v2.0
#SingleInstance Force


; Constants
DEBUG_ENABLED := false

SCRIPT_TITLE := "TRYHARD Macros"
UPDATER_SCRIPT_TITLE := "Updater - " . SCRIPT_TITLE
SCRIPT_VERSION := "v1.1.0 - 26/09/2024 (21:28)"
SCRIPT_UPDATER_API_URL := "https://api.github.com/repos/Illegal-Services/TRYHARD_GTA_Macros/releases/latest"
SCRIPT_WINDOW_IDENTIFIER := SCRIPT_TITLE . " ahk_class " . "AutoHotkeyGUI" . " ahk_pid " . WinGetPID(A_ScriptHwnd)
GTA_WINDOW_IDENTIFIER := "Grand Theft Auto V ahk_class grcWindow ahk_exe GTA5.exe"
USER_INPUT__CURRENTLY_PLAYING_MACRO__STOPPING_KEYS := ["LButton", "RButton", "Enter", "Escape", "Backspace"]
MSGBOX_SYSTEM_MODAL := 4096
CENTER_ADJUSTMENT_PIXELS := 7

DEFAULT_HOTKEY_BST := "F1"
DEFAULT_HOTKEY_RELOAD := "F2"
DEFAULT_HOTKEY_SPAMRESPAWN := "F3"

TOOLTIP_DISPLAY_TIME := 250
TOOLTIP_HIDE_TIME := 5000

KEY_DELAY_SLOWEST := 100
KEY_DELAY_FASTEST := 10
KEY_DELAY_DEFAULT := 40

; Globals
HotkeyBST := DEFAULT_HOTKEY_BST
HotkeyReload := DEFAULT_HOTKEY_RELOAD
HotkeySpamRespawn := DEFAULT_HOTKEY_SPAMRESPAWN
CurrentDefaultButton := false
KeyHold := KEY_DELAY_DEFAULT
KeyDelay := KEY_DELAY_DEFAULT
IsMacroRunning := false


SetTitleMatchMode(3) ; Exact match mode

On_WM_KEYDOWN(wParam, lParam, msg, Hwnd) {
    if (wParam == 0x0D) { ; 0x0D is the virtual key code for the Enter key
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        ; Simulate click on active (Default) "Apply" button when editing an Edit field and pressing ENTER.
        if (RegexMatch(CurrControl.ClassNN, "^Edit\d+$") and (CurrentDefaultButton.Text == "Apply")) {
            ControlClick(CurrentDefaultButton)
            ControlFocus(CurrControl)
        }
    }
}

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
CenterElements(gui, elements*) {
    spacing := 10

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
    Speed_Slider.Enabled := false
    if (UpdatedSliderValue <= 10) {
        MsgBox(
            "Legend said, only NASA computers can run this!",
            SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
    } else if (UpdatedSliderValue <= 20) {
        MsgBox(
            "This method is only recommended in invite-only sessions with a very limited number of players and a high-performance CPU and GPU; even then, consistent results are not even guaranteed.",
            SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
    } else if (UpdatedSliderValue <= 30) {
        MsgBox(
            "This method is only recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise.",
            SCRIPT_TITLE,
            "OK Iconi " . MSGBOX_SYSTEM_MODAL
        )
    }
    Speed_Slider.Enabled := true

    KeyDelay := UpdatedSliderValue
    KeyHold := UpdatedSliderValue
}

OpenRepo(*) {
    Run("https://github.com/Illegal-Services/TRYHARD_GTA_Macros")
}

Updater(Source) {
    FormatTimestampToAHK(Timestamp, TimestampSource) {
        if TimestampSource == "SCRIPT_VERSION" {
            if RegExMatch(Timestamp, "(\d{2})/(\d{2})/(\d{4}) \((\d{2}):(\d{2})\)", &matches) {
                return matches[3] . matches[2] . matches[1] . matches[4] . matches[5] ; . "00"
            }
        } else if TimestampSource == "GitHub" {
            if RegExMatch(Timestamp, "(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z", &matches) {
                return matches[1] . matches[2] . matches[3] . matches[4] . matches[5] . matches[6]
            }
        }

        throw Error("Invalid timestamp format.")
    }

    GetLatestReleaseInfo() {
        try {
            Response := WebRequest("GET", SCRIPT_UPDATER_API_URL)

            if Response.Status == 200 {
                DownloadUrl := RegExMatch(Response.Text, '"html_url"\s*:\s*"(https:\/\/github\.com\/Illegal-Services\/TRYHARD_GTA_Macros\/releases\/tag\/[^"]+)', &urlMatch) ? urlMatch[1] : ""
                LatestVersion := RegExMatch(Response.Text, '"tag_name"\s*:\s*"([^"]+)"', &VersionMatch) ? VersionMatch[1] : ""
                ReleaseDate := RegExMatch(Response.Text, '"published_at"\s*:\s*"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)"', &DateMatch) ? FormatTimestampToAHK(DateMatch[1], "GitHub") : ""

                return { LatestVersion: LatestVersion, ReleaseDate: ReleaseDate, DownloadUrl: DownloadUrl }
            }
        }

        throw Error("Error: Failed fetching release info.")
    }


    AHKscriptVersion := FormatTimestampToAHK(SCRIPT_VERSION, "SCRIPT_VERSION")

    try {
        LatestRelease := GetLatestReleaseInfo()
    } catch error as err {
        if (err.Message == "Error: Failed fetching release info.") {
            MsgBox(
                "Error: Failed fetching release info.",
                UPDATER_SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
        } else {
            throw err
        }
    } else {
        if DateDiff(LatestRelease.releaseDate, AHKscriptVersion, "Seconds") > 0 {
            MsgBox_Text := "New version found. Do you want to update ?`n`n"
            MsgBox_Text .= "Current Version: " . SCRIPT_VERSION . "`n"
            MsgBox_Text .= "Latest Version: " . LatestRelease.LatestVersion . " - " . FormatTime(LatestRelease.ReleaseDate, "dd/MM/yyyy (HH:mm)")
            MsgBox_Result := MsgBox(
                MsgBox_Text,
                UPDATER_SCRIPT_TITLE,
                "YesNo Iconi " . MSGBOX_SYSTEM_MODAL
            )
            if MsgBox_Result == "Yes" {
                Run(LatestRelease.DownloadUrl)
            }
        } else {
            if Source == "MANUAL_CHECK" {
                MsgBox_Text := "You are up-to-date :)`n`n"
                MsgBox_Text .= "Current Version: " . SCRIPT_VERSION . "`n"
                MsgBox_Text .= "Latest Version: " . LatestRelease.LatestVersion . " - " . FormatTime(LatestRelease.ReleaseDate, "dd/MM/yyyy (HH:mm)") . "`n"
                MsgBox(
                    MsgBox_Text,
                    UPDATER_SCRIPT_TITLE,
                    "Ok Iconi " . MSGBOX_SYSTEM_MODAL
                )
            }
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

IsValidGTAwinRunning(Options := {}) {
    ; Get the HWND of the first window matching GTA_WINDOW_IDENTIFIER or uses the one supplied from user.
    gtaWindowID := Options.HasOwnProp("hwnd") ? Options.hwnd : ""
    CheckIsActive := Options.HasOwnProp("AndActive") ? Options.AndActive : ""

    if gtaWindowID == "" {
        if not WinExist(GTA_WINDOW_IDENTIFIER) {
            return false
        }
    } else {
        if (gtaWindowID == 0) or (not WinExist(GTA_WINDOW_IDENTIFIER . " ahk_id " . gtaWindowID)) {
            return false
        }
    }

    if not CheckIsActive == "" {
        if CheckIsActive == WinActive("ahk_id " gtaWindowID) {
            return false
        }
    }

    return true
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


    ; Get the HWND of the first window matching GTA_WINDOW_IDENTIFIER
    gtaWindowID := WinExist(GTA_WINDOW_IDENTIFIER)

    if not IsValidGTAwinRunning({ hwnd: gtaWindowID }) {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        return false
    }

    if triggerSource == "Button" and not WinActive("ahk_id " gtaWindowID) {
        MyGui.Minimize()
        WinActivate("ahk_id " gtaWindowID)
        Sleep(KeyDelay * 5)
        if not WinActive("ahk_id " gtaWindowID) {
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
        ; Apply default count, hold and delay values if not provided in the Keystroke properties.
        Keystroke.count := Keystroke.HasOwnProp("count") ? Keystroke.count : 1
        Keystroke.hold := Keystroke.HasOwnProp("hold") ? Keystroke.hold : KeyHold
        Keystroke.delay := Keystroke.HasOwnProp("delay") ? Keystroke.delay : KeyDelay

        loop Keystroke.count {
            if not IsValidGTAwinRunning({ hwnd: gtaWindowID, AndActive: true }) {
                MsgBox(
                    'ERROR: GTA V window is no longer active, aborting process.',
                    SCRIPT_TITLE,
                    "OK Icon! " . MSGBOX_SYSTEM_MODAL
                )
                return false
            }

            ; Set delay to 0 for the last Keystroke
            if ((A_Index == Keystroke.count) and (index == Keystrokes.Length)) {
                Keystroke.delay := 0
            }

            if CheckUserInputStopConditions() {
                return false
            }

            SendKeyWithDelay(Keystroke.key, Keystroke.hold, Keystroke.delay)
        }
    }

    return true
}

RunMacro(macroFunc, triggerSource) {
    global isMacroRunning

    if isMacroRunning {
        return false
    }
    isMacroRunning := true

    result := macroFunc(triggerSource)

    isMacroRunning := false
    return result
}

DropBST(triggerSource) {
    BST_Keystrokes := [
        { key: ",", delay: KeyDelay * 6 }, ; in [Interaction Menu]
        { key: "Enter", delay: KeyDelay * 2 }, ; in [SecuroServ CEO]
        { key: "Down", count: 4 }, ; hover [CEO Abilities]
        { key: "Enter", delay: KeyDelay * 2 }, ; in [CEO Abilities]
        { key: "Down" }, ; hover [Drop Bull Shark]
        { key: "Enter" } ; select [Drop Bull Shark]
    ]

    return ProcessGTAKeystrokes(triggerSource, BST_Keystrokes)
}

ReloadAllWeapons(triggerSource) {
    Reload_Keystrokes := []

    Reload_Keystrokes.Push(
        { key: ",", delay: KeyDelay * 6 }, ; in [Interaction Menu]
        { key: "Down", count: 4 }, ; hover [Health and Ammo]
        { key: "Enter", count: 2, delay: KeyDelay * 2 } ; in [Health and Ammo] and [Ammo]
    )

    if (ReloadAllWeapons_CheckBox.Value == 1) {
        static NumOfWeaponTypesToIterate := 9

        ; Iterate through each [Ammo Type] and select the [Full Ammo $x] option for each
        Loop NumOfWeaponTypesToIterate {
            Reload_Keystrokes.Push(
                { key: "Up" }, ; hover [Full Ammo $x]
                { key: "Enter", delay: KeyDelay * 2 } ; select [Full Ammo $x]
            )

            ; Only add "Down" and "Left" if it's not the last iteration
            if (A_Index < NumOfWeaponTypesToIterate) {
                Reload_Keystrokes.Push(
                    { key: "Down" }, ; hover [Ammo Type < x >]
                    { key: "Left" } ; hover [Ammo Type < y >]
                )
            }
        }
    } else {
        Reload_Keystrokes.Push(
            { key: "Left" }, ; hover [Ammo Type < All >]
            { key: "Up" }, ; hover [Full Ammo $x]
            { key: "Enter", delay: KeyDelay * 2 } ; select [Full Ammo $x]
        )
    }

    ; exit [Interaction Menu]
    Reload_Keystrokes.Push({ key: "," })

    return ProcessGTAKeystrokes(triggerSource, Reload_Keystrokes)
}

SpamRespawn(triggerSource) {
    SpamRespawn_Keystrokes := [
        { key: "LButton", count: 20 } ; select [Respawn]
    ]

    return ProcessGTAKeystrokes(triggerSource, SpamRespawn_Keystrokes)
}

RemoveHotkey(HotkeyToRemove) {
    if (HotkeyToRemove == "HotkeyBST") {
        global HotkeyBST
        if not (HotkeyBST == false) {
            Hotkey(HotkeyBST, "Off")
        }
        HotkeyBST := false
        HotkeyBST_Edit.Value := ""
    } else if (HotkeyToRemove == "HotkeyReload") {
        global HotkeyReload
        if not (HotkeyBST == false) {
            Hotkey(HotkeyBST, "Off")
        }
        HotkeyReload := false
        HotkeyReload_Edit.Value := ""
    } else if (HotkeyToRemove == "HotkeySpamRespawn") {
        global HotkeySpamRespawn
        if not (HotkeyBST == false) {
            Hotkey(HotkeyBST, "Off")
        }
        HotkeySpamRespawn := false
        HotkeySpamRespawn_Edit.Value := ""
    }
}

ApplyHotkeyBST(*) {
    global HotkeyBST

    if (HotkeyBST == false) {
        return true
    }

    if InArray(HotkeyBST_Edit.Value, [HotkeyReload, HotkeySpamRespawn]) {
        MsgBox(
            "Error: You cannot assign a hotkey to more than one macro.",
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        HotkeyBST_Edit.Value := HotkeyBST
        return false
    }

    Hotkey(HotkeyBST, "Off")

    if (HotkeyBST_Edit.Value == "") {
        RemoveHotkey("HotkeyBST")
        return true
    }

    try {
        Hotkey(HotkeyBST_Edit.Value, (*) => RunMacro(DropBST, "Hotkey"))
    } catch error as err {
        if ((err.what == "Hotkey") and ((err.message == "Invalid key name.") or (err.message == "Invalid hotkey."))) {
            MsgBox(
                "Error: " . err.message,
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            Hotkey(HotkeyBST, (*) => RunMacro(DropBST, "Hotkey"))
            Hotkey(HotkeyBST, "On")
            HotkeyBST_Edit.Value := HotkeyBST
            return false
        }
        throw err
    }

    Hotkey(HotkeyBST_Edit.Value, "On")
    HotkeyBST := HotkeyBST_Edit.Value

    return true
}

ApplyHotkeyReload(*) {
    global HotkeyReload

    if (HotkeyReload == false) {
        return true
    }

    if InArray(HotkeyReload_Edit.Value, [HotkeyBST, HotkeySpamRespawn]) {
        MsgBox(
            "Error: You cannot assign a hotkey to more than one macro.",
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        HotkeyReload_Edit.Value := HotkeyReload
        return false
    }

    Hotkey(HotkeyReload, "Off")

    if (HotkeyReload_Edit.Value == "") {
        RemoveHotkey("HotkeyReload")
        return true
    }

    try {
        Hotkey(HotkeyReload_Edit.Value, (*) => RunMacro(ReloadAllWeapons, "Hotkey"))
    } catch error as err {
        if ((err.what == "Hotkey") and ((err.message == "Invalid key name.") or (err.message == "Invalid hotkey."))) {
            MsgBox(
                "Error: " . err.message,
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            Hotkey(HotkeyReload, (*) => RunMacro(ReloadAllWeapons, "Hotkey"))
            Hotkey(HotkeyReload, "On")
            HotkeyReload_Edit.Value := HotkeyReload
            return false
        }
        throw err
    }

    Hotkey(HotkeyReload_Edit.Value, "On")
    HotkeyReload := HotkeyReload_Edit.Value

    return true
}

ApplyHotkeySpamRespawn(*) {
    global HotkeySpamRespawn

    if (HotkeySpamRespawn == false) {
        return true
    }

    if InArray(HotkeySpamRespawn_Edit.Value, [HotkeyBST, HotkeyReload]) {
        MsgBox(
            "Error: You cannot assign a hotkey to more than one macro.",
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        HotkeySpamRespawn_Edit.Value := HotkeySpamRespawn
        return false
    }

    Hotkey(HotkeySpamRespawn, "Off")

    if (HotkeySpamRespawn_Edit.Value == "") {
        RemoveHotkey("HotkeySpamRespawn")
        return true
    }

    try {
        Hotkey(HotkeySpamRespawn_Edit.Value, (*) => RunMacro(SpamRespawn, "Hotkey"))
    } catch error as err {
        if ((err.what == "Hotkey") and ((err.message == "Invalid key name.") or (err.message == "Invalid hotkey."))) {
            MsgBox(
                "Error: " . err.message,
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            Hotkey(HotkeySpamRespawn, (*) => RunMacro(SpamRespawn, "Hotkey"))
            Hotkey(HotkeySpamRespawn, "On")
            HotkeySpamRespawn_Edit.Value := "F3"
            return false
        }
        throw err
    }

    Hotkey(HotkeySpamRespawn_Edit.Value, "On")
    HotkeySpamRespawn := HotkeySpamRespawn_Edit.Value

    return true
}

ResetHotkey(HotkeyToReset) {
    if (HotkeyToReset == "HotkeyBST") {
        global HotkeyBST
        if not (HotkeyBST == false) {
            Hotkey(HotkeyBST, "Off")
        }
        Hotkey(DEFAULT_HOTKEY_BST, "On")
        HotkeyBST := DEFAULT_HOTKEY_BST
        HotkeyBST_Edit.Value := DEFAULT_HOTKEY_BST
    } else if (HotkeyToReset == "HotkeyReload") {
        global HotkeyReload
        if not (HotkeyReload == false) {
            Hotkey(HotkeyReload, "Off")
        }
        Hotkey(DEFAULT_HOTKEY_RELOAD, "On")
        HotkeyReload := DEFAULT_HOTKEY_RELOAD
        HotkeyReload_Edit.Value := DEFAULT_HOTKEY_RELOAD
    } else if (HotkeyToReset == "HotkeySpamRespawn") {
        global HotkeySpamRespawn
        if not (HotkeySpamRespawn == false) {
            Hotkey(HotkeySpamRespawn, "Off")
        }
        Hotkey(DEFAULT_HOTKEY_SPAMRESPAWN, "On")
        HotkeySpamRespawn := DEFAULT_HOTKEY_SPAMRESPAWN
        HotkeySpamRespawn_Edit.Value := DEFAULT_HOTKEY_SPAMRESPAWN
    }
}

GetHotkeyToggleButtonsMap() {
    Buttons_Map := Map()
    Buttons_Map.Set("HotkeyBST", { ToggleButton: HotkeyBSTToggle_Button, Hotkey: HotkeyBST })
    Buttons_Map.Set("HotkeyReload", { ToggleButton: HotkeyReloadToggle_Button, Hotkey: HotkeyReload })
    Buttons_Map.Set("HotkeySpamRespawn", { ToggleButton: HotkeySpamRespawnToggle_Button, Hotkey: HotkeySpamRespawn })

    return Buttons_Map
}

ToggleHotkey(HotkeyToToggle) {
    Buttons_Map := GetHotkeyToggleButtonsMap()

    if Buttons_Map.Has(HotkeyToToggle) {
        ToggleItem := Buttons_Map[HotkeyToToggle]
        ToggleButton := ToggleItem.ToggleButton
        _Hotkey := ToggleItem.Hotkey

        if (ToggleButton.Text == "Enable") {
            Hotkey(_Hotkey, "On")
            ToggleButton.Text := "Disable"
        } else if (ToggleButton.Text == "Disable") {
            Hotkey(_Hotkey, "Off")
            ToggleButton.Text := "Enable"
        }
    }
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
        if not ((err.what == "Menu.Prototype.Rename") and (err.Message == "Nonexistent menu item.")) {
            throw err
        }
    } else {
        A_TrayMenu.Add(ItemName, ActionFunc)
    } finally {
        A_TrayMenu.Default := ItemName
    }
}

IsGTARunning_Callback() {
    Buttons_Map := GetHotkeyToggleButtonsMap()
    IsGTAwinActive := IsValidGTAwinRunning({ AndActive: true })

    for HotkeyName, Data in Buttons_Map {
        ToggleButton := Data.ToggleButton
        _Hotkey := Data.Hotkey

        if (ToggleButton.Text == "Disable") {
            Hotkey(_Hotkey, IsGTAwinActive ? "On" : "Off")
        }
    }
}


MyGui := Gui()
MyGui.Opt("+AlwaysOnTop")
MyGui.Title := SCRIPT_TITLE

; Oh please do not ask me what the fuck I've done with x and y I just tried to make it works and it does.
Speed_Text := MyGui.AddText("y+10 w108", GenerateMacroSpeedText(KEY_DELAY_DEFAULT)) ; here keeping w108 is important to keep (e.g., a 3-digit number like 100) showing up correctly.
MyGui.AddText("xm x32 y35", "[" . KEY_DELAY_SLOWEST . "ms]")
Speed_Slider := MyGui.AddSlider("yp y30 w200", KEY_DELAY_SLOWEST - KEY_DELAY_DEFAULT + 10)
Speed_Slider.Opt("Invert")
Speed_Slider.Opt("Line10")
Speed_Slider.Opt("Page25")
Speed_Slider.Opt("Range10-100")
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
ReloadAllWeapons_Button.ToolTip := '*If you are NOT using "FIX (slower)", before reloading, fire a single pistol round.'
SpamRespawn_Button := MyGui.AddButton("Disabled x+10", "Spam Respawn*")
SpamRespawn_Button.OnEvent("Click", (*) => RunMacro(SpamRespawn, "Button"))
SpamRespawn_Button.ToolTip := "*Use that when you're dead to spawn faster."

ReloadAllWeapons_CheckBox := MyGui.AddCheckBox("x10", "Reload All Weapons: FIX (slower)")
ReloadAllWeapons_CheckBox.Value := 1

AddSeparator(MyGui)

OnEdit_Focus(ApplyButton) {
    global CurrentDefaultButton

    ApplyButton.Opt("+Default")

    CurrentDefaultButton := ApplyButton
}

OnEdit_LoseFocus(ApplyButton) {
    global CurrentDefaultButton

    ApplyButton.Opt("-Default")

    CurrentDefaultButton := false
}


MyGui.AddText(, 'Hotkey for "Drop BST" :')
HotkeyBST_Edit := MyGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_BST)
HotkeyBST_Edit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeyBST_Button))
HotkeyBST_Edit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeyBST_Button))
HotkeyBST_Button := MyGui.AddButton("w66 x+10", "Apply")
HotkeyBST_Button.OnEvent("LoseFocus", ApplyHotkeyBST)
HotkeyBSTReset_Button := MyGui.AddButton("w66 x+10", "Reset")
HotkeyBSTReset_Button.OnEvent("Click", (*) => ResetHotkey("HotkeyBST"))
HotkeyBSTToggle_Button := MyGui.AddButton("w66 x+10", "Disable")
HotkeyBSTToggle_Button.OnEvent("Click", (*) => ToggleHotkey("HotkeyBST"))
MyGui.AddText("x10", 'Hotkey for "Reload All Weapons" :')
HotkeyReload_Edit := MyGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_RELOAD)
HotkeyReload_Edit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeyReload_Button))
HotkeyReload_Edit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeyReload_Button))
HotkeyReload_Button := MyGui.AddButton("w66 x+10", "Apply")
HotkeyReload_Button.OnEvent("Click", ApplyHotkeyReload)
HotkeyReloadReset_Button := MyGui.AddButton("w66 x+10", "Reset")
HotkeyReloadReset_Button.OnEvent("Click", (*) => ResetHotkey("HotkeyReload"))
HotkeyReloadToggle_Button := MyGui.AddButton("w66 x+10", "Disable")
HotkeyReloadToggle_Button.OnEvent("Click", (*) => ToggleHotkey("HotkeyReload"))
MyGui.AddText("x10", 'Hotkey for "Spam Respawn" :')
HotkeySpamRespawn_Edit := MyGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_SPAMRESPAWN)
HotkeySpamRespawn_Edit.OnEvent("Focus", (*) => OnEdit_Focus(HotkeySpamRespawn_Button))
HotkeySpamRespawn_Edit.OnEvent("LoseFocus", (*) => OnEdit_LoseFocus(HotkeySpamRespawn_Button))
HotkeySpamRespawn_Button := MyGui.AddButton("w66 x+10", "Apply")
HotkeySpamRespawn_Button.OnEvent("Click", ApplyHotkeySpamRespawn)
HotkeySpamRespawnReset_Button := MyGui.AddButton("w66 x+10", "Reset")
HotkeySpamRespawnReset_Button.OnEvent("Click", (*) => ResetHotkey("HotkeySpamRespawn"))
HotkeySpamRespawnToggle_Button := MyGui.AddButton("w66 x+10", "Disable")
HotkeySpamRespawnToggle_Button.OnEvent("Click", (*) => ToggleHotkey("HotkeySpamRespawn"))

HotkeysHelp_Link := MyGui.AddLink("x10", 'Full list of possible Hotkeys:`n<a id="KeyListHelp" href="https://www.autohotkey.com/docs/v2/KeyList.htm">https://www.autohotkey.com/docs/v2/KeyList.htm</a>')
HotkeysHelp_Link.OnEvent("Click", Link_Click)

AddSeparator(MyGui)

Help_Button := MyGui.AddButton("x+70", "Open GitHub Repository")
Help_Button.OnEvent("Click", OpenRepo)

Updater_Button := MyGui.AddButton("x+6", "Check For Updates")
Updater_Button.OnEvent("Click", (*) => Updater("MANUAL_CHECK"))

Hotkey(HotkeyBST, (*) => RunMacro(DropBST, "Hotkey"), "Off")
Hotkey(HotkeyReload, (*) => RunMacro(ReloadAllWeapons, "Hotkey"), "Off")
Hotkey(HotkeySpamRespawn, (*) => RunMacro(SpamRespawn, "Hotkey"), "Off")

MyGui.Show("w350 h430")

CenterElement(MyGui, Speed_Text)
CenterElement(MyGui, Speed_Slider)
CenterElements(MyGui, DropBST_Button, ReloadAllWeapons_Button, SpamRespawn_Button)
CenterElement(MyGui, ReloadAllWeapons_CheckBox)

; Fixes a visual Glitch issue, using `Hidden` and then `.Visible` works too, but this is cleaner imo.
DropBST_Button.Enabled := true
ReloadAllWeapons_Button.Enabled := true
SpamRespawn_Button.Enabled := true

OnMessage(0x0100, On_WM_KEYDOWN)
OnMessage(0x0200, On_WM_MOUSEMOVE)
OnMessage(0x020A, On_WM_MOUSEWHEEL)

A_TrayMenu.Insert("1&", "Hide", (*) => HideGui(MyGui))
A_TrayMenu.Insert("2&")

Updater("STARTUP_CHECK")

SetTimer(() => UpdateTrayMenuShowHideOptionState(MyGui), 100)

/*
HotIfWinActive(GTA_WINDOW_IDENTIFIER)
Known-Bug: After restarting the game this method ain't working anymore.
So I fixed it by implementing my own one just below.
*/
SetTimer(IsGTARunning_Callback, 100) ; Only enable Hotkeys when the GTA_WINDOW_IDENTIFIER conditions are found.
