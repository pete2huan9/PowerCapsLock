#Requires AutoHotkey v2.0

; ==========================================================
; 模块名称：NumpadAlwaysNumbers.ahk
; 描述：保持 NumLock LED 关闭，同时映射小键盘按键输出数字
; ==========================================================

; 1. 同步 NumLock 状态函数
SyncNumpadState() {
    if (Config.NumpadAlwaysNumbers) {
        SetNumLockState "AlwaysOff"
    } else {
        SetNumLockState "On"
    }
}

; 初始化 SetNumLockState
SyncNumpadState()

; 2. 当 NumpadAlwaysNumbers 模块启用时，重映射物理小键盘按键为对应数字和符号
#HotIf Config.NumpadAlwaysNumbers

NumpadIns::Send "0"
NumpadEnd::Send "1"
NumpadDown::Send "2"
NumpadPgDn::Send "3"
NumpadLeft::Send "4"
NumpadClear::Send "5"   
NumpadRight::Send "6"
NumpadHome::Send "7"
NumpadUp::Send "8"
NumpadPgUp::Send "9"
NumpadDel::Send "."

#HotIf
