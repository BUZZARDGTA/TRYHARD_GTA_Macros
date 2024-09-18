#Requires AutoHotkey v2.0

global DebugEnabled := true
global HotkeyBST := "F1"
global HotkeyReload := "F2"
global KeyHold := 50
global KeyDelay := 50
global SCRIPT_NAME := "TRYHARD_Macros.ahk"
global SCRIPT_TITLE := "TRYHARD Macros"
global WAITING_GTA_WINDOW_TIMER := 5

MyGui := Gui()
MyGui.Title := SCRIPT_TITLE

MyGui.Opt("+AlwaysOnTop")  ; +Owner avoids a taskbar button.

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd) {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if !CurrControl.HasProp("ToolTip") {
                return ; No tooltip for this control.
            }
            Text := CurrControl.ToolTip
            SetTimer () => ToolTip(Text), -250
            SetTimer () => ToolTip(), -3000 ; Remove the tooltip.
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
    if DebugEnabled {
        OutputDebug("[" . SCRIPT_NAME . "]: " str)
    }
}

/*
Checks if a window with the title "Grand Theft Auto V" and process name "GTA5.exe" exists.
Returns the first PID found, otherwise false.
*/
GetGTAPid() {
    SetTitleMatchMode(3) ; Exact match mode
    for HWND in WinGetList("Grand Theft Auto V") {
        GTAPid := WinGetPID(HWND)
        ProcessName := ProcessGetName(GTAPid)

        if (ProcessName == "GTA5.exe" && WinExist("ahk_pid " GTAPid)) {
            return GTAPid
        }
    }
    return false
}

/*
Checks if a window with the title "Grand Theft Auto V" and process name "GTA5.exe" is active.
If not, displays an error message and returns false.
*/
CheckGTAWindowActive() {
    GTAPid := GetGTAPid()

    if !GTAPid {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" with process name "GTA5.exe".',
            SCRIPT_TITLE,
            "OK Icon! 4096"
        )
        return false
    }

    CustomOutputDebug("Waiting for window activation ...")

    if !WinActive("ahk_pid " GTAPid) {
        if !WinWaitActive("ahk_pid " GTAPid, , WAITING_GTA_WINDOW_TIMER) {
            MsgBox(
                'ERROR: Window titled "Grand Theft Auto V" with process name "GTA5.exe" did not become active within ' . WAITING_GTA_WINDOW_TIMER . ' ' . Pluralize(WAITING_GTA_WINDOW_TIMER, "second") . '.',
                SCRIPT_TITLE,
                "OK Icon! 4096"
            )
            return false
        }

        Sleep(1000) ; Wait for 1 second after the window becomes active
    }

    return GTAPid
}

; Function to center a GUI element
CenterElement(gui, element) {
    ; Get the dimensions of the GUI
    gui.GetPos(&guiX, &guiY, &guiWidth, &guiHeight)

    ; Get the dimensions of the element
    element.GetPos(&elementX, &elementY, &elementWidth, &elementHeight)

    ; Calculate the new X position to center the element horizontally
    newX := (guiWidth - elementWidth) / 2

    ; Move the element to the center horizontally, keeping its original Y position
    element.Move(newX, elementY)
}

; Function to center multiple GUI elements with spacing
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

    ; Calculate starting position to center all elements
    startX := (guiWidth - totalWidth) / 2

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

    speed := SpeedDropdown.Text
    switch speed {
        case "Very Slow: 100ms":
            KeyDelay := 100
            KeyHold := 100
        case "Slow: 75ms":
            KeyDelay := 75
            KeyHold := 75
        case "Normal; 50ms":
            KeyDelay := 50
            KeyHold := 50
        case "Fast; 35ms":
            MsgBox(
                "This method is only recommended in small lobbies, with a limited number of players, as it may not work consistently otherwise.",
                SCRIPT_TITLE,
                "OK Iconi 4096"
            )
            KeyDelay := 35
            KeyHold := 35
        case "Very Fast: 25ms":
            MsgBox(
                "This method is only recommended in invite-only sessions with a very limited number of players, as it may not work consistently otherwise.",
                SCRIPT_TITLE,
                "OK Iconi 4096"
            )
            KeyDelay := 25
            KeyHold := 25
    }
}

; Define a function to send key press, hold, and release
SendKeyWithDelay(count, key, holdTime, releaseTime) {
    loop count {
        CustomOutputDebug("{" key " down}")
        Send("{" key " down}")
        Sleep(holdTime)
        Send("{" key " up}")
        Sleep(releaseTime)
    }
}

; Define the "Drop BST" function to simulate the sequence of keys
DropBST(*) {
    GTAPid := CheckGTAWindowActive()
    if !GTAPid {
        return
    }

    ; Create a list of key actions and delays
    KeyStrokes := [
        { count: 1, key: ",", hold: KeyHold, delay: KeyDelay * 20 },
        ; in Interaction Menu
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 5 },
        ; in SecuroServ CEO Menu
        { count: 4, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: KeyDelay * 5 },
        ; in CEO Abilities Menu
        { count: 1, key: "Down", hold: KeyHold, delay: KeyDelay },
        { count: 1, key: "Enter", hold: KeyHold, delay: 0 }
        ; select Drop Bull Shark
    ]

    ; Process each action while GTA is running
    for KeyStroke in KeyStrokes {
        if (!WinExist("ahk_pid " GTAPid) || !WinActive("ahk_pid " GTAPid)) {
            MsgBox('ERROR: "GTA5.exe" is no longer running, aborting BST Drop.', SCRIPT_TITLE, "OK Icon! 4096")
            return
        }

        SendKeyWithDelay(KeyStroke.count, KeyStroke.key, KeyStroke.hold, KeyStroke.delay)
    }
}

