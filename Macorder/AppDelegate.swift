import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let recorder = EventRecorder()
    let hotkeyManager = HotkeyManager.shared
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure proper app activation
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Hotkey setup
        hotkeyManager.onToggleRecord = { [weak self] in
            guard let self = self else { return }
            self.recorder.isRecording ? self.recorder.stop() : self.recorder.start()
        }
        
        hotkeyManager.onTogglePlayback = { [weak self] in
            self?.recorder.playback(loopCount: 1)
        }
        
        hotkeyManager.startMonitoring()
        print("🚀 Hotkeys ready: ^⌘⌘R = record, ^⌘⌘P = playback")
        
        // Window creation
        let contentView = ContentView().environmentObject(recorder)
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 350),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.title = "Macorder"
        window.contentView = NSHostingView(rootView: contentView)
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.stopMonitoring()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
