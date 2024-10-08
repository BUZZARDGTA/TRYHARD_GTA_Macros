# TRYHARD GTA Macros

Macros for TRYHARD players using AutoHotkey v2.

# Screenshots

| Main                                                                                     | Settings                                                                                     |
| ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| ![Main](https://github.com/user-attachments/assets/5922e71c-1ed7-4c45-8b9b-b22eb2264cb5) | ![Settings](https://github.com/user-attachments/assets/dcd5b382-726b-4d21-9b0d-9a8cddce3f5c) |

# FAQ

### Is it detected?

> I have not been banned while using this since I started developing it.

### Does it work in Full Screen?

> Yes, it works with all screen modes, including Full Screen.

### "Drop BST" is not working

> Ensure you are in a CEO Organization.
> 
> There is a known bug in GTA:O where "SecuroServ CEO" says [“SecuroServ is currently unavailable. Please try again later”](https://github.com/user-attachments/assets/e8676a8f-99f6-4999-a74d-0d6de2b60f90).
>
> There is a known bug in GTA:O where "Drop Bull Shark" says [“You have hit the drop limit for this item”](https://github.com/user-attachments/assets/fa1e7cee-9e11-491e-b824-0a9ca1c20ce2).

### "Reload All Weapons" is not working

> There is a known bug in GTA:O where "Full Ammo" says [“You are unable to purchase ammo at this time”](https://github.com/user-attachments/assets/c9e0b3e6-7da5-4a05-a886-74fc1fbcc26a).

### "Thermal Vision" is not working

> There is a known bug in GTA:O where your Dual/Quad Lens Combat Helmet doesn't appear in "Interaction Menu" > "Accessories" > "Helmets" even though you're wearing it.

### "Reload All Weapons" / "Thermal Vision" sometimes fails

> If you are NOT in a CEO/MC, there is a known bug in GTA:O where "Register as a Boss" may sometimes [randomly be hidden from the Interaction Menu](https://github.com/user-attachments/assets/2bc88def-a270-40ab-bbc8-7cbfc5362a1c).<br>
> I highly recommend using the "Reload All Weapons" macro ONLY when you're in a CEO/MC, as using it outside may change your character's appearance and result in being disconnected from the session.

### Macros are not working consistently

> Try selecting a slower "Macro Speed".<br>
> Your computer's specs or a generally slow session might be affecting the macro's consistency.

### Can we use Hotkey Combinations?

> Yes, you can! For more information, refer to the [AutoHotkey Modifier Keys](https://www.autohotkey.com/docs/v2/KeyList.htm#modifier).<br>
> For example, the combination `CTRL+F1` corresponds to `<^F1`

# Known Bug (unlikely to be fixed)

- Macros are running slower then other similar AHK scripts, I still don't understand why.
- The macro does not consistently abort when the following stop keys are <ins>**quickly**</ins> pressed:<br>
`LButton`, `RButton`, `Enter`, `Escape` and `Backspace`<br>
While this currently randomely works, the implementation is not optimized.<br>
I recommend holding any of these keys down for a full second for it to works every time.

# TODO

- Load/Save `Settings.ini` file
- Add each of the following macros:
  - Anti-Kick
  - Spam Clipboard
  - Spam Rocket
  - Spam Sniper
  - Spam Pistol

# Credits
[.Gangsta](https://socialclub.rockstargames.com/member/.Gangsta/) - Assisted me with testing and provided new ideas.
