/*
  _____                            _____                _ lock 
 |  __ \                          / ____|              | |      
 | |__) |____      _____ _ __    | |     __ _ _ __  ___| |      
 |  ___/ _ \ \ /\ / / _ \ '__|   | |    / _` | '_ \/ __| |      
 | |  | (_) \ V  V /  __/ |      | |___| (_| | |_) \__ \ |____  
 |_|   \___/ \_/\_/ \___|_|       \_____\__,_| .__/|___/______| 
                                             | |                
                                             |_|                
*/

#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================================
; 项目名称：PowerCapsLock
; 描述：利用 Capslock 作为热键的空间管理以及输入增强 (双语中英 GUI 版)
; 作者：Peter
; 许可证：GNU General Public License v3.0 (GPLv3)
; 版本：0.4 (2026-08)
; ==========================================================

; --- 1. 管理员权限自动提权 ---
if !A_IsAdmin {
    try {
        if A_IsCompiled
            Run('*RunAs "' A_ScriptFullPath '" /restart')
        else
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
    }
    ExitApp()
}

; --- 2. 全局环境优化与配置读取 ---
SetWorkingDir A_ScriptDir
ProcessSetPriority "High"
SetWinDelay 0
InstallKeybdHook()
SetCapsLockState "AlwaysOff" 
SetStoreCapsLockMode False 

; 阻止系统在空闲时挂起脚本进程
DllCall("kernel32\SetThreadExecutionState", "uint", 0x80000001)

; 配置管理对象与 Ini 读写
ConfigFile := A_ScriptDir "\Config.ini"
global Config := {
    VimNavigation: 1,
    WindowManager: 1,
    InputMethod: 1,
    NumpadAlwaysNumbers: 1,
    Keyboard980: 1,
    Theme: "Dark",
    Language: "zh"
}

; 语言文本字典 (i18n Dictionary)
global LangMap := Map(
    "zh", Map(
        "Title", "⚡ PowerCapsLock 控制中心",
        "Subtitle", "功能模块管理与界面设置 (自动保存)",
        "GrpModules", " 核心功能模块开关 ",
        "chkVim", "🔤 Vim 光标导航 (CapsLock + H/J/K/L/I/U)",
        "chkWin", "🪟 窗口分屏管理 (CapsLock + 箭头 / Enter)",
        "chkIME", "🌐 中日/中英输入法切换 (CapsLock + Space / 短按)",
        "chkNum", "🔢 小键盘常驻数字 (关灯优先输出数字)",
        "chk980", "⌨️ 980 键盘增强 (长按 PgUp->Home, PgDn->End)",
        "GrpSettings", " 快捷键与界面设置 ",
        "Shortcuts", "• Ctrl + Alt + P : 打开 / 隐藏本控制面板`n• Ctrl + Alt + R : 重新加载 PowerCapsLock`n• 双击托盘图标 : 呼出控制面板",
        "BtnThemeDark", "☀️ 浅色主题",
        "BtnThemeLight", "🌙 深色主题",
        "BtnLang", "🌐 English",
        "BtnEnableAll", "全部开启",
        "BtnDisableAll", "全部关闭",
        "BtnSaveClose", "保存并隐藏",
        "TrayTip", "PowerCapsLock 系统运行中 (双击打开控制面板)",
        "TrayOpen", "⚡ 打开控制面板 (&O)",
        "TrayReload", "🔄 重新加载 (&R)",
        "TrayExit", "❌ 退出 PowerCapsLock (&X)",
        "StatusUpdated", "设置已更新并实时生效",
        "StatusThemeDark", "主题已切换为: 深色模式 🌙",
        "StatusThemeLight", "主题已切换为: 浅色模式 ☀️",
        "StatusLang", "语言已切换为: English 🇺🇸",
        "ReloadMsg", "PowerCapsLock: 重新注入能量..."
    ),
    "en", Map(
        "Title", "⚡ PowerCapsLock Dashboard",
        "Subtitle", "Module Controls && UI Settings (Auto-Saved)",
        "GrpModules", " Core Feature Modules ",
        "chkVim", "🔤 Vim Navigation (CapsLock + H/J/K/L/I/U)",
        "chkWin", "🪟 Window Manager (CapsLock + Arrows / Enter)",
        "chkIME", "🌐 Input Method Switcher (CapsLock + Space / Tap)",
        "chkNum", "🔢 Numpad Always Numbers (Keep NumLock OFF)",
        "chk980", "⌨️ 980 (Hold PgUp->Home, PgDn->End)",
        "GrpSettings", " Shortcuts && Appearance ",
        "Shortcuts", "• Ctrl + Alt + P : Open / Hide Dashboard`n• Ctrl + Alt + R : Reload PowerCapsLock`n• Double-click Tray Icon : Open Dashboard",
        "BtnThemeDark", "☀️ Light Theme",
        "BtnThemeLight", "🌙 Dark Theme",
        "BtnLang", "🌐 简体中文",
        "BtnEnableAll", "Enable All",
        "BtnDisableAll", "Disable All",
        "BtnSaveClose", "Save && Hide",
        "TrayTip", "PowerCapsLock is running (Double-click to open)",
        "TrayOpen", "⚡ Open Dashboard (&O)",
        "TrayReload", "🔄 Reload (&R)",
        "TrayExit", "❌ Exit PowerCapsLock (&X)",
        "StatusUpdated", "Settings updated & applied instantly",
        "StatusThemeDark", "Theme switched to: Dark Mode 🌙",
        "StatusThemeLight", "Theme switched to: Light Mode ☀️",
        "StatusLang", "语言已切换为: 中文 🇨🇳",
        "ReloadMsg", "PowerCapsLock: Reloading..."
    )
)

