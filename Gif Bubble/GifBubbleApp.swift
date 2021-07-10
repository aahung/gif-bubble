//
//  Gif_BubbleApp.swift
//  Gif Bubble
//
//  Created by Xinhong LIU on 7/9/21.
//

import SwiftUI

@main
struct GifBubbleApp: App {
    // swiftlint:disable weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                EmptyView()
            }
            .hidden()
        }
    }
}
