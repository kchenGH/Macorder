import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let recorder = EventRecorder()
    let hotkeyManager = HotkeyManager.shared
    var isRecording = false
    var isPlaying = false
    func applicationDidFinishLaunching(_ notification: Notification) {
        hotkeyManager.onToggleRecord = {
            self.isRecording.toggle()
            self.isRecording ? self.recorder.start() : self.recorder.stop()
        }
        
        hotkeyManager.onTogglePlayback = {
            self.isPlaying.toggle()
            if self.isPlaying {
                self.recorder.playback()
                self.isPlaying = false
            }
        }
        
        hotkeyManager.startMonitoring()
        print("🚀 Hotkeys ready: ⌃⌘R = record, ⌃⌘P = playback")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.stopMonitoring()
    }
}
