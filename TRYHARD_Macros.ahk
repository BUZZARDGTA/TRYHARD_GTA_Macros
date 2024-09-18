#Requires AutoHotkey v2.0

global DebugEnabled := true
global HotkeyBST := "F1"
global HotkeyReload := "F2"
global KeyDelay := 100
global SCRIPT_TITLE := "TRYHARD Macros"

MyGui := Gui()
MyGui.Title := SCRIPT_TITLE

MyGui.Opt("+AlwaysOnTop")  ; +Owner avoids a taskbar button.

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd) {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if !CurrControl.HasProp("ToolTip")
                return ; No tooltip for this control.
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

CustomOutputDebug(str) {
    if (DebugEnabled) {
        OutputDebug("[TRYHARD_GTA_Macros.ahk]: " str)
    }
}

/*
Checks if a window with the title "Grand Theft Auto V" and process name "GTA5.exe" exists.
If such a window is found, the script will wait indefinitely until the window becomes active.
If the window does not match the criteria, the function will exit early.
*/
CustomWinWaitActive(*) {
    CustomOutputDebug('Searching an active "GTA5.exe" window whose title matches "Grand Theft Auto V" ...')

    SetTitleMatchMode(3) ; 3: A window's title must exactly match WinTitle to be a match.
    for HWND in WinGetList("Grand Theft Auto V") {
        PID := WinGetPID(HWND)
        Title := WinGetTitle(HWND)
        ProcessName := ProcessGetName(PID)

        if (title != "Grand Theft Auto V" || ProcessName != "GTA5.exe") {
            continue
        }

        CustomOutputDebug("Waiting for window activation ...")
        if not (WinExist(HWND) and WinActive(HWND)) {
            WinWaitActive("ahk_pid " PID)
            Sleep(1000)
        }
        return true
    }

    return false
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
    global KeyDelay

    speed := SpeedDropdown.Text
    switch speed {
        case "Very Slow":
            KeyDelay := 500
        case "Slow":
            KeyDelay := 300
        case "Normal":
            KeyDelay := 100
        case "Fast":
            MsgBox(
                "This method is recommended only for sessions with a limited number of players, as it may not work consistently otherwise.",
                SCRIPT_TITLE,
                "OK Iconi 4096"
            )
            KeyDelay := 50
        case "Very Fast":
            MsgBox(
                "This method is recommended only for invite-only sessions with a limited number of players, as it may not work consistently otherwise.",
                SCRIPT_TITLE,
                "OK Iconi 4096"
            )
            KeyDelay := 50
    }
}

; Define the "Drop BST" function to simulate the sequence of keys
DropBST(*) {
    if not CustomWinWaitActive("Grand Theft Auto V", "GTA5.exe") {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" with process name "GTA5.exe".',
            SCRIPT_TITLE,
            "OK Icon! 4096"
        )
        return
    }

    ; Enters in the player's "Interaction Menu".
    Send(",")
    Sleep(KeyDelay * 10)

    ; Assuming player is already in an Organization, enters in the "SecuroServ CEO" tab.
    Send("{Enter}")
    Sleep(KeyDelay * 5)

    ; Enters in the "CEO Abilities" tab.
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Enter}")
    Sleep(KeyDelay * 5)

    ; Selects "Drop Bull Shark".
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Enter}")
}

; Define the "Reload All Weapons" function to simulate the sequence of keys
ReloadAllWeapons(*) {
    if not CustomWinWaitActive("Grand Theft Auto V", "GTA5.exe") {
        MsgBox(
            'ERROR: Unable to find a window titled "Grand Theft Auto V" with process name "GTA5.exe".',
            SCRIPT_TITLE,
            "OK Icon! 4096"
        )
        return
    }

    ; Enters in the player's "Interaction Menu".
    Send(",")
    Sleep(KeyDelay * 10)

    ; Enters in "Health and Ammo" tab.
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Down}")
    Sleep(KeyDelay)
    Send("{Enter}")
    Sleep(KeyDelay)

    ; Enters in "Ammo" tab.
    Send("{Enter}")
    Sleep(KeyDelay)

    ; Assuming we where on the "Pistol Ammo", switches to "All" (Ammo Type)
    Send("{Left}")
    Sleep(KeyDelay)
    ; Hover "Full Ammo"
    Send("{Down}")
    Sleep(KeyDelay)
    ; Select "Full Ammo"
    Send("{Enter}")
    Sleep(KeyDelay * 10)

    ; Leaves the player's "Interaction Menu".
    Send(",")
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
    "Very Slow",
    "Slow",
    "Normal",
    "Fast",
    "Very Fast"
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

MyGui.AddText(, "Hotkey* for Drop BST:")
HotkeyBST_Input := MyGui.AddEdit("w100", HotkeyBST)
HotkeyBST_Button := MyGui.AddButton("w75 x+10", "Apply")
HotkeyBST_Button.OnEvent("Click", ApplyHotkeyBST)
MyGui.AddText("x10", "Hotkey* for Reload All Weapons:")
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