#Requires AutoHotkey v2.0

F1::
{
    ; Enters in the player's "Interaction Menu".
    Send(",")
    Sleep(100)

    ; Assuming player is already in an Organization, enters in the "SecuroServ CEO" tab.
    Send("{Enter}")
    Sleep(100)

    ; Enters in the "CEO Abilities" tab.
    Send("{Up 3}")
    Send("{Enter}")
    Sleep(100)

    ; Selects "Drop Bull Shark".
    Send("{Down}")
    Send("{Enter}")
}
