#Requires AutoHotkey v2.0
#SingleInstance Force


; Globals
HotkeyBST := "F1"
HotkeyReload := "F2"
KeyHold := 50
KeyDelay := 50

; Constants
DEBUG_ENABLED := false

SCRIPT_NAME := "TRYHARD_Macros.ahk"
SCRIPT_TITLE := "TRYHARD Macros"

TOOLTIP_DISPLAY_TIME := 250
TOOLTIP_HIDE_TIME := 3000

KEY_HOLD_VERY_SLOW := 100
KEY_HOLD_SLOW := 75
KEY_HOLD_NORMAL := 50
KEY_HOLD_FAST := 35
KEY_HOLD_VERY_FAST := 25

KEY_DELAY_VERY_SLOW := 100
KEY_DELAY_SLOW := 75
KEY_DELAY_NORMAL := 50
KEY_DELAY_FAST := 35
KEY_DELAY_VERY_FAST := 25

TEXT_SPEED_VERY_SLOW := "Very Slow: " . KEY_DELAY_VERY_SLOW . "ms"
TEXT_SPEED_SLOW := "Slow: " . KEY_DELAY_SLOW . "ms"
TEXT_SPEED_NORMAL := "Normal: " . KEY_DELAY_NORMAL . "ms"
TEXT_SPEED_FAST := "Fast: " . KEY_DELAY_FAST . "ms"
TEXT_SPEED_VERY_FAST := "Very Fast: " . KEY_DELAY_VERY_FAST . "ms"

WAITING_GTA_WINDOW_TIMER := 5

MSGBOX_SYSTEM_MODAL := 4096

CENTER_ADJUSTMENT_PIXELS := 7


SetTitleMatchMode(3) ; Exact match mode

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd) {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if !CurrControl.HasProp("ToolTip") {
                return
            }
            Text := CurrControl.ToolTip
            SetTimer () => ToolTip(Text), -TOOLTIP_DISPLAY_TIME
            SetTimer () => ToolTip(), -TOOLTIP_HIDE_TIME
        }

        PrevHwnd := Hwnd
    }
}

Link_Click(Ctrl, ID, HREF) {
    Run(HREF)
}

Pluralize(count, singular, plural := "") {
    if count > 1 {
        return plural ? plural : singular . "s"
    }
    return singular
}

CustomOutputDebug(str) {
    if DEBUG_ENABLED {
        OutputDebug("[" . SCRIPT_NAME . "]: " . str)
    }
}

