//
//  EventRecorder.swift
//  Macorder
//
//  Created by Keyu Chen on 6/9/25.
//

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

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { proxy, type, event, userInfo in
                let recorder = Unmanaged<EventRecorder>
                    .fromOpaque(userInfo!)
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
                    dict["keyCode"] = Int(event.getIntegerValueField(.keyboardEventKeycode))
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
            let data = try JSONSerialization.data(
                withJSONObject: recordedEvents,
                options: .prettyPrinted
            )
            try data.write(to: fileURL)
            print("⏹ Recording stopped – saved to \(fileURL.path)")
        } catch {
            print("⚠️ Failed to save recording: \(error)")
        }
    }

    /// Save the in-memory recording to any URL
    func saveRecording(to url: URL) throws {
        let data = try JSONSerialization.data(
            withJSONObject: recordedEvents,
            options: .prettyPrinted
        )
        try data.write(to: url)
    }

    /// Load a recording from disk into memory
    func loadRecording(from url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw NSError(
                domain: "EventRecorder",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid macro file format"]
            )
        }
        recordedEvents = json
        print("🔄 Loaded \(recordedEvents.count) events from \(url.lastPathComponent)")
    }

    /// Play back whatever is currently in memory
    func playback(times: Int = 1) {
        guard !recordedEvents.isEmpty else {
            print("⚠️ No events loaded or recorded")
            return
        }

        DispatchQueue.global().async {
            for cycle in 1...times {
                for evt in self.recordedEvents {
                    if let delta = evt["timeDelta"] as? TimeInterval {
                        Thread.sleep(forTimeInterval: delta)
                    }
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
            let ev = CGEvent(
                keyboardEventSource: nil,
                virtualKey: CGKeyCode(keyCode),
                keyDown: isDown
            )
            ev?.flags = CGEventFlags(rawValue: flagsRaw)
            return ev

        case .leftMouseDown, .rightMouseDown:
            guard let x = dict["x"] as? CGFloat,
                  let y = dict["y"] as? CGFloat,
                  let flagsRaw = dict["flags"] as? UInt64
            else { return nil }
            let button: CGMouseButton = (type == .leftMouseDown) ? .left : .right
            let ev = CGEvent(
                mouseEventSource: nil,
                mouseType: type,
                mouseCursorPosition: CGPoint(x: x, y: y),
                mouseButton: button
            )
            ev?.flags = CGEventFlags(rawValue: flagsRaw)
            return ev

        default:
            return nil
        }
    }
}
