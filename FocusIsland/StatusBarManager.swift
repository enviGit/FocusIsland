//
//  StatusBarManager.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import SwiftUI
import AppKit
import SwiftData

class TrackingHostingView<Content: View>: NSHostingView<Content> {
    var onHover: ((Bool) -> Void)?
    private var trackingArea: NSTrackingArea?
    
    private var hoverWorkItem: DispatchWorkItem?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupTrackingArea()
    }

    private func setupTrackingArea() {
        if let existing = trackingArea {
            self.removeTrackingArea(existing)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        let newArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        
        self.addTrackingArea(newArea)
        self.trackingArea = newArea
    }

    override func mouseEntered(with event: NSEvent) {
        hoverWorkItem?.cancel()
        onHover?(true)
    }

    override func mouseExited(with event: NSEvent) {
        hoverWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.onHover?(false)
        }
        hoverWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }
}

class StatusBarManager: NSObject, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let appState = AppState()

    init(modelContainer: ModelContainer) {
        super.init()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            let viewToHost = MenuBarPillView().environmentObject(appState)
            let hostingView = TrackingHostingView(rootView: viewToHost)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            
            hostingView.onHover = { [weak self] isHovering in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    self?.appState.isHovered = isHovering
                }
            }
            
            button.addSubview(hostingView)
            
            NSLayoutConstraint.activate([
                hostingView.topAnchor.constraint(equalTo: button.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor)
            ])
            
            button.action = #selector(handleStatusItemClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 450)
        popover?.behavior = .transient
        popover?.delegate = self
        
        let popoverView = TodaySessionsView()
            .environmentObject(appState)
            .modelContainer(modelContainer)
            
        popover?.contentViewController = NSHostingController(rootView: popoverView)
    }

    @objc func handleStatusItemClick() {
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }
    
    func popoverDidClose(_ notification: Notification) {
        withAnimation(.spring(duration: 0.25, bounce: 0)) {
            appState.isPopoverOpen = false
        }
    }

    func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                appState.isPopoverOpen = true
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings...", action: nil, keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FocusIsland", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
}
