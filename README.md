# ⚡ PowerCapsLock

[![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2.0-blue.svg)](https://www.autohotkey.com/)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg)](https://www.microsoft.com/)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

**PowerCapsLock** is an advanced AutoHotkey v2 productivity suite that transforms your `CapsLock` key into a multi-layer modal hyper-key for Vim-style navigation, window management, input method switching, and keyboard layout enhancements — complete with a modern, customizable GUI dashboard.

---

## 🌟 Features

- **🎛️ Interactive GUI Control Panel**:
  - Real-time module toggles (enable/disable modules without restarting).
  - **Bilingual UI**: One-click toggle between **English 🇺🇸** and **Simplified Chinese 🇨🇳**.
  - **Theme Support**: Windows 11 Immersive Dark Mode 🌙 and Clean Light Theme ☀️.
  - Position memory (remains where you place it when switching themes or languages).

- **🔤 Vim Navigation Layer** (`Modules/VimNavigation.ahk`):
  - `CapsLock + H / J / K / L`: Left / Down / Up / Right navigation.
  - `CapsLock + U / I`: Home / End navigation.

- **🪟 Smart Window Topology Manager** (`Modules/WindowManager.ahk`):
  - `CapsLock + Left / Right`: Snap active window to Left 1/2 or Right 1/2 half-screen.
  - `CapsLock + Up / Down`: Quarter-screen / vertical snapping.
  - `CapsLock + Enter`: Smart maximize / restore with position memory.
  - Seamless multi-monitor spanning and DPI awareness.

- **🌐 Instant Input Method Switcher** (`Modules/InputMethod.ahk`):
  - `CapsLock + Space`: Instant toggle between Chinese (Microsoft Pinyin) and Japanese (Hiragana).
  - `Short-press CapsLock`: Quick English / Chinese layout toggle.

- **🔢 Numpad Always Numbers** (`Modules/NumpadAlwaysNumbers.ahk`):
  - Forces physical numpad keys to output numbers while keeping the NumLock LED off.

- **⌨️ 980 Keyboard Layout Enhancement** (`Modules/Keyboard980.ahk`):
  - Designed for compact 98-key keyboards:
  - **Hold `PgUp` (> 250ms)**: Triggers `Home`
  - **Hold `PgDn` (> 250ms)**: Triggers `End`
  - Preserves modifier keys (`Shift`, `Ctrl`, `Alt`) for selection and shortcuts.

---

## 🚀 Getting Started

### Option 1: Run Source Code (Recommended for Customization)

1. Download and install [AutoHotkey v2](https://www.autohotkey.com/).
2. Clone or download this repository:
   ```bash
   git clone https://github.com/your-username/PowerCapsLock.git
   ```
3. Double-click `Main.ahk` to start.

### Option 2: Run Standalone Executable

1. Go to the **Releases** tab on the GitHub repository page.
2. Download `PowerCapsLock.exe`.
3. Double-click to run (no AutoHotkey installation required).

---

## ⌨️ Shortcuts Reference

| Shortcut | Action |
| :--- | :--- |
| **`Ctrl` + `Alt` + `P`** | Open / Hide Dashboard GUI |
| **`Ctrl` + `Alt` + `R`** | Reload PowerCapsLock |
| **`CapsLock` + `H/J/K/L`** | Vim Cursor Left / Down / Up / Right |
| **`CapsLock` + `U/I`** | Home / End |
| **`CapsLock` + `Space`** | Chinese ↔ Japanese Input Switch |
| **`CapsLock` + `Arrows`** | Window Half-Screen / Quarter-Screen Snapping |
| **`CapsLock` + `Enter`** | Maximize / Restore Window |
| **Hold `PgUp` / `PgDn`** | Home / End (980 Keyboard Mode) |
| **Double-Click Tray Icon** | Open Dashboard GUI |

---

## 📁 Repository Structure

```
PowerCapsLock/
├── Main.ahk                           # Application entry point, GUI, & tray manager
├── Config.ini                         # Persistent user configuration file
├── icons8-capslock-key-100.ico        # System tray & window icon
└── Modules/
    ├── InputMethod.ahk                # IME switching engine
    ├── VimNavigation.ahk              # Vim navigation layer & CapsLock tap/hold logic
    ├── WindowManager.ahk              # Window topology snapping engine
    ├── NumpadAlwaysNumbers.ahk        # Numpad number lock overrides
    └── Keyboard980.ahk                # 980 layout PgUp/PgDn long-press engine
```

---

## ⚙️ Compilation (.ahk to .exe)

To build your own standalone `.exe`:

1. Open **Ahk2Exe** (bundled with AutoHotkey v2).
2. Set **Source (.ahk)** to `Main.ahk`.
3. Set **Icon (.ico)** to `icons8-capslock-key-100.ico`.
4. Click **Convert**.

---

## 📄 License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

