#Requires AutoHotkey v2.0
#SingleInstance Force


; Constants
DEBUG_ENABLED := false

SCRIPT_TITLE := "TRYHARD Macros"
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

KEY_HOLD_VERY_SLOW := 60
KEY_HOLD_SLOW := 50
KEY_HOLD_NORMAL := 40
KEY_HOLD_FAST := 30
KEY_HOLD_VERY_FAST := 20

KEY_DELAY_VERY_SLOW := 60
KEY_DELAY_SLOW := 50
KEY_DELAY_NORMAL := 40
KEY_DELAY_FAST := 30
KEY_DELAY_VERY_FAST := 20

TEXT_SPEED_VERY_SLOW := "Very Slow: " . KEY_DELAY_VERY_SLOW . "ms"
TEXT_SPEED_SLOW := "Slow: " . KEY_DELAY_SLOW . "ms"
TEXT_SPEED_NORMAL := "Normal: " . KEY_DELAY_NORMAL . "ms"
TEXT_SPEED_FAST := "Fast: " . KEY_DELAY_FAST . "ms"
TEXT_SPEED_VERY_FAST := "Very Fast: " . KEY_DELAY_VERY_FAST . "ms"

; Globals
HotkeyBST := DEFAULT_HOTKEY_BST
HotkeyReload := DEFAULT_HOTKEY_RELOAD
HotkeySpamRespawn := DEFAULT_HOTKEY_SPAMRESPAWN
KeyHold := 50
KeyDelay := 50
IsMacroRunning := false


SetTitleMatchMode(3) ; Exact match mode
HotIfWinActive(GTA_WINDOW_IDENTIFIER) ; Only enable Hotkeys when the GTA_WINDOW_IDENTIFIER conditions are found.

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

Link_Click(Ctrl, ID, HREF) {
    Run(HREF)
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
    Send("{" key " down}")
    Sleep(holdTime)
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

    if not (WinExist("ahk_id " gtaWindowID) and ProcessGetName(WinGetPID("ahk_id " gtaWindowID)) == "GTA5.exe") {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" using class "grcWindow" and with process name "GTA5.exe".`n`nPlease ensure GTA V is currently running.',
            SCRIPT_TITLE,
            "OK Icon! " . MSGBOX_SYSTEM_MODAL
        )
        return false
    }

    if (triggerSource == "Button" and WinExist("ahk_id " gtaWindowID) and not WinActive("ahk_id " gtaWindowID) and ProcessGetName(WinGetPID("ahk_id " gtaWindowID)) == "GTA5.exe") {
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
            if not (WinExist("ahk_id " gtaWindowID) and WinActive("ahk_id " gtaWindowID) and ProcessGetName(WinGetPID("ahk_id " gtaWindowID)) == "GTA5.exe") {
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

    if (isMacroRunning) {
        return false
    }
    isMacroRunning := true

    result := macroFunc(triggerSource)  ; Call the specific macro function

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
        static NumOfWeaponTypesToIterate := 8

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

MyGui.AddText(, 'Hotkey for "Drop BST" :')
HotkeyBST_Edit := MyGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_BST)
HotkeyBST_Button := MyGui.AddButton("w66 x+10", "Apply")
HotkeyBST_Button.OnEvent("Click", ApplyHotkeyBST)
HotkeyBSTRemove_Button := MyGui.AddButton("w66 x+10", "Remove")
HotkeyBSTRemove_Button.OnEvent("Click", (*) => RemoveHotkey("HotkeyBST"))
HotkeyBSTReset_Button := MyGui.AddButton("w66 x+10", "Reset")
HotkeyBSTReset_Button.OnEvent("Click", (*) => ResetHotkey("HotkeyBST"))
MyGui.AddText("x10", 'Hotkey for "Reload All Weapons" :')
HotkeyReload_Edit := MyGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_RELOAD)
HotkeyReload_Button := MyGui.AddButton("w66 x+10", "Apply")
HotkeyReload_Button.OnEvent("Click", ApplyHotkeyReload)
HotkeyReloadRemove_Button := MyGui.AddButton("w66 x+10", "Remove")
HotkeyReloadRemove_Button.OnEvent("Click", (*) => RemoveHotkey("HotkeyReload"))
HotkeyReloadReset_Button := MyGui.AddButton("w66 x+10", "Reset")
HotkeyReloadReset_Button.OnEvent("Click", (*) => ResetHotkey("HotkeyReload"))
MyGui.AddText("x10", 'Hotkey for "Spam Respawn" :')
HotkeySpamRespawn_Edit := MyGui.AddEdit("w100 Limit17", DEFAULT_HOTKEY_SPAMRESPAWN)
HotkeySpamRespawn_Button := MyGui.AddButton("w66 x+10", "Apply")
HotkeySpamRespawn_Button.OnEvent("Click", ApplyHotkeySpamRespawn)
HotkeySpamRespawnRemove_Button := MyGui.AddButton("w66 x+10", "Remove")
HotkeySpamRespawnRemove_Button.OnEvent("Click", (*) => RemoveHotkey("HotkeySpamRespawn"))
HotkeySpamRespawnReset_Button := MyGui.AddButton("w66 x+10", "Reset")
HotkeySpamRespawnReset_Button.OnEvent("Click", (*) => ResetHotkey("HotkeySpamRespawn"))

HotkeysHelp_Link := MyGui.AddLink("x10", 'Full list of possible Hotkeys:`n<a id="KeyListHelp" href="https://www.autohotkey.com/docs/v2/KeyList.htm">https://www.autohotkey.com/docs/v2/KeyList.htm</a>')
HotkeysHelp_Link.OnEvent("Click", Link_Click)

AddSeparator(MyGui)

Repo_Button := MyGui.AddButton("Default x+176", "Help / Check For Updates")
Repo_Button.OnEvent("Click", openRepo)

Hotkey(HotkeyBST, (*) => RunMacro(DropBST, "Hotkey"))
Hotkey(HotkeyReload, (*) => RunMacro(ReloadAllWeapons, "Hotkey"))
Hotkey(HotkeySpamRespawn, (*) => RunMacro(SpamRespawn, "Hotkey"))

MyGui.Show("w350 h410")

CenterElement(MyGui, Speed_Text)
CenterElement(MyGui, Speed_DropdownList)
CenterElements(MyGui, DropBST_Button, ReloadAllWeapons_Button, SpamRespawn_Button)
CenterElement(MyGui, ReloadAllWeapons_CheckBox)

; Fixes a visual Glitch issue, using `Hidden` and then `.Visible` works too, but this is cleaner imo.
DropBST_Button.Enabled := true
ReloadAllWeapons_Button.Enabled := true
SpamRespawn_Button.Enabled := true

OnMessage(0x0200, On_WM_MOUSEMOVE)

A_TrayMenu.Insert("1&", "Hide", (*) => HideGui(MyGui))
A_TrayMenu.Insert("2&")
SetTimer(() => UpdateTrayMenuShowHideOptionState(MyGui), 100)
