import SwiftUI

@main
struct MacorderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { } // Empty scene to prevent automatic window creation
    }
}
