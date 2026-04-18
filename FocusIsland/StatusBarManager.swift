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
    var onClick: ((NSEvent) -> Void)?
    
    private var trackingArea: NSTrackingArea?
    private var hoverWorkItem: DispatchWorkItem?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupTrackingArea()
    }
    
    override func layout() {
        super.layout()
        NotificationCenter.default.post(name: NSNotification.Name("UpdatePopoverPosition"), object: nil)
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
    
    override func mouseDown(with event: NSEvent) {
        onClick?(event)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        onClick?(event)
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
                withAnimation(.spring(duration: 0.25, bounce: 0)) {
                    self?.appState.isHovered = isHovering
                }
            }
            
            hostingView.onClick = { [weak self] event in
                if event.type == .rightMouseDown {
                    self?.showContextMenu()
                } else {
                    self?.togglePopover()
                }
            }
            
            button.addSubview(hostingView)
            
            NSLayoutConstraint.activate([
                hostingView.topAnchor.constraint(equalTo: button.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor)
            ])
            
            button.action = nil
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 330, height: 480)
        popover?.behavior = .transient
        popover?.delegate = self
        
        let popoverView = TodaySessionsView()
            .environmentObject(appState)
            .modelContainer(modelContainer)
            
        popover?.contentViewController = NSHostingController(rootView: popoverView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePopoverPosition), name: NSNotification.Name("UpdatePopoverPosition"), object: nil)
    }
    
    @objc func updatePopoverPosition() {
        if let button = statusItem?.button, popover?.isShown == true {
            let rightEdge = NSRect(x: button.bounds.width - 4, y: 0, width: 4, height: button.bounds.height)
            popover?.positioningRect = rightEdge
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
                let rightEdge = NSRect(x: button.bounds.width - 4, y: 0, width: 4, height: button.bounds.height)
                popover?.show(relativeTo: rightEdge, of: button, preferredEdge: .minY)
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
