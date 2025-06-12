//
//  MacorderApp.swift
//  Macorder
//
//  Created by Keyu Chen on 6/9/25.
//

import SwiftUI

@main
struct MacorderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