; Define the "Reload All Weapons" function to simulate the sequence of keys
ReloadAllWeapons(*) {
    GTAPid := CheckGTAWindowActive()
    if !GTAPid {
        return
    }

    ; Create a list of key actions and delays
    KeyStrokes := [
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

    ; Process each action while GTA is running
    for KeyStroke in KeyStrokes {
        if (!WinExist("ahk_pid " GTAPid) || !WinActive("ahk_pid " GTAPid)) {
            MsgBox('ERROR: "GTA5.exe" is no longer running, aborting BST Drop.', SCRIPT_TITLE, "OK Icon! 4096")
            return
        }

        SendKeyWithDelay(KeyStroke.count, KeyStroke.key, KeyStroke.hold, KeyStroke.delay)
    }
}

ApplyHotkeyBST(*) {
    global HotkeyBST

    try {
        HotkeyBST := HotkeyBST_Input.Value
        Hotkey(HotkeyBST, DropBST)
    } catch error as err {
        if (err.what == "Hotkey" && err.message == "Invalid key name.") {
            MsgBox(
                "Error: Hotkey is an invalid key name.",
                SCRIPT_TITLE,
                "OK Icon! 4096"
            )
            return false
        }
        throw Error(err)
    }

    return true
}

ApplyHotkeyReload(*) {
    global HotkeyReload

    try {
        HotkeyReload := HotkeyReload_Input.Value
        Hotkey(HotkeyReload, ReloadAllWeapons)
    } catch error as err {
        if (err.what == "Hotkey" && err.message == "Invalid key name.") {
            MsgBox(
                "Error: Hotkey is an invalid key name.",
                SCRIPT_TITLE,
                "OK Icon! 4096"
            )
            return false
        }
        throw Error(err)
    }

    return true
}

openRepo(*) {
    Run("https://github.com/Illegal-Services/TRYHARD_GTA_Macros")
}

Speed_Text := MyGui.AddText(, "Select Macro Speed:")
SpeedDropdown := MyGui.AddDropDownList(, [
    "Very Slow: 100ms",
    "Slow: 75ms",
    "Normal; 50ms",
    "Fast; 35ms",
    "Very Fast: 25ms",
])
SpeedDropdown.Choose(3)
SpeedDropdown.OnEvent("Change", SetDelay)

MyGui.AddText("w0 h0", "")
MyGui.AddText("w244 h1 Border", "")
MyGui.AddText("w0 h0", "")
ShowToolTip(*) {
    ToolTip("*Drop BST: Ensure you are in a CEO Organization.")
}

HideToolTip(*) {
    ToolTip()
}

DropBST_Button := MyGui.AddButton(, "Drop BST*")
DropBST_Button.OnEvent("Click", DropBST)
DropBST_Button.ToolTip := "*Drop BST: Ensure you are in a CEO Organization."
ReloadAllWeapons_Button := MyGui.AddButton("x+10", "Reload All Weapons")
ReloadAllWeapons_Button.OnEvent("Click", ReloadAllWeapons)

MyGui.AddText("x10 w0 h0", "")
MyGui.AddText("w244 h1 Border", "")
MyGui.AddText("w0 h0", "")

MyGui.AddText(, "Hotkey for Drop BST:")
HotkeyBST_Input := MyGui.AddEdit("w100", HotkeyBST)
HotkeyBST_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyBST_Button.OnEvent("Click", ApplyHotkeyBST)
MyGui.AddText("x10", "Hotkey for Reload All Weapons:")
HotkeyReload_Input := MyGui.AddEdit("w100", HotkeyReload)
HotkeyReload_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyReload_Button.OnEvent("Click", ApplyHotkeyReload)
Link := MyGui.AddLink("x10",
    'Full list of possible Hotkeys:`n<a id="KeyListHelp" href="https://www.autohotkey.com/docs/v2/KeyList.htm">https://www.autohotkey.com/docs/v2/KeyList.htm</a>.'
)
Link.OnEvent("Click", Link_Click)

MyGui.AddText("w0 h0", "")
MyGui.AddText("w244 h1 Border", "")
MyGui.AddText("w0 h0", "")

Repo_Button := MyGui.AddButton("Default x+100", "Help / Check For Updates")
Repo_Button.OnEvent("Click", openRepo)

Hotkey(HotkeyBST, DropBST)
Hotkey(HotkeyReload, ReloadAllWeapons)

MyGui.Show("w280 h344")

OnMessage(0x0200, On_WM_MOUSEMOVE)

CenterElement(MyGui, Speed_Text)
CenterElement(MyGui, SpeedDropdown)
CenterElements(MyGui, DropBST_Button, ReloadAllWeapons_Button)