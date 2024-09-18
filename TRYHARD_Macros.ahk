#Requires AutoHotkey v2.0

global DebugEnabled := true
global HotkeyBST := "F1"
global HotkeyReload := "F2"
global KeyDelay := 100
global SCRIPT_TITLE := "TRYHARD Macros"

MyGui := Gui()
MyGui.Title := SCRIPT_TITLE

MyGui.Opt("+AlwaysOnTop")  ; +Owner avoids a taskbar button.

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
            KeyDelay := 50
        case "Very Fast":
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

ApplyHotkeys(*) {
    global HotkeyBST
    global HotkeyReload

    HotkeyBST := HotkeyBST_Input.Value
    Hotkey(HotkeyBST, DropBST)

    HotkeyReload := HotkeyReload_Input.Value
    Hotkey(HotkeyReload, ReloadAllWeapons)
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

MyGui.AddText("w0 h1", "")
MyGui.AddText("w244 h1 Border", "")
MyGui.AddText("w0 h1", "")

DropBST_Button := MyGui.AddButton("Default", "Drop BST")
DropBST_Button.OnEvent("Click", DropBST)
ReloadAllWeapons_Button := MyGui.AddButton("Default x+10", "Reload All Weapons")
ReloadAllWeapons_Button.OnEvent("Click", ReloadAllWeapons)

MyGui.AddText("x10 w0 h1", "")
MyGui.AddText("w244 h1 Border", "")
MyGui.AddText("w0 h1", "")

MyGui.AddText(, "Hotkey for Drop BST:")
HotkeyBST_Input := MyGui.AddEdit("w100", HotkeyBST)
MyGui.AddButton("w75 x+10", "Apply")
MyGui.AddText("x10", "Hotkey for Reload All Weapons:")
HotkeyReload_Input := MyGui.AddEdit("w100", HotkeyReload)
MyGui.AddButton("w75 x+10", "Apply")

MyGui.AddText("x10 w0 h1", "")
MyGui.AddText("w244 h1 Border", "")
MyGui.AddText("w0 h1", "")

Repo_Button := MyGui.AddButton("Default x+100", "Help / Check For Updates")
Repo_Button.OnEvent("Click", openRepo)

Hotkey(HotkeyBST, DropBST)
Hotkey(HotkeyReload, ReloadAllWeapons)

MyGui.Show("w264 h310")

CenterElement(MyGui, SpeedDropdown)
CenterElement(MyGui, Speed_Text)
CenterElements(MyGui, DropBST_Button, ReloadAllWeapons_Button)