#Requires AutoHotkey v2.0

; ==============================================================================
; 模块名称：WindowManager.ahk (Power-Rectangle 终极拓扑版)
; 核心逻辑：
; 1. 绝对状态锁 (拓扑判定法：无视 Chrome 最小宽度强制锁定，只看物理贴边)
; 2. 全屏快照拦截 (彻底消灭 Windows 还原时的幽灵坐标跨屏 Bug)
; 3. 优雅分步跨屏 (解决异构屏幕 DPI 碰撞)
; ==============================================================================

global WindowHistory := Map()

; --- 1. 核心判定逻辑 (完全拦截版) ---
#HotIf GetKeyState("CapsLock", "P") && Config.WindowManager

*Left::WM_DirectionalMove("Left")
*Right::WM_DirectionalMove("Right")
*Up::WM_DirectionalMove("Up")
*Down::WM_DirectionalMove("Down")
*Enter::WM_SmartToggleMaximize()

#HotIf

; --- 2. 核心执行引擎 ---
WM_DirectionalMove(Dir) {
    ActiveWin := WinActive("A")
    if !ActiveWin
        return

    Monitors := WM_GetSortedMonitors()

    ; --------------------------------------------------------------------------
    ; 【全屏独立拦截器】：先快照，后还原，降维打击
    ; --------------------------------------------------------------------------
    if (WinGetMinMax(ActiveWin) = 1) {
        ; 1. 拍照留证：获取全屏时它到底在哪块屏幕
        snapInfo := WM_GetCurrentMonitorGrid(ActiveWin, Monitors)
        sm := snapInfo.Mon
        
        ; 2. 放虎归山：让系统去还原它 (哪怕它的幽灵跨屏了也不怕)
        WinRestore(ActiveWin)
        
        ; 3. 降维打击：无视幽灵坐标，强制把它按在刚才快照屏幕的左/右半边
        if (Dir = "Left") {
            WinMove(sm.L, sm.T, sm.W / 2, sm.H, ActiveWin)
            return ; 执行完毕，提前拦截结束！
        } 
        else if (Dir = "Right") {
            WinMove(sm.L + sm.W / 2, sm.T, sm.W / 2, sm.H, ActiveWin)
            return ; 执行完毕，提前拦截结束！
        }
        else {
            ; 如果全屏时按了 Up/Down，只做 Restore 还原，当做“逃生门”
            return 
        }
    }

    ; --------------------------------------------------------------------------
    ; 常规状态机逻辑 (实体墙与拓扑边缘判定)
    ; --------------------------------------------------------------------------
    
    ; 获取精准的显示器管辖权
    mInfo := WM_GetCurrentMonitorGrid(ActiveWin, Monitors)
    m := mInfo.Mon
    CurIdx := mInfo.Idx

    WinGetPos(&X, &Y, &W, &H, ActiveWin)
    HalfW := m.W / 2
    HalfH := m.H / 2

    ; 计算边缘贴合度 (容差 50px，对付隐形边框)
    Tol := 50
    isLeftEdge   := Abs(X - m.L) < Tol
    isRightEdge  := Abs((X + W) - m.R) < Tol
    isTopEdge    := Abs(Y - m.T) < Tol
    isBottomEdge := Abs((Y + H) - m.B) < Tol

    ; --------------------------------------------------------------------------
    ; 【绝对状态锁：拓扑判定版】(专治 Chrome 最小宽度限制)
    ; --------------------------------------------------------------------------
    isFullHeight := isTopEdge && isBottomEdge

    ; 只要贴住左边 + 上下顶满 + 没贴住右边(非全屏) -> 强制认定为左 1/2 屏
    isLeftHalf  := isLeftEdge && isFullHeight && !isRightEdge
    
    ; 只要贴住右边 + 上下顶满 + 没贴住左边(非全屏) -> 强制认定为右 1/2 屏
    isRightHalf := isRightEdge && isFullHeight && !isLeftEdge
    
    ; 1/4 屏同理：只要卡死在角落，就赋予状态，不再死抠宽高像素
    isTL := isLeftEdge && isTopEdge && !isBottomEdge && !isRightEdge
    isBL := isLeftEdge && isBottomEdge && !isTopEdge && !isRightEdge
    isTR := isRightEdge && isTopEdge && !isBottomEdge && !isLeftEdge
    isBR := isRightEdge && isBottomEdge && !isTopEdge && !isLeftEdge

    isQuarter := isTL || isBL || isTR || isBR
    isHalf    := isLeftHalf || isRightHalf

    ; --------------------------------------------------------------------------
    ; 状态 A：1/4 屏逻辑
    ; --------------------------------------------------------------------------
    if (isQuarter) {
        if (Dir = "Left") {
            if (isTR)
                WinMove(m.L, m.T, HalfW, HalfH, ActiveWin) 
            else if (isBR)
                WinMove(m.L, m.T + HalfH, HalfW, HalfH, ActiveWin) 
            else if (isTL || isBL)
                WinMove(m.L, m.T, HalfW, m.H, ActiveWin) ; 撞左墙变 1/2
        }
        else if (Dir = "Right") {
            if (isTL)
                WinMove(m.L + HalfW, m.T, HalfW, HalfH, ActiveWin) 
            else if (isBL)
                WinMove(m.L + HalfW, m.T + HalfH, HalfW, HalfH, ActiveWin) 
            else if (isTR || isBR)
                WinMove(m.L + HalfW, m.T, HalfW, m.H, ActiveWin) ; 撞右墙变 1/2
        }
        else if (Dir = "Up") {
            if (isBL)
                WinMove(m.L, m.T, HalfW, HalfH, ActiveWin) 
            else if (isBR)
                WinMove(m.L + HalfW, m.T, HalfW, HalfH, ActiveWin) 
        }
        else if (Dir = "Down") {
            if (isTL)
                WinMove(m.L, m.T + HalfH, HalfW, HalfH, ActiveWin) 
            else if (isTR)
                WinMove(m.L + HalfW, m.T + HalfH, HalfW, HalfH, ActiveWin) 
        }
    }
    ; --------------------------------------------------------------------------
    ; 状态 B：竖向 1/2 屏逻辑 (优雅分步跨屏版)
    ; --------------------------------------------------------------------------
    else if (isHalf) {
        if (Dir = "Left") {
            if (isRightHalf) {
                WinMove(m.L, m.T, HalfW, m.H, ActiveWin) 
            } else if (isLeftHalf) {
                if (CurIdx > 1) {
                    prevM := Monitors[CurIdx - 1]
                    WinRestore(ActiveWin)
                    
                    ; --- 优雅解法：先转移阵地，再重塑形态 ---
                    tX := prevM.L + prevM.W/2
                    ; 1. 仅平移 X 和 Y (省略 W 和 H 参数)
                    WinMove(tX, prevM.T, , , ActiveWin) 
                    ; 2. 原地拉伸 W 和 H
                    WinMove(tX, prevM.T, prevM.W/2, prevM.H, ActiveWin) 
                }
            }
        }
        else if (Dir = "Right") {
            if (isLeftHalf) {
                WinMove(m.L + HalfW, m.T, HalfW, m.H, ActiveWin) 
            } else if (isRightHalf) {
                if (CurIdx < Monitors.Length) {
                    nextM := Monitors[CurIdx + 1]
                    WinRestore(ActiveWin)
                    
                    ; --- 优雅解法：先转移阵地，再重塑形态 ---
                    ; 1. 仅平移
                    WinMove(nextM.L, nextM.T, , , ActiveWin) 
                    ; 2. 原地拉伸
                    WinMove(nextM.L, nextM.T, nextM.W/2, nextM.H, ActiveWin) 
                }
            }
        }
        ; --- 1/4 屏垂直切换逻辑 ---
        else if (Dir = "Up" || Dir = "Down") {
            if (isLeftHalf)
                WinMove(m.L, (Dir="Up" ? m.T : m.T + HalfH), HalfW, HalfH, ActiveWin) 
            else
                WinMove(m.L + HalfW, (Dir="Up" ? m.T : m.T + HalfH), HalfW, HalfH, ActiveWin) 
        }
    }
    ; --------------------------------------------------------------------------
    ; 状态 C：游荡窗口兜底
    ; --------------------------------------------------------------------------
    else {
        midX := X + W/2
        isMoreRight := (midX > m.L + HalfW)
        targetX := isMoreRight ? (m.L + HalfW) : m.L 

        if (Dir = "Left")
            WinMove(m.L, m.T, HalfW, m.H, ActiveWin)
        else if (Dir = "Right")
            WinMove(m.L + HalfW, m.T, HalfW, m.H, ActiveWin)
        else if (Dir = "Up")
            WinMove(targetX, m.T, HalfW, HalfH, ActiveWin)
        else if (Dir = "Down")
            WinMove(targetX, m.T + HalfH, HalfW, HalfH, ActiveWin)
    }
}

