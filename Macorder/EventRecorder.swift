import Foundation
import Cocoa

class EventRecorder {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isRecording = false
    private var recordedEvents: [[String: Any]] = []
    private var lastTimestamp: TimeInterval = 0

    func start() {
        guard !isRecording else { return }

        recordedEvents.removeAll()
        lastTimestamp = CFAbsoluteTimeGetCurrent()

        let mask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.leftMouseDown.rawValue) |
            (1 << CGEventType.rightMouseDown.rawValue)

        // Create an event tap
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { proxy, type, event, userInfo in
                guard let userInfo = userInfo else {
                    return Unmanaged.passRetained(event)
                }
                let recorder = Unmanaged<EventRecorder>
                    .fromOpaque(userInfo)
                    .takeUnretainedValue()

                let now = CFAbsoluteTimeGetCurrent()
                let delta = now - recorder.lastTimestamp
                recorder.lastTimestamp = now

                var dict: [String: Any] = [
                    "type": type.rawValue,
                    "timeDelta": delta
                ]

                switch type {
                case .keyDown, .keyUp:
                    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                    dict["keyCode"] = Int(keyCode)
                    dict["flags"] = event.flags.rawValue

                case .leftMouseDown, .rightMouseDown:
                    let loc = event.location
                    dict["x"] = loc.x
                    dict["y"] = loc.y
                    dict["flags"] = event.flags.rawValue

                default:
                    break
                }

                recorder.recordedEvents.append(dict)
                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        if let tap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            isRecording = true
            print("🔴 Recording started")
        } else {
            print("⚠️ Failed to create event tap")
        }
    }

    func stop() {
        guard isRecording else { return }

        if let tap = eventTap, let source = runLoopSource {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            eventTap = nil
            runLoopSource = nil
        }
        isRecording = false

        let fileURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/macro_recording.json")

        do {
            let data = try JSONSerialization.data(withJSONObject: recordedEvents, options: .prettyPrinted)
            try data.write(to: fileURL)
            print("⏹ Recording stopped – saved to \(fileURL.path)")
        } catch {
            print("⚠️ Failed to save recording: \(error)")
        }
    }

    func playback(times: Int = 1) {
        let fileURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/macro_recording.json")

        guard
            let data = try? Data(contentsOf: fileURL),
            let json = try? JSONSerialization.jsonObject(with: data),
            let events = json as? [[String: Any]]
        else {
            print("⚠️ No recording found at \(fileURL.path)")
            return
        }

        recordedEvents = events

        DispatchQueue.global().async {
            for cycle in 1...times {
                for evt in self.recordedEvents {
                    // wait for recorded interval
                    if let delta = evt["timeDelta"] as? TimeInterval {
                        Thread.sleep(forTimeInterval: delta)
                    }
                    // reconstruct and post the event
                    if let cgEvent = self.reconstructEvent(from: evt) {
                        cgEvent.post(tap: .cghidEventTap)
                    }
                }
                print("✅ Finished cycle \(cycle) of \(times)")
            }
            print("✅ All \(times) playback cycle(s) complete.")
        }
    }

    private func reconstructEvent(from dict: [String: Any]) -> CGEvent? {
        guard let rawType = dict["type"] as? Int,
              let type = CGEventType(rawValue: CGEventType.RawValue(rawType))
        else { return nil }

        switch type {
        case .keyDown, .keyUp:
            guard let keyCode = dict["keyCode"] as? Int,
                  let flagsRaw = dict["flags"] as? UInt64
            else { return nil }
            let isDown = (type == .keyDown)
            let ev = CGEvent(keyboardEventSource: nil,
                             virtualKey: CGKeyCode(keyCode),
                             keyDown: isDown)
            ev?.flags = CGEventFlags(rawValue: flagsRaw)
            return ev

        case .leftMouseDown, .rightMouseDown:
            guard let x = dict["x"] as? CGFloat,
                  let y = dict["y"] as? CGFloat,
                  let flagsRaw = dict["flags"] as? UInt64
            else { return nil }
            let button: CGMouseButton = (type == .leftMouseDown) ? .left : .right
            let ev = CGEvent(mouseEventSource: nil,
                             mouseType: type,
                             mouseCursorPosition: CGPoint(x: x, y: y),
                             mouseButton: button)
            ev?.flags = CGEventFlags(rawValue: flagsRaw)
            return ev

        default:
            return nil
        }
    }
}
