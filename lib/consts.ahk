DEBUG_ENABLED := false

SCRIPT_TITLE := "TRYHARD Macros"
SCRIPT_VERSION := "v1.2.6 - 12/10/2024 (02:36)"
SCRIPT_REPOSITORY := "https://github.com/BUZZARDGTA/TRYHARD_GTA_Macros"
SCRIPT_LATEST_RELEASE_URL := SCRIPT_REPOSITORY . "/releases/latest"
SCRIPT_VERSION_UPDATER_URL := "https://raw.githubusercontent.com/BUZZARDGTA/TRYHARD_GTA_Macros/refs/heads/main/VERSION.txt"
SCRIPT_WINDOW_IDENTIFIER := SCRIPT_TITLE . " ahk_class " . "AutoHotkeyGUI" . " ahk_pid " . WinGetPID(A_ScriptHwnd)
SCRIPT_SETTINGS_FILE := "Settings.ini"
UPDATER_SCRIPT_TITLE := "Updater - " . SCRIPT_TITLE
UPDATER_FETCHING_ERROR := "Error: Failed fetching release info."
SETTINGS_SCRIPT_TITLE := "Settings - " . SCRIPT_TITLE
GTA_WINDOW_IDENTIFIER := "Grand Theft Auto V ahk_class grcWindow ahk_exe GTA5.exe"
USER_INPUT__CURRENTLY_PLAYING_MACRO__STOPPING_KEYS := ["LButton", "RButton", "Enter", "Escape", "Backspace"]
MSGBOX_SYSTEM_MODAL := 4096
CENTER_ADJUSTMENT_PIXELS := 7

TOOLTIP_DISPLAY_TIME := 250
TOOLTIP_HIDE_TIME := 6000

KEY_HOLD_SLOWEST := 100
KEY_HOLD_FASTEST := 20

KEY_RELEASE_SLOWEST := 100
KEY_RELEASE_FASTEST := 20

GUI_RESOLUTIONS := {
    MAIN: {
        WIDTH: 350,
        HEIGHT: 264
    },
    SETTINGS: {
        WIDTH: 350,
        HEIGHT: 174
    },
    RELOAD_SETTINGS: {
        WIDTH: 318,
        HEIGHT: 84
    },
    KEYBINDS_SETTINGS: {
        WIDTH: 318,
        HEIGHT: 88
    },
    HOTKEYS_SETTINGS: {
        WIDTH: 350,
        HEIGHT: 320
    }
}

DEFAULT_SETTINGS__MAP := Map(
    "KEY_HOLD", 40,
    "KEY_RELEASE", 40,

    "RADIO_RELOAD_All_WEAPONS_METHOD", 1,
    "RADIO_RELOAD_All_WEAPONS_ITERATE_DIRECTION", 1,
    "EDIT_RELOAD_All_WEAPONS", 8,

    "HOTKEY_BST", "*F1",
    "HOTKEY_RELOAD", "*F2",
    "HOTKEY_SPAMRESPAWN", "*F3",
    "HOTKEY_THERMALVISION", "*F4",
    "HOTKEY_SUSPENDGAME", "F11",
    "HOTKEY_TERMINATEGAME", "F12",

    "KEY_BINDING__INTERACTION_MENU", "M"
)