GetText(key) {
    lang := Config.Language
    if (!LangMap.Has(lang))
        lang := "zh"
    return LangMap[lang][key]
}

LoadConfig() {
    global Config, ConfigFile
    Config.VimNavigation := Number(IniRead(ConfigFile, "Modules", "VimNavigation", "1"))
    Config.WindowManager := Number(IniRead(ConfigFile, "Modules", "WindowManager", "1"))
    Config.InputMethod := Number(IniRead(ConfigFile, "Modules", "InputMethod", "1"))
    Config.NumpadAlwaysNumbers := Number(IniRead(ConfigFile, "Modules", "NumpadAlwaysNumbers", "1"))
    Config.Keyboard980 := Number(IniRead(ConfigFile, "Modules", "Keyboard980", "1"))
    Config.Theme := IniRead(ConfigFile, "Settings", "Theme", "Dark")
    Config.Language := IniRead(ConfigFile, "Settings", "Language", "zh")
}

SaveConfig() {
    global Config, ConfigFile
    IniWrite(Config.VimNavigation, ConfigFile, "Modules", "VimNavigation")
    IniWrite(Config.WindowManager, ConfigFile, "Modules", "WindowManager")
    IniWrite(Config.InputMethod, ConfigFile, "Modules", "InputMethod")
    IniWrite(Config.NumpadAlwaysNumbers, ConfigFile, "Modules", "NumpadAlwaysNumbers")
    IniWrite(Config.Keyboard980, ConfigFile, "Modules", "Keyboard980")
    IniWrite(Config.Theme, ConfigFile, "Settings", "Theme")
    IniWrite(Config.Language, ConfigFile, "Settings", "Language")
}

LoadConfig()

; --- 3. 模块引用 ---
#Include "Modules\InputMethod.ahk"         ; 输入法闪现引擎
#Include "Modules\VimNavigation.ahk"       ; Vim 内容导航层
#Include "Modules\WindowManager.ahk"       ; 边界反馈空间引擎
#Include "Modules\NumpadAlwaysNumbers.ahk" ; 小键盘数字常驻模块
#Include "Modules\Keyboard980.ahk"         ; 980 配列键盘增强 (长按 PgUp/PgDn -> Home/End)

; --- 4. GUI 控制面板动态构建引擎 ---
global MainGui := ""
global chkVim := "", chkWin := "", chkIME := "", chkNum := "", chk980 := ""

