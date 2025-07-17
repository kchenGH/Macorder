import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let recorder = EventRecorder()
    let hotkeyManager = HotkeyManager.shared
    var window: NSWindow!
    var loopCount: Int = 1
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        let contentView = ContentView(onLoopCountChange: { [weak self] newCount in
            self?.loopCount = newCount
        })
        
        hotkeyManager.onToggleRecord = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.recorder.isRecording ? self.recorder.stop() : self.recorder.start()
            }
        }
        
        hotkeyManager.onTogglePlayback = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.recorder.playback(loopCount: self.loopCount)
            }
        }
        
        hotkeyManager.startMonitoring()
        print("🚀 Hotkeys ready: ^⌘⌘R = record, ^⌘⌘P = playback")
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 350),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Macorder"
        window.contentView = NSHostingView(rootView: contentView.environmentObject(recorder))
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
