MyMainGui := Gui()
MyMainGui.Opt("+AlwaysOnTop")
MyMainGui.Title := SCRIPT_TITLE
MyGuis.Push(MyMainGui)

; Oh please do not ask me what the fuck I've done with x and y I just tried to make it works and it does.
KeyHold_Text := MyMainGui.AddText("y+10 w128", GenerateMacroSpeedText("Key-Hold", Settings_Map["KEY_HOLD"])) ; here keeping w{x} is important to keep (e.g., a 3-digit number like 100) showing up correctly.
MyMainGui.AddText("xm x32 y35", "[" . KEY_HOLD_SLOWEST . "ms]")
KeyHold_Slider := MyMainGui.AddSlider("yp y30 w200")
KeyHold_Slider.Opt("Invert")
KeyHold_Slider.Opt("Line5")
KeyHold_Slider.Opt("Page10")
KeyHold_Slider.Opt("Range" . KEY_HOLD_FASTEST . "-" . KEY_HOLD_SLOWEST)
KeyHold_Slider.Opt("Thick30")
KeyHold_Slider.Opt("TickInterval5")
KeyHold_Slider.OnEvent("Change", UpdateKeyHoldMacroSpeed)
KeyHold_Slider.Value := Settings_Map["KEY_HOLD"]
MyMainGui.AddText("yp y35", "[" . KEY_HOLD_FASTEST . "ms]")
; Dev-Note: alternative code --> https://discord.com/channels/288498150145261568/866440127320817684/1288240872630259815

; Oh please do not ask me what the fuck I've done with x and y I just tried to make it works and it does.
KeyRelease_Text := MyMainGui.AddText("x10 y+22 w141", GenerateMacroSpeedText("Key-Release", Settings_Map["KEY_RELEASE"])) ; here keeping w{x} is important to keep (e.g., a 3-digit number like 100) showing up correctly.
MyMainGui.AddText("xm x32 y96", "[" . KEY_RELEASE_SLOWEST . "ms]")
KeyRelease_Slider := MyMainGui.AddSlider("yp y90 w200")
KeyRelease_Slider.Opt("Invert")
KeyRelease_Slider.Opt("Line5")
KeyRelease_Slider.Opt("Page10")
KeyRelease_Slider.Opt("Range" . KEY_RELEASE_FASTEST . "-" . KEY_RELEASE_SLOWEST)
KeyRelease_Slider.Opt("Thick30")
KeyRelease_Slider.Opt("TickInterval5")
KeyRelease_Slider.OnEvent("Change", UpdateKeyReleaseMacroSpeed)
KeyRelease_Slider.Value := Settings_Map["KEY_RELEASE"]
MyMainGui.AddText("yp y96", "[" . KEY_RELEASE_FASTEST . "ms]")
; Dev-Note: alternative code --> https://discord.com/channels/288498150145261568/866440127320817684/1288240872630259815

AddSeparator(MyMainGui, {text1: "x10"})

SuspendGame_Button := MyMainGui.AddButton("Disabled", "Suspend Game*")
SuspendGame_Button.OnEvent("Click", (*) => RunMacro(SuspendGame, "Button"))
SuspendGame_Button.ToolTip := "*You can use this to force yourself into a solo public session.`nThis is especially useful when making risky sales in public lobbies."
TooltipElementHwnds.Push(SuspendGame_Button.Hwnd)
TerminateGame_Button := MyMainGui.AddButton("Disabled x+0", "Terminate Game*")
TerminateGame_Button.OnEvent("Click", (*) => RunMacro(TerminateGame, "Button"))
TerminateGame_Button.ToolTip := "*You can use this to select the Casino Lucky Wheel slot you want.`nIf it doesn't match your choice, close the game and try again as many times as needed."
TooltipElementHwnds.Push(TerminateGame_Button.Hwnd)

AddSeparator(MyMainGui, {text1: "x10"})

Settings_Button := MyMainGui.AddButton("Disabled x+0", "Settings")
Settings_Button.OnEvent("Click", (*) => OpenSettingsGui())

OpenRepo_Button := MyMainGui.AddButton("Disabled x+0", "Open Repository")
OpenRepo_Button.OnEvent("Click", (*) => OpenRepo())

Updater_Button := MyMainGui.AddButton("Disabled x+0", "Check For Updates")
Updater_Button.OnEvent("Click", (*) => RunUpdater("MANUAL"))
