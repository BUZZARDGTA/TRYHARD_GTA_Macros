#Requires AutoHotkey v2.0
#SingleInstance Force


; Globals
HotkeyBST := "F1"
HotkeyReload := "F2"
KeyHold := 50
KeyDelay := 50

; Constants
DEBUG_ENABLED := false
GTA_WINDOW_IDENTIFIER := "Grand Theft Auto V ahk_class grcWindow ahk_exe GTA5.exe"
MSGBOX_SYSTEM_MODAL := 4096
CENTER_ADJUSTMENT_PIXELS := 7

SCRIPT_NAME := "TRYHARD_Macros.ahk"
SCRIPT_TITLE := "TRYHARD Macros"

TOOLTIP_DISPLAY_TIME := 250
TOOLTIP_HIDE_TIME := 5000

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


SetTitleMatchMode(3) ; Exact match mode
HotIfWinActive(GTA_WINDOW_IDENTIFIER) ; Only enable Hotkeys when the GTA_WINDOW_IDENTIFIER conditions are found.

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if not (Hwnd == PrevHwnd) {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if not CurrControl.HasProp("ToolTip") {
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

Print(str) {
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

    switch Speed_DropdownList.Text {
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
        default:
            KeyDelay := KEY_DELAY_NORMAL
            KeyHold := KEY_HOLD_NORMAL
    }
}

openRepo(*) {
    Run("https://github.com/Illegal-Services/TRYHARD_GTA_Macros")
}

; Define a function to send key press, hold, and release
SendKeyWithDelay(key, holdTime, releaseTime) {
    Print("{" key " down}")
    Send("{" key " down}")
    Sleep(holdTime)
    Print("{" key " up}")
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
ProcessGTAKeystrokes(triggerSource, Keystrokes) {
    ; Get the HWND of the first window matching GTA_WINDOW_IDENTIFIER
    gtaWindowID := WinExist(GTA_WINDOW_IDENTIFIER)

    if not (WinExist("ahk_id " gtaWindowID) and ProcessGetName(WinGetPID("ahk_id " gtaWindowID)) == "GTA5.exe") {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        return false
    }

    if (triggerSource == "Button" and WinExist("ahk_id " gtaWindowID) and not WinActive("ahk_id " gtaWindowID) and ProcessGetName(WinGetPID("ahk_id " gtaWindowID)) == "GTA5.exe") {
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
        Sleep(KeyDelay * 10)
    }

    for Keystroke in Keystrokes {
        if not (WinExist("ahk_id " gtaWindowID) and WinActive("ahk_id " gtaWindowID) and ProcessGetName(WinGetPID("ahk_id " gtaWindowID)) == "GTA5.exe") {
            MsgBox(
                'ERROR: GTA V window is no longer active, aborting process.',
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

DropBST(triggerSource) {
    BST_Keystrokes := [
        { count: 1, key: ",", hold: KeyHold, delay: KeyDelay * 6 },
        ; in [Interaction Menu]
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 },
        ; in [SecuroServ CEO]
        { count: 4, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 },
        ; in [CEO Abilities]
        { count: 1, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: 0 }
        ; select [Drop Bull Shark]
    ]

    ProcessGTAKeystrokes(triggerSource, BST_Keystrokes)
}

ReloadAllWeapons(triggerSource) {
    Reload_Keystrokes := []

    Reload_Keystrokes.Push(
        { count: 1, key: ",", hold: KeyHold, delay: KeyDelay * 6 },
        ; in [Interaction Menu]
        { count: 4, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 },
        ; in [Health and Ammo]
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 }
        ; in [Ammo]
    )

    if (ReloadAllWeapons_CheckBox.Value == 1) {
        ; Iterate through each [Ammo Type] and select the [Full Ammo $x] option for each
        Loop 8 {
            Reload_Keystrokes.Push(
                { count: 1, key: "Up", hold: KeyHold, delay: KeyDelay },
                { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay },
                { count: 1, key: "Down", hold: KeyHold, delay: KeyDelay },
                { count: 1, key: "Left", hold: KeyHold, delay: KeyDelay }
            )
        }
    } else {
        Reload_Keystrokes.Push(
            { count: 1, key: "Left", hold: KeyHold, delay: KeyDelay },
            ; hover [Ammo Type < All >]
            { count: 1, key: "Down", hold: KeyHold, delay: KeyDelay },
            ; hover [Full Ammo $x]
            { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 3 }
        )
    }

    ; exit [Interaction Menu]
    Reload_Keystrokes.Push({ count: 1, key: ",", hold: KeyHold, delay: 0 })

    ProcessGTAKeystrokes(triggerSource, Reload_Keystrokes)
}

ApplyHotkeyBST(*) {
    global HotkeyBST

    if (HotkeyBST_Edit.Value == HotkeyReload) {
        MsgBox(
            "Error: You cannot assign a hotkey to more than one macro.",
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        HotkeyBST_Edit.Value := HotkeyBST
        return false
    }

    Hotkey(HotkeyBST, "Off")

    try {
        Hotkey(HotkeyBST_Edit.Value, (*) => DropBST("Hotkey"))
    } catch error as err {
        if (err.what == "Hotkey" and (err.message == "Invalid key name." or err.message == "Invalid hotkey.")) {
            MsgBox(
                "Error: " . err.message,
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            Hotkey(HotkeyBST, (*) => DropBST("Hotkey"))
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

    if (HotkeyReload_Edit.Value == HotkeyBST) {
        MsgBox(
            "Error: You cannot assign a hotkey to more than one macro.",
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        HotkeyReload_Edit.Value := HotkeyReload
        return false
    }

    Hotkey(HotkeyReload, "Off")

    try {
        Hotkey(HotkeyReload_Edit.Value, (*) => ReloadAllWeapons("Hotkey"))
    } catch error as err {
        if (err.what == "Hotkey" and (err.message == "Invalid key name." or err.message == "Invalid hotkey.")) {
            MsgBox(
                "Error: " . err.message,
                SCRIPT_TITLE,
                "OK Icon! " . MSGBOX_SYSTEM_MODAL
            )
            Hotkey(HotkeyReload, (*) => ReloadAllWeapons("Hotkey"))
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


MyGui := Gui()
MyGui.Title := SCRIPT_TITLE

MyGui.Opt("+AlwaysOnTop")

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
DropBST_Button.OnEvent("Click", (*) => DropBST("Button"))
DropBST_Button.ToolTip := "*Ensure you are in a CEO Organization."
ReloadAllWeapons_Button := MyGui.AddButton("Disabled x+10", "Reload All Weapons*")
ReloadAllWeapons_Button.OnEvent("Click", (*) => ReloadAllWeapons("Button"))
ReloadAllWeapons_Button.ToolTip := '*If you are NOT using "FIX (slower)", before reloading, fire a single pistol round.'

ReloadAllWeapons_CheckBox := MyGui.AddCheckBox("x10", "Reload All Weapons: FIX (slower)")
ReloadAllWeapons_CheckBox.Value := 1

AddSeparator(MyGui)

MyGui.AddText(, "Hotkey for Drop BST:")
HotkeyBST_Edit := MyGui.AddEdit("w100 Limit17", HotkeyBST)
HotkeyBST_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyBST_Button.OnEvent("Click", ApplyHotkeyBST)
MyGui.AddText("x10", "Hotkey for Reload All Weapons:")
HotkeyReload_Edit := MyGui.AddEdit("w100 Limit17", HotkeyReload)
HotkeyReload_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyReload_Button.OnEvent("Click", ApplyHotkeyReload)
HotkeysHelp_Link := MyGui.AddLink("x10", 'Full list of possible Hotkeys:`n<a id="KeyListHelp" href="https://www.autohotkey.com/docs/v2/KeyList.htm">https://www.autohotkey.com/docs/v2/KeyList.htm</a>.')
HotkeysHelp_Link.OnEvent("Click", Link_Click)

AddSeparator(MyGui)

Repo_Button := MyGui.AddButton("Default x+100", "Help / Check For Updates")
Repo_Button.OnEvent("Click", openRepo)


Hotkey(HotkeyBST, (*) => DropBST("Hotkey"))
Hotkey(HotkeyReload, (*) => ReloadAllWeapons("Hotkey"))

MyGui.Show("w280 h360")

OnMessage(0x0200, On_WM_MOUSEMOVE)

CenterElement(MyGui, Speed_Text)
CenterElement(MyGui, Speed_DropdownList)
CenterElements(MyGui, DropBST_Button, ReloadAllWeapons_Button)
CenterElement(MyGui, ReloadAllWeapons_CheckBox)

; Fixes a visual Glitch issue, using `Hidden` and then `.Visible` works too, but this is cleaner imo.
DropBST_Button.Enabled := true
ReloadAllWeapons_Button.Enabled := true