#Requires AutoHotkey v2.0

F2::
{
    ; Enters in the player's "Interaction Menu".
    Send(",")
    Sleep(100)

    ; Enters in "Health and Ammo" tab.
    Send("{Down 4}")
    Send("{Enter}")
    Sleep(100)

    ; Enters in "Ammo" tab.
    Send("{Enter}")
    Sleep(100)

    ; Assuming we where on the "Pistol Ammo", switches to "All" (Ammo Type)
    Send("{Left}")
    ; Hover "Full Ammo"
    Send("{Down}")
    ; Select "Full Ammo"
    Send("{Enter}")
    Sleep(1000)

    ; Leaves the player's "Interaction Menu".
    Send(",")
}