BuildGUI() {
    global MainGui, chkVim, chkWin, chkIME, chkNum, chk980
    
    if (IsObject(MainGui)) {
        try MainGui.Destroy()
    }
    
    isDark := (Config.Theme = "Dark")
    
    bgColor    := isDark ? "0x202020" : "0xF9F9F9"
    titleColor := isDark ? "c0x60A5FA" : "c0x005A9E"
    subColor   := isDark ? "c0xA0A0A0" : "c0x666666"
    textColor  := isDark ? "c0xE0E0E0" : "c0x222222"
    groupColor := isDark ? "c0x60A5FA" : "c0x005A9E"
    
    MainGui := Gui("-MaximizeBox", "PowerCapsLock")
    MainGui.MarginX := 20
    MainGui.MarginY := 20
    MainGui.BackColor := bgColor
    
    ; 开启 Windows 11/10 原生沉浸式暗色标题栏
    hwnd := MainGui.Hwnd
    try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", 20, "int*", isDark ? 1 : 0, "int", 4)
    try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", 19, "int*", isDark ? 1 : 0, "int", 4)
    
    ; --- 1. Header 标题栏 ---
    MainGui.SetFont("s14 bold " titleColor, "Microsoft YaHei UI")
    MainGui.Add("Text", "x20 y15 w420 Center", GetText("Title"))
    MainGui.SetFont("s9 norm " subColor, "Microsoft YaHei UI")
    MainGui.Add("Text", "x20 y+4 w420 Center", GetText("Subtitle"))

    MainGui.Add("Text", "x20 y+10 w420 h1 0x10") ; 分隔线

    ; --- 2. GroupBox 1: 核心功能模块开关 ---
    MainGui.SetFont("s10 bold " groupColor, "Microsoft YaHei UI")
    MainGui.Add("GroupBox", "x20 y95 w420 h185", GetText("GrpModules"))
    
    MainGui.SetFont("s10 norm " textColor, "Microsoft YaHei UI")
    chkVim := MainGui.Add("Checkbox", "x35 y122 w390 Checked" Config.VimNavigation, GetText("chkVim"))
    chkWin := MainGui.Add("Checkbox", "x35 y+8 w390 Checked" Config.WindowManager, GetText("chkWin"))
    chkIME := MainGui.Add("Checkbox", "x35 y+8 w390 Checked" Config.InputMethod, GetText("chkIME"))
    chkNum := MainGui.Add("Checkbox", "x35 y+8 w390 Checked" Config.NumpadAlwaysNumbers, GetText("chkNum"))
    chk980 := MainGui.Add("Checkbox", "x35 y+8 w390 Checked" Config.Keyboard980, GetText("chk980"))

    chkVim.OnEvent("Click", OnModuleToggle)
    chkWin.OnEvent("Click", OnModuleToggle)
    chkIME.OnEvent("Click", OnModuleToggle)
    chkNum.OnEvent("Click", OnModuleToggle)
    chk980.OnEvent("Click", OnModuleToggle)

    ; --- 3. GroupBox 2: 快捷键与主题/语言设置 ---
    MainGui.SetFont("s10 bold " groupColor, "Microsoft YaHei UI")
    MainGui.Add("GroupBox", "x20 y295 w420 h140", GetText("GrpSettings"))
    
    MainGui.SetFont("s9 norm " subColor, "Microsoft YaHei UI")
    MainGui.Add("Text", "x35 y322 w390", GetText("Shortcuts"))

    themeText := isDark ? GetText("BtnThemeDark") : GetText("BtnThemeLight")
    btnTheme := MainGui.Add("Button", "x35 y392 w190 h28", themeText)
    btnTheme.OnEvent("Click", (*) => ToggleTheme())

    btnLang := MainGui.Add("Button", "x+10 yp w190 h28", GetText("BtnLang"))
    btnLang.OnEvent("Click", (*) => ToggleLanguage())

    ; --- 4. 底部操作按钮 ---
    MainGui.SetFont("s10 norm", "Microsoft YaHei UI")
    btnEnableAll := MainGui.Add("Button", "x20 y450 w130 h34", GetText("BtnEnableAll"))
    btnDisableAll := MainGui.Add("Button", "x+15 yp w130 h34", GetText("BtnDisableAll"))
    btnSaveClose := MainGui.Add("Button", "x+15 yp w130 h34 Default", GetText("BtnSaveClose"))

    btnEnableAll.OnEvent("Click", (*) => SetAllModules(1))
    btnDisableAll.OnEvent("Click", (*) => SetAllModules(0))
    btnSaveClose.OnEvent("Click", (*) => MainGui.Hide())

    MainGui.OnEvent("Close", (*) => MainGui.Hide())
    
    LoadMyIcon()
}

