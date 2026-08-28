#Requires AutoHotkey v2.0

; ==========================================================
; 模块名称：InputMethod.ahk (中日输入法底层逻辑)
; ==========================================================

; --- 1. 核心函数：中日两点强跳 (闪现逻辑) ---
WM_ToggleIME() {
    if (!Config.InputMethod)
        return
    ; 显式获取当前语言 ID
    currentLang := WM_GetCurrentLangID()
    
    ; [非中文] -> [一键闪现到中文 (0x0804)]
    if (currentLang != 0x0804) { 
        PostMessage(0x50, 0, 0x0804, , "A") 
        ShowStatus("微软拼音")
    } 
    ; [中文] -> [一键闪现到日语 (0x0411) 并激活 あ]
    else { 
        PostMessage(0x50, 0, 0x0411, , "A") 
        Sleep(200)
        try {
            if (targetHwnd := WinActive("A")) {
                DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", targetHwnd, "Ptr")
                ; 发送消息激活日语 Hiragana 模式 (0x10)
                SendMessage(0x0283, 0x006, 0x10, , "ahk_id " DefaultIMEWnd)
            }
        }
        ShowStatus("日本語 [あ]")
    }
}

; --- 2. 辅助工具函数：获取当前语言代码 ---
WM_GetCurrentLangID() {
    try {
        targetHwnd := WinActive("A")
        if !targetHwnd
            return 0
        
        threadID := DllCall("GetWindowThreadProcessId", "Ptr", targetHwnd, "Ptr", 0)
        layout := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
        ; 返回低 16 位即为 Language ID
        return layout & 0xFFFF
    } catch {
        return 0
    }
}