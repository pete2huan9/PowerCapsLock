#Requires AutoHotkey v2.0

; ==============================================================================
; 模块名称：WindowManager.ahk (Power-Rectangle 终极拓扑与分屏版)
; 核心逻辑：
; 1. 触发条件：Ctrl + CapsLock 按住触发
; 2. 方向键 & Enter：1/2 屏分屏与智能最大化/还原
; 3. D/F/G/E/T：1/3 与 2/3 三分屏与三分之二列式分屏
; ==============================================================================

global WindowHistory := Map()

; --- 1. 核心判定逻辑 ---
#HotIf GetKeyState("Ctrl", "P") && GetKeyState("CapsLock", "P") && Config.WindowManager

; 1/2 屏与最大化
*Left::WM_DirectionalMove("Left")
*Right::WM_DirectionalMove("Right")
*Up::WM_DirectionalMove("Up")
*Down::WM_DirectionalMove("Down")
*Enter::WM_SmartToggleMaximize()

; 1/3 与 2/3 列式分屏 (D: 左1/3, F: 中1/3, G: 右1/3, E: 左2/3, T: 右2/3)
*d::WM_ColumnFraction("Left1_3")
*f::WM_ColumnFraction("Center1_3")
*g::WM_ColumnFraction("Right1_3")
*e::WM_ColumnFraction("Left2_3")
*t::WM_ColumnFraction("Right2_3")

#HotIf

; --- 2. 核心执行引擎：方向键 1/2 屏分屏 ---
WM_DirectionalMove(Dir) {
    ActiveWin := WinActive("A")
    if !ActiveWin
        return

    Monitors := WM_GetSortedMonitors()

    if (WinGetMinMax(ActiveWin) = 1) {
        snapInfo := WM_GetCurrentMonitorGrid(ActiveWin, Monitors)
        sm := snapInfo.Mon
        WinRestore(ActiveWin)
        
        if (Dir = "Left") {
            WinMove(sm.L, sm.T, sm.W / 2, sm.H, ActiveWin)
            return
        } 
        else if (Dir = "Right") {
            WinMove(sm.L + sm.W / 2, sm.T, sm.W / 2, sm.H, ActiveWin)
            return
        }
        else {
            return 
        }
    }

    mInfo := WM_GetCurrentMonitorGrid(ActiveWin, Monitors)
    m := mInfo.Mon
    CurIdx := mInfo.Idx

    WinGetPos(&X, &Y, &W, &H, ActiveWin)
    HalfW := m.W / 2
    HalfH := m.H / 2

    Tol := 50
    isLeftEdge   := Abs(X - m.L) < Tol
    isRightEdge  := Abs((X + W) - m.R) < Tol
    isTopEdge    := Abs(Y - m.T) < Tol
    isBottomEdge := Abs((Y + H) - m.B) < Tol

    isFullHeight := isTopEdge && isBottomEdge
    isLeftHalf   := isLeftEdge && isFullHeight && !isRightEdge
    isRightHalf  := isRightEdge && isFullHeight && !isLeftEdge
    
    isTL := isLeftEdge && isTopEdge && !isBottomEdge && !isRightEdge
    isBL := isLeftEdge && isBottomEdge && !isTopEdge && !isRightEdge
    isTR := isRightEdge && isTopEdge && !isBottomEdge && !isLeftEdge
    isBR := isRightEdge && isBottomEdge && !isTopEdge && !isLeftEdge

    isQuarter := isTL || isBL || isTR || isBR
    isHalf    := isLeftHalf || isRightHalf

    if (isQuarter) {
        if (Dir = "Left") {
            if (isTR)
                WinMove(m.L, m.T, HalfW, HalfH, ActiveWin) 
            else if (isBR)
                WinMove(m.L, m.T + HalfH, HalfW, HalfH, ActiveWin) 
            else if (isTL || isBL)
                WinMove(m.L, m.T, HalfW, m.H, ActiveWin) 
        }
        else if (Dir = "Right") {
            if (isTL)
                WinMove(m.L + HalfW, m.T, HalfW, HalfH, ActiveWin) 
            else if (isBL)
                WinMove(m.L + HalfW, m.T + HalfH, HalfW, HalfH, ActiveWin) 
            else if (isTR || isBR)
                WinMove(m.L + HalfW, m.T, HalfW, m.H, ActiveWin) 
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
    else if (isHalf) {
        if (Dir = "Left") {
            if (isRightHalf) {
                WinMove(m.L, m.T, HalfW, m.H, ActiveWin) 
            } else if (isLeftHalf) {
                if (CurIdx > 1) {
                    prevM := Monitors[CurIdx - 1]
                    WinRestore(ActiveWin)
                    tX := prevM.L + prevM.W/2
                    WinMove(tX, prevM.T, , , ActiveWin) 
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
                    WinMove(nextM.L, nextM.T, , , ActiveWin) 
                    WinMove(nextM.L, nextM.T, nextM.W/2, nextM.H, ActiveWin) 
                }
            }
        }
        else if (Dir = "Up" || Dir = "Down") {
            if (isLeftHalf)
                WinMove(m.L, (Dir="Up" ? m.T : m.T + HalfH), HalfW, HalfH, ActiveWin) 
            else
                WinMove(m.L + HalfW, (Dir="Up" ? m.T : m.T + HalfH), HalfW, HalfH, ActiveWin) 
        }
    }
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

; --- 3. 1/3 与 2/3 列式分屏 ---
WM_ColumnFraction(Fraction) {
    ActiveWin := WinActive("A")
    if !ActiveWin
        return

    if (WinGetMinMax(ActiveWin) = 1)
        WinRestore(ActiveWin)

    Monitors := WM_GetSortedMonitors()
    mInfo := WM_GetCurrentMonitorGrid(ActiveWin, Monitors)
    m := mInfo.Mon

    W1_3 := m.W / 3
    W2_3 := (m.W * 2) / 3

    switch Fraction {
        case "Left1_3":   WinMove(m.L, m.T, W1_3, m.H, ActiveWin)
        case "Center1_3": WinMove(m.L + W1_3, m.T, W1_3, m.H, ActiveWin)
        case "Right1_3":  WinMove(m.L + 2 * W1_3, m.T, W1_3, m.H, ActiveWin)
        case "Left2_3":   WinMove(m.L, m.T, W2_3, m.H, ActiveWin)
        case "Right2_3":  WinMove(m.L + W1_3, m.T, W2_3, m.H, ActiveWin)
    }
}

; --- 4. 智能最大化/还原与记忆缩放 ---
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

; --- 5. 空间拓扑工具函数 ---
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
        dist := Sqrt((midX - closestX)**2 + (midY - closestY)**2)
        if (dist < minDist) {
            minDist := dist
            closestIdx := i
        }
    }
    return {Idx: closestIdx, Mon: Monitors[closestIdx]}
}