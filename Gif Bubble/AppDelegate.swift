//
//  AppDelegate.swift
//  Gif Bubble
//
//  Created by Xinhong LIU on 7/9/21.
//

import SwiftUI
import AppKit
import SDWebImage

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusBar: NSStatusBar!
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let imageCache = SDImageCache()
        imageCache.config.maxDiskSize = 1
        imageCache.config.shouldCacheImagesInMemory = false
        imageCache.config.shouldUseWeakMemoryCache = true
        SDImageCachesManager.shared.caches = [imageCache]
        SDWebImageManager.defaultImageCache = SDImageCachesManager.shared

        popover = NSPopover.init()
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)

        if let statusBarButton = statusItem.button {
            statusBarButton.title = "GIF"
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }

        popover.contentSize = NSSize(width: 620, height: 820)
        popover.delegate = self
    }

    @objc func togglePopover(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            NSApplication.shared.activate(ignoringOtherApps: true)
            popover.contentViewController = NSHostingController(rootView: ContentView())
            popover.behavior = .transient
            popover.show(relativeTo: statusItem.button!.frame, of: statusItem.button!, preferredEdge: NSRectEdge.maxY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func popoverDidClose(_ notification: Notification) {
        popover.contentViewController = nil
    }

    func popoverDidShow(_ notification: Notification) {
    }
}