; --- 3. 记忆缩放逻辑 ---
WM_SmartToggleMaximize() {
    ActiveWin := WinActive("A")
    if !ActiveWin
        return
    if WinGetMinMax(ActiveWin) = 1 {
        if WindowHistory.Has(ActiveWin) {
            h := WindowHistory[ActiveWin]
            WinRestore(ActiveWin)
            WinMove(h.X, h.Y, h.W, h.H, ActiveWin)
        } else WinRestore(ActiveWin)
    } else {
        WinGetPos(&X, &Y, &W, &H, ActiveWin)
        WindowHistory[ActiveWin] := {X:X, Y:Y, W:W, H:H}
        WinMaximize(ActiveWin)
    }
}

; --- 4. 空间拓扑工具函数 ---
WM_GetSortedMonitors() {
    ms := []
    Loop MonitorGetCount() {
        MonitorGetWorkArea(A_Index, &L, &T, &R, &B)
        ms.Push({L:L, T:T, R:R, B:B, W:R-L, H:B-T})
    }
    for i, m in ms {
        loop ms.Length - i {
            if ms[A_Index].L > ms[A_Index+1].L {
                temp := ms[A_Index], ms[A_Index] := ms[A_Index+1], ms[A_Index+1] := temp
            }
        }
    }
    return ms
}

WM_GetCurrentMonitorGrid(hwnd, Monitors) {
    try {
        WinGetPos(&X, &Y, &W, &H, hwnd)
        midX := X + W/2
        midY := Y + H/2
    } catch {
        return {Idx: 1, Mon: Monitors[1]}
    }
    
    for i, mon in Monitors {
        if (midX >= mon.L && midX <= mon.R && midY >= mon.T && midY <= mon.B) {
            return {Idx: i, Mon: mon}
        }
    }
    
    closestIdx := 1
    minDist := 9999999
    for i, mon in Monitors {
        closestX := Max(mon.L, Min(midX, mon.R))
        closestY := Max(mon.T, Min(midY, mon.B))
        ; 修复了 Markdown 复制导致的乘方错误，恢复了 AHK 语法的 **2
        dist := Sqrt((midX - closestX)**2 + (midY - closestY)**2)
        if (dist < minDist) {
            minDist := dist
            closestIdx := i
        }
    }
    return {Idx: closestIdx, Mon: Monitors[closestIdx]}
}