; 托盘图标及右键菜单
LoadMyIcon(*) {
    iconPath := A_ScriptDir "\icons8-capslock-key-100.ico"
    if FileExist(iconPath) {
        try {
            TraySetIcon(iconPath)
            if IsObject(MainGui) && MainGui.Hwnd {
                hIcon := LoadPicture(iconPath, "w32 h32", &imgType := 0)
                if hIcon
                    SendMessage(0x0080, 1, hIcon, , MainGui.Hwnd)
            }
        }
    }
    A_IconTip := GetText("TrayTip")
}

SetupTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add(GetText("TrayOpen"), (*) => ShowGUI())
    A_TrayMenu.Default := GetText("TrayOpen")
    A_TrayMenu.Add() ; 分隔线
    A_TrayMenu.Add(GetText("TrayReload"), (*) => ReloadScript())
    A_TrayMenu.Add(GetText("TrayExit"), (*) => ExitApp())
}

BuildGUI()
SetupTrayMenu()
OnMessage(DllCall("RegisterWindowMessage", "str", "TaskbarCreated"), LoadMyIcon)

; --- 5. GUI 交互逻辑函数 ---
OnModuleToggle(ctrl, *) {
    global Config
    Config.VimNavigation := chkVim.Value
    Config.WindowManager := chkWin.Value
    Config.InputMethod := chkIME.Value
    Config.NumpadAlwaysNumbers := chkNum.Value
    Config.Keyboard980 := chk980.Value
    
    SaveConfig()
    SyncNumpadState()
    
    ShowStatus(GetText("StatusUpdated"))
}

ToggleTheme() {
    global Config, MainGui
    
    posX := "", posY := ""
    if IsObject(MainGui) && MainGui.Hwnd {
        try WinGetPos(&posX, &posY, , , MainGui.Hwnd)
    }
    
    Config.Theme := (Config.Theme = "Dark") ? "Light" : "Dark"
    SaveConfig()
    
    BuildGUI()
    SetupTrayMenu()
    
    if (posX != "" && posY != "") {
        MainGui.Show("x" posX " y" posY)
    } else {
        MainGui.Show("Center")
    }
    
    ShowStatus(Config.Theme = "Dark" ? GetText("StatusThemeDark") : GetText("StatusThemeLight"))
}

ToggleLanguage() {
    global Config, MainGui
    
    posX := "", posY := ""
    if IsObject(MainGui) && MainGui.Hwnd {
        try WinGetPos(&posX, &posY, , , MainGui.Hwnd)
    }
    
    Config.Language := (Config.Language = "zh") ? "en" : "zh"
    SaveConfig()
    
    BuildGUI()
    SetupTrayMenu()
    
    if (posX != "" && posY != "") {
        MainGui.Show("x" posX " y" posY)
    } else {
        MainGui.Show("Center")
    }
    
    ShowStatus(GetText("StatusLang"))
}

SetAllModules(state) {
    chkVim.Value := state
    chkWin.Value := state
    chkIME.Value := state
    chkNum.Value := state
    chk980.Value := state
    OnModuleToggle(chkVim)
}

ToggleGUI() {
    if IsObject(MainGui) && DllCall("IsWindowVisible", "Ptr", MainGui.Hwnd) {
        MainGui.Hide()
    } else {
        ShowGUI()
    }
}

ShowGUI() {
    if (!IsObject(MainGui)) {
        BuildGUI()
    }
    chkVim.Value := Config.VimNavigation
    chkWin.Value := Config.WindowManager
    chkIME.Value := Config.InputMethod
    chkNum.Value := Config.NumpadAlwaysNumbers
    chk980.Value := Config.Keyboard980
    
    if DllCall("IsWindowVisible", "Ptr", MainGui.Hwnd) {
        MainGui.Show()
    } else {
        MainGui.Show("Center")
    }
}

ReloadScript() {
    ShowStatus(GetText("ReloadMsg"))
    Sleep 400
    Reload()
}

; --- 6. 全局热键定义 ---
; Ctrl + Alt + R：一键重启
^!r::ReloadScript()

; Ctrl + Alt + P：呼出 / 隐藏控制面板 GUI
^!p::ToggleGUI()

; --- 7. 通用辅助函数 ---
ShowStatus(txt) {
    ToolTip(txt)
    SetTimer(() => ToolTip(), -1000)
}