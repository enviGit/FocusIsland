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
        appState.isHovered || appState.isPopoverOpen
    }

    var body: some View {
        HStack(spacing: 6) {
            if !appState.isActive {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                if isExpanded {
                    Text("Inactive")
                        .font(.system(size: 11, weight: .medium))
                        .fixedSize(horizontal: true, vertical: false)
                }
            } else {
                if isExpanded {
                    Text(appState.taskName.isEmpty ? "Focusing" : appState.taskName)
                        .font(.system(size: 11, weight: .medium))
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .bold))
                    
                    Text(appState.formattedTime)
                        .font(.system(size: 11, weight: .medium))
                        .monospacedDigit()
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 20)
        .fixedSize()
        .foregroundStyle(.white)
        .background(
            Capsule()
                .fill(appState.isActive ? activeColor : Color.gray.opacity(0.4))
        )
        .clipShape(Capsule())
        .contentShape(Capsule())
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
