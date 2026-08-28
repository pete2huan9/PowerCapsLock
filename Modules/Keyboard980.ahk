#Requires AutoHotkey v2.0

; ==========================================================
; 模块名称：Keyboard980.ahk (980 配列键盘增强)
; 描述：针对 98 键配列优化：长按 PgUp 触发 Home，长按 PgDn 触发 End
; ==========================================================

#HotIf Config.Keyboard980

; --- 1. PgUp: 短按为翻页，长按 (>250ms) 为 Home ---
*$PgUp::
{
    ; 等待松开按键，超时 250ms
    if !KeyWait("PgUp", "T0.25") {
        ; 长按：发送 Home (保留 Shift/Ctrl 等修饰键)
        Send "{Blind}{Home}"
        KeyWait "PgUp" ; 等待物理按键抬起，防止按住时自动重复
    } else {
        ; 短按：正常发送 PgUp
        Send "{Blind}{PgUp}"
    }
}

; --- 2. PgDn: 短按为翻页，长按 (>250ms) 为 End ---
*$PgDn::
{
    ; 等待松开按键，超时 250ms
    if !KeyWait("PgDn", "T0.2") {
        ; 长按：发送 End (保留 Shift/Ctrl 等修饰键)
        Send "{Blind}{End}"
        KeyWait "PgDn" ; 等待物理按键抬起，防止按住时自动重复
    } else {
        ; 短按：正常发送 PgDn
        Send "{Blind}{PgDn}"
    }
}

#HotIf
