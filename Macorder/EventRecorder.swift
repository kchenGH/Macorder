import Foundation
import Cocoa

class EventRecorder {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isRecording = false
    private var recordedEvents: [[String: Any]] = []
    func start() {
        guard !isRecording else { return }
        
        recordedEvents.removeAll()
        
        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue) |
        (1 << CGEventType.keyUp.rawValue) |
        (1 << CGEventType.leftMouseDown.rawValue) |
        (1 << CGEventType.rightMouseDown.rawValue)
        
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            let recorder = Unmanaged<EventRecorder>.fromOpaque(refcon!).takeUnretainedValue()
            recorder.capture(event: event, type: type)
            return Unmanaged.passUnretained(event)
        }
        
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: refcon
        )
        
        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            isRecording = true
            print("✅ Event recording started")
        } else {
            print("❌ Failed to create event tap. Make sure Accessibility permissions are granted.")
        }
    }
    
    func stop() {
        guard isRecording else { return }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        if let eventTap = eventTap {
            CFMachPortInvalidate(eventTap)
        }
        
        eventTap = nil
        runLoopSource = nil
        isRecording = false
        
        print("🛑 Event recording stopped")
        print("Captured events: \(recordedEvents)")
        
        saveToFile()
    }
    
    private func capture(event: CGEvent, type: CGEventType) {
        var record: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "type": type.rawValue
        ]
        switch type {
        case .keyDown, .keyUp: // 👈 ADD keyUp here
            record["keyCode"] = event.getIntegerValueField(.keyboardEventKeycode)
        case .leftMouseDown, .rightMouseDown:
            record["location"] = ["x": event.location.x, "y": event.location.y]
        default:
            break
        }
        
        recordedEvents.append(record)
    }
    
    func saveToFile() {
        let url = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/macro_recording.json")
        do {
            let data = try JSONSerialization.data(withJSONObject: recordedEvents, options: .prettyPrinted)
            try data.write(to: url)
            print("💾 Saved to \(url.path)")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
    
    func playback() {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = FileManager.default
                .homeDirectoryForCurrentUser
                .appendingPathComponent("Documents/macro_recording.json")
            guard let data = try? Data(contentsOf: url),
                  let events = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                  !events.isEmpty else {
                print("❌ Failed to load macro file.")
                return
            }
            
            print("🎞️ Replaying \(events.count) events...")
            
            guard let baseTime = events.first?["timestamp"] as? TimeInterval else { return }
            
            var previousTimestamp = baseTime
            
            for event in events {
                guard let typeRaw = event["type"] as? UInt32,
                      let type = CGEventType(rawValue: typeRaw),
                      let timestamp = event["timestamp"] as? TimeInterval else { continue }

                let delta = timestamp - previousTimestamp
                let delayMicroseconds = max(0, useconds_t(delta * 1_000_000))
                usleep(delayMicroseconds)
                previousTimestamp = timestamp

                switch type {
                case .keyDown, .keyUp:
                    if let keyCode = event["keyCode"] as? Int64 {
                        let isKeyDown = (type == .keyDown)
                        if let cgEvent = CGEvent(keyboardEventSource: nil,
                        virtualKey: CGKeyCode(keyCode),
                        keyDown: isKeyDown) {
                        cgEvent.post(tap: .cghidEventTap)
                        }
                    }
                case .leftMouseDown, .rightMouseDown:
                    if let loc = event["location"] as? [String: Double],
                       let x = loc["x"], let y = loc["y"] {
                        let point = CGPoint(x: x, y: y)
                        let mouseEvent = CGEvent(mouseEventSource: nil,
                                                 mouseType: type,
                                                 mouseCursorPosition: point,
                                                 mouseButton: (type == .leftMouseDown ? .left : .right))
                        mouseEvent?.post(tap: .cghidEventTap)
                    }
                default:
                    continue
                }
            }

            
            print("✅ Playback finished.")
        }
    }
}
