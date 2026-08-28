#Requires AutoHotkey v2.0

; ==========================================================
; 模块名称：VimNavigation.ahk (CapsLock 虚拟层与导航)
; ==========================================================

; --- 1. CapsLock 虚拟层 (按住触发) ---
#HotIf GetKeyState("CapsLock", "P") && Config.VimNavigation

; Vim 方向键导航
*k::Send "{Blind}{Up}"
*h::Send "{Blind}{Left}"
*j::Send "{Blind}{Down}"
*l::Send "{Blind}{Right}"
*i::Send "{Blind}{End}"
*u::Send "{Blind}{Home}"

#HotIf GetKeyState("CapsLock", "P") && Config.InputMethod

; 调用 InputMethod.ahk 中的强切函数
*Space::WM_ToggleIME() 

#HotIf

; --- 2. 屏蔽系统干扰 ---
#Space::return

; --- 3. CapsLock 物理键逻辑 (长按/短按) ---
*CapsLock::
{
    start_time := A_TickCount
    KeyWait "CapsLock"
    
    ; 如果按住期间触发了 HJKL 或 Space 等键，不执行短按逻辑
    if (A_PriorKey != "CapsLock")
        return

    duration := A_TickCount - start_time

    if (duration > 300) {
        ; 【长按】：大写锁定
        SetCapsLockState(GetKeyState("CapsLock", "T") ? "AlwaysOff" : "AlwaysOn")
        ShowStatus("CapsLock: " (GetKeyState("CapsLock", "T") ? "ON" : "OFF"))
    }
    else {
        ; 【短按】：中英切换 (仅在 InputMethod 模块启用且中文布局下有效)
        if (Config.InputMethod) {
            langID := WM_GetCurrentLangID()
            if (langID == 0x0804) { 
                Send "^{Space}"
                ShowStatus("中 / En")
            }
        }
    }
}