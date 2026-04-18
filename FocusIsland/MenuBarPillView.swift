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

    var isExpanded: Bool {
        appState.isHovered && !appState.isPopoverOpen
    }
    
    private func textWidth(_ text: String) -> CGFloat {
        let font = NSFont.systemFont(ofSize: 11, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }

    var body: some View {
        HStack(spacing: appState.isActive ? 6 : 0) {
            if !appState.isActive {
                Image(systemName: "moon.fill")
                    .font(.system(size: 14, weight: .regular))
                    .frame(width: 18)
            } else {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                
                if isExpanded {
                    let text = appState.taskName.isEmpty ? "Focusing" : appState.taskName
                    let dynamicWidth = min(textWidth(text), 180)
                    
                    Text(text)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: dynamicWidth, alignment: .leading)
                } else {
                    Text(appState.formattedTime)
                        .font(.system(size: 11, weight: .medium))
                        .monospacedDigit()
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, appState.isActive ? 8 : 8)
        .frame(height: 23)
        .fixedSize(horizontal: true, vertical: false)
        .foregroundStyle(appState.isActive ? .white : .primary)
        .background(
            Group {
                if appState.isActive {
                    Capsule()
                        .fill(activeColor)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(appState.isPopoverOpen ? Color.primary.opacity(0.06) : Color.clear)
                }
            }
        )
        .contentShape(Rectangle())
        .animation(.spring(duration: 0.25, bounce: 0), value: isExpanded)
        .animation(.spring(duration: 0.25, bounce: 0), value: appState.isActive)
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
