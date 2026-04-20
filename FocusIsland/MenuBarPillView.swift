//
//  MenuBarPillView.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import SwiftUI

struct MenuBarPillView: View {
    @EnvironmentObject var appState: AppState
    let activeColor = Color(hex: 0x34C759)
    
    var shouldShowTaskName: Bool {
        appState.isHovered || appState.isPopoverOpen
    }
    
    var artificialHold: Bool {
        appState.isPopoverOpen && !appState.isActive && !appState.taskName.isEmpty
    }
    
    var isActiveState: Bool {
        appState.isActive || artificialHold
    }

    private func textWidth(_ text: String) -> CGFloat {
        let font = NSFont.systemFont(ofSize: 11, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }
    
    var textContentWidth: CGFloat {
        if !isActiveState { return 0 }
        
        let timeWidth = textWidth(appState.formattedTime) + 2
        
        if shouldShowTaskName {
            let text = appState.taskName.isEmpty ? "Focusing" : appState.taskName
            let taskWidth = min(textWidth(text), 180)
            return max(timeWidth, taskWidth)
        } else {
            return timeWidth
        }
    }
    
    private var backgroundColor: Color {
        if appState.isActive { return activeColor }
        if artificialHold { return Color.gray.opacity(0.5) }
        return appState.isPopoverOpen ? Color.primary.opacity(0.15) : Color.clear
    }

    var body: some View {
        HStack(spacing: isActiveState ? 6 : 0) {
            
            ZStack {
                Image(systemName: "moon.fill")
                    .font(.system(size: 14, weight: .regular))
                    .opacity(!isActiveState ? 1.0 : 0.0)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                    .opacity(isActiveState ? 1.0 : 0.0)
            }
            .frame(width: 18)
            
            ZStack(alignment: .leading) {
                let text = appState.taskName.isEmpty ? "Focusing" : appState.taskName
                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .fixedSize(horizontal: true, vertical: false)
                    .opacity((shouldShowTaskName && isActiveState) ? 1.0 : 0.0)
                
                Text(appState.formattedTime)
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .fixedSize(horizontal: true, vertical: false)
                    .opacity((!shouldShowTaskName && isActiveState) ? 1.0 : 0.0)
            }
            .frame(width: textContentWidth, alignment: .leading)
            .clipped()
        }
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .fill(backgroundColor)
        )
        .fixedSize(horizontal: true, vertical: false)
        .foregroundStyle(isActiveState ? .white : .primary)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.25), value: shouldShowTaskName)
        .animation(.easeInOut(duration: 0.25), value: isActiveState)
        .animation(.easeInOut(duration: 0.25), value: textContentWidth)
        .animation(.easeInOut(duration: 0.25), value: appState.isActive)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