AddSeparator(gui, Options := {}) {
    TextOptions1 := "w0 h0" . (Options.HasOwnProp("text1") ? " " . Options.text1 : "")
    TextOptions2 := "w244 h1 Border" . (Options.HasOwnProp("text2") ? " " . Options.text2 : "")
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


SetDelay(*) {
    global KeyDelay, KeyHold

    speed := Speed_DropdownList.Text

    switch speed {
        case TEXT_SPEED_VERY_SLOW:
            KeyDelay := KEY_DELAY_VERY_SLOW
            KeyHold := KEY_HOLD_VERY_SLOW
        case TEXT_SPEED_SLOW:
            KeyDelay := KEY_DELAY_SLOW
            KeyHold := KEY_HOLD_SLOW
        case TEXT_SPEED_NORMAL:
            KeyDelay := KEY_DELAY_NORMAL
            KeyHold := KEY_HOLD_NORMAL
        case TEXT_SPEED_FAST:
            KeyDelay := KEY_DELAY_FAST
            KeyHold := KEY_HOLD_FAST
            MsgBox(
                "This method is only recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise.",
                SCRIPT_TITLE,
                "OK Iconi " . MSGBOX_SYSTEM_MODAL
            )
        case TEXT_SPEED_VERY_FAST:
            KeyDelay := KEY_DELAY_VERY_FAST
            KeyHold := KEY_HOLD_VERY_FAST
            MsgBox(
                "This method is only recommended in invite-only sessions with a very limited number of players, as it may not work consistently otherwise.",
                SCRIPT_TITLE,
                "OK Iconi " . MSGBOX_SYSTEM_MODAL
            )
    }
}

ApplyHotkeyBST(*) {
    global HotkeyBST

    try {
        ; Remove any previous hotkey assignment
        Hotkey(HotkeyBST, "Off", "Off")

        HotkeyBST := HotkeyBST_Edit.Value
        Hotkey(HotkeyBST, DropBST)
        Hotkey(HotkeyBST, "On", "On")
    } catch error as err {
        if (err.what == "Hotkey" && err.message == "Invalid key name.") {
            MsgBox(
                "Error: Hotkey is an invalid key name.",
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return false
        }
        throw err
    }

    return true
}

ApplyHotkeyReload(*) {
    global HotkeyReload

    try {
        ; Remove any previous hotkey assignment
        Hotkey(HotkeyReload, "Off", "Off")

        HotkeyReload := HotkeyReload_Edit.Value
        Hotkey(HotkeyReload, ReloadAllWeapons)
        Hotkey(HotkeyReload, "On", "On")
    } catch error as err {
        if (err.what == "Hotkey" && err.message == "Invalid key name.") {
            MsgBox(
                "Error: Hotkey is an invalid key name.",
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return false
        }
        throw err
    }

    return true
}

openRepo(*) {
    Run("https://github.com/Illegal-Services/TRYHARD_GTA_Macros")
}

/*
Checks if a window with the title "Grand Theft Auto V", class "grcWindow", and process name "GTA5.exe" exists.
Returns the unique ID (HWND) of the first matching window (or 0 if none).
*/
GetExistingGTAWindow() {
    return WinExist("Grand Theft Auto V ahk_class grcWindow ahk_exe GTA5.exe")
}

/*
Validates if the "Grand Theft Auto V" window title (with class "grcWindow" and process "GTA5.exe") is active.
- If the window or process is not found, an error message is shown and false is returned.
- If the window is not active, it waits for the window to become active within a given time.
- If the window doesn't become active within the specified time, an error message is shown.
- Returns true, or false
*/
WaitGTAWindowActive() {
    if !GetExistingGTAWindow() {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        return false
    }

    CustomOutputDebug("Waiting for window activation ...")

    if !WinActive() {
        if !WinWaitActive(,, WAITING_GTA_WINDOW_TIMER) {
            MsgBox(
                "ERROR: You didn't open GTA V window within " . WAITING_GTA_WINDOW_TIMER . ' ' . Pluralize(WAITING_GTA_WINDOW_TIMER, "second") . ".`n`nThe macro has been aborted.",
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return false
        }

        Sleep(1000) ; Wait for 1 second after the window becomes active
    }

    return true
}

; Define a function to send key press, hold, and release
SendKeyWithDelay(key, holdTime, releaseTime) {
    CustomOutputDebug("{" key " down}")
    Send("{" key " down}")
    Sleep(holdTime)
    CustomOutputDebug("{" key " up}")
    Send("{" key " up}")
    Sleep(releaseTime)
}

/*
Processes a sequence of keystrokes for the game.
Takes a list of keystrokes where each keystroke includes:
- `count`: Number of times the key should be pressed
- `key`: The key to be pressed
- `hold`: Duration to hold the key
- `delay`: Time to wait between key presses

Checks if the GTA V window is active before sending each keystroke.
Displays an error message and aborts if the GTA V window is no longer running.
*/
ProcessGTAKeystrokes(Keystrokes) {
    if !WaitGTAWindowActive() {
        return false
    }

    for Keystroke in Keystrokes {
        if (!WinExist() || !WinActive() || !ProcessGetName(WinGetPID()) == "GTA5.exe") {
            MsgBox(
                'ERROR: "GTA5.exe" is no longer running, aborting process.',
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            return false
        }

        loop Keystroke.count {
            SendKeyWithDelay(Keystroke.key, Keystroke.hold, Keystroke.delay)
        }
    }
    return true
}

DropBST(*) {
    BST_Keystrokes := [
        { count: 1, key: ",", hold: KeyHold, delay: KeyDelay * 6 },
        ; in Interaction Menu
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 },
        ; in SecuroServ CEO Menu
        { count: 4, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 },
        ; in CEO Abilities Menu
        { count: 1, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: 0 }
        ; select Drop Bull Shark
    ]

    ProcessGTAKeystrokes(BST_Keystrokes)
}

ReloadAllWeapons(*) {
    Reload_Keystrokes := [
        { count: 1, key: ",", hold: KeyHold, delay: KeyDelay * 20 },
        ; in Interaction Menu
        { count: 4, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 5 },
        ; in Health and Ammo Menu
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 5 },
        ; in Ammo Menu
        { count: 1, key: "Left", hold: KeyHold, delay: KeyDelay },
        ; selected Ammo Type < All >
        { count: 1, key: "Down", hold: KeyHold, delay: KeyDelay },
        ; hover Full Ammo $~
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 5 },
        ; exit Interaction Menu
        { count: 1, key: ",", hold: KeyHold, delay: 0 }
    ]

    ProcessGTAKeystrokes(Reload_Keystrokes)
}


MyGui := Gui()
MyGui.Title := SCRIPT_TITLE

MyGui.Opt("+AlwaysOnTop")  ; +Owner avoids a taskbar button.

Speed_Text := MyGui.AddText(, "Select Macro Speed:")
Speed_DropdownList := MyGui.AddDropDownList(, [
    TEXT_SPEED_VERY_SLOW,
    TEXT_SPEED_SLOW,
    TEXT_SPEED_NORMAL,
    TEXT_SPEED_FAST,
    TEXT_SPEED_VERY_FAST,
])
Speed_DropdownList.Choose(3)
Speed_DropdownList.OnEvent("Change", SetDelay)

AddSeparator(MyGui)

DropBST_Button := MyGui.AddButton("Disabled", "Drop BST*")
DropBST_Button.OnEvent("Click", DropBST)
DropBST_Button.ToolTip := "*Drop BST: Ensure you are in a CEO Organization."
ReloadAllWeapons_Button := MyGui.AddButton("Disabled x+10", "Reload All Weapons")
ReloadAllWeapons_Button.OnEvent("Click", ReloadAllWeapons)

AddSeparator(MyGui, { text1: "x10" })

MyGui.AddText(, "Hotkey for Drop BST:")
HotkeyBST_Edit := MyGui.AddEdit("w100", HotkeyBST)
HotkeyBST_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyBST_Button.OnEvent("Click", ApplyHotkeyBST)
MyGui.AddText("x10", "Hotkey for Reload All Weapons:")
HotkeyReload_Edit := MyGui.AddEdit("w100", HotkeyReload)
HotkeyReload_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyReload_Button.OnEvent("Click", ApplyHotkeyReload)
HotkeysHelp_Link := MyGui.AddLink("x10", 'Full list of possible Hotkeys:`n<a id="KeyListHelp" href="https://www.autohotkey.com/docs/v2/KeyList.htm">https://www.autohotkey.com/docs/v2/KeyList.htm</a>.')
HotkeysHelp_Link.OnEvent("Click", Link_Click)

AddSeparator(MyGui)

Repo_Button := MyGui.AddButton("Default x+100", "Help / Check For Updates")
Repo_Button.OnEvent("Click", openRepo)

Hotkey(HotkeyBST, DropBST)
Hotkey(HotkeyReload, ReloadAllWeapons)

MyGui.Show("w280 h342")

OnMessage(0x0200, On_WM_MOUSEMOVE)

CenterElement(MyGui, Speed_Text)
CenterElement(MyGui, Speed_DropdownList)
CenterElements(MyGui, DropBST_Button, ReloadAllWeapons_Button)

; Fixes a visual Glitch issue, using `Hidden` and then `.Visible` works too, but this is cleaner imo.
DropBST_Button.Enabled := true
ReloadAllWeapons_Button.Enabled := true