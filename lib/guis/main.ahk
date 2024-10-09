MyMainGui := Gui()
MyMainGui.Opt("+AlwaysOnTop")
MyMainGui.Title := SCRIPT_TITLE

; Oh please do not ask me what the fuck I've done with x and y I just tried to make it works and it does.
Speed_Text := MyMainGui.AddText("y+10 w108", GenerateMacroSpeedText(Settings_Map["KEY_DELAY"])) ; here keeping w108 is important to keep (e.g., a 3-digit number like 100) showing up correctly.
MyMainGui.AddText("xm x32 y35", "[" . KEY_DELAY_SLOWEST . "ms]")
Speed_Slider := MyMainGui.AddSlider("yp y30 w200", KEY_DELAY_SLOWEST - Settings_Map["KEY_DELAY"] + 20)
Speed_Slider.Opt("Invert")
Speed_Slider.Opt("Line5")
Speed_Slider.Opt("Page10")
Speed_Slider.Opt("Range" . KEY_DELAY_FASTEST . "-" . KEY_DELAY_SLOWEST)
Speed_Slider.Opt("Thick30")
Speed_Slider.Opt("TickInterval5")
Speed_Slider.Opt("ToolTip")
Speed_Slider.OnEvent("Change", UpdateMacroSpeed)
MyMainGui.AddText("yp y35", "[" . KEY_DELAY_FASTEST . "ms]")
; Dev-Note: alternative code --> https://discord.com/channels/288498150145261568/866440127320817684/1288240872630259815

AddSeparator(MyMainGui, {text1: "x10"})

DropBST_Button := MyMainGui.AddButton("Disabled", "Drop BST*")
DropBST_Button.OnEvent("Click", (*) => RunMacro(DropBST, "Button"))
DropBST_Button.ToolTip := "*Ensure you are in a CEO Organization."
ReloadAllWeapons_Button := MyMainGui.AddButton("Disabled x+10", "Reload All Weapons*")
ReloadAllWeapons_Button.OnEvent("Click", (*) => RunMacro(ReloadAllWeapons, "Button"))
ReloadAllWeapons_Button.ToolTip := "*You can adjust the number of weapon type iterations in the Settings."
SpamRespawn_Button := MyMainGui.AddButton("Disabled x+10", "Spam Respawn*")
SpamRespawn_Button.OnEvent("Click", (*) => RunMacro(SpamRespawn, "Button"))
SpamRespawn_Button.ToolTip := "*Use this on the death screen after being killed to speed up your respawn time."
ThermalVision_Button := MyMainGui.AddButton("Disabled x10", "Thermal Vision*")
ThermalVision_Button.OnEvent("Click", (*) => RunMacro(ThermalVision, "Button"))
ThermalVision_Button.ToolTip := "*Toogles your Combat Helmet, Thermal Vision ON/OFF.`nYou must wear a Thermal Vision Combat Helmet (Dual/Quad Lens) with the Visor in the down position.`n`nPlease note that there is a game bug where the helmet doesn't appear in the 'Interaction Menu' > 'Accessories'.`nYou will need to resolve this issue on your own."

MyMainGui.AddText("x10")

SuspendGame_Button := MyMainGui.AddButton("Disabled", "Suspend Game*")
SuspendGame_Button.OnEvent("Click", (*) => RunMacro(SuspendGame, "Button"))
SuspendGame_Button.ToolTip := "*You can use this to force yourself into a solo public session.`nThis is especially useful when making risky sales in public lobbies."
TerminateGame_Button := MyMainGui.AddButton("Disabled x+0", "Terminate Game*")
TerminateGame_Button.OnEvent("Click", (*) => RunMacro(TerminateGame, "Button"))
TerminateGame_Button.ToolTip := "*You can use this to select the Casino Lucky Wheel slot you want.`nIf it doesn't match your choice, close the game and try again as many times as needed."

AddSeparator(MyMainGui, {text1: "x10"})

Settings_Button := MyMainGui.AddButton("Disabled x+0", "Settings")
Settings_Button.OnEvent("Click", (*) => OpenSettingsGui())

OpenRepo_Button := MyMainGui.AddButton("Disabled x+0", "Open Repository")
OpenRepo_Button.OnEvent("Click", (*) => OpenRepo())

Updater_Button := MyMainGui.AddButton("Disabled x+0", "Check For Updates")
Updater_Button.OnEvent("Click", (*) => RunUpdater("MANUAL"))
