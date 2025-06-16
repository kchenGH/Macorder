import Foundation
import AppKit
import Quartz  // for CGEvent

/// Represents a recorded input event (keyboard or mouse)
struct RecordedEvent: Codable {
    enum EventType: String, Codable {
        case keyDown, keyUp
        case leftMouseDown, leftMouseUp
        case rightMouseDown, rightMouseUp
    }

    let type: EventType
    let timestamp: TimeInterval   // seconds since session start
    let keyCode: UInt16?          // for keyboard events
    let mouseX: Double?           // global screen X coordinate for mouse events
    let mouseY: Double?           // global screen Y coordinate for mouse events
}

/// Records and plays back global keyboard and mouse events
class EventRecorder {
    private var eventMonitors: [Any] = []
    private var events: [RecordedEvent] = []
    private var sessionStartTime: TimeInterval?

    /// Begin recording keyboard and mouse events
    func start() {
        events.removeAll()
        sessionStartTime = nil

        // Keyboard events
        let keyDownMon = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.capture(event)
        }
        let keyUpMon = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) { [weak self] event in
            self?.capture(event)
        }

        // Mouse click events
        let leftDownMon = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            self?.capture(event)
        }
        let leftUpMon = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] event in
            self?.capture(event)
        }
        let rightDownMon = NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            self?.capture(event)
        }
        let rightUpMon = NSEvent.addGlobalMonitorForEvents(matching: .rightMouseUp) { [weak self] event in
            self?.capture(event)
        }

        eventMonitors = [keyDownMon, keyUpMon,
                         leftDownMon, leftUpMon,
                         rightDownMon, rightUpMon]
    }

    /// Stop recording and remove all event monitors
    func stop() {
        for mon in eventMonitors {
            NSEvent.removeMonitor(mon)
        }
        eventMonitors.removeAll()
    }

    /// Play back the recorded events in sequence, preserving timing
    func playback() {
        guard !events.isEmpty else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            var lastTime: TimeInterval = 0
            for recorded in self.events {
                let wait = recorded.timestamp - lastTime
                if wait > 0 {
                    Thread.sleep(forTimeInterval: wait)
                }
                self.post(recorded)
                lastTime = recorded.timestamp
            }
        }
    }

    /// Save the recorded events to a JSON file
    func saveRecording(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(events)
        try data.write(to: url)
    }

    /// Load recorded events from a JSON file
    func loadRecording(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        events = try decoder.decode([RecordedEvent].self, from: data)
    }

    // MARK: - Private Helpers

    private func capture(_ event: NSEvent) {
        // Initialize session start time on first event
        if sessionStartTime == nil {
            sessionStartTime = event.timestamp
        }
        guard let start = sessionStartTime else { return }

        let relativeTime = event.timestamp - start
        let type: RecordedEvent.EventType
        var keyCode: UInt16? = nil
        var locX: Double? = nil
        var locY: Double? = nil

        switch event.type {
        case .keyDown:
            type = .keyDown; keyCode = event.keyCode
        case .keyUp:
            type = .keyUp;   keyCode = event.keyCode
        case .leftMouseDown:
            type = .leftMouseDown
        case .leftMouseUp:
            type = .leftMouseUp
        case .rightMouseDown:
            type = .rightMouseDown
        case .rightMouseUp:
            type = .rightMouseUp
        default:
            return
        }

        // For mouse events, capture global cursor location in screen coords
        if [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp].contains(event.type) {
            let mouseLoc = NSEvent.mouseLocation
            locX = Double(mouseLoc.x)
            locY = Double(mouseLoc.y)
        }

        let recorded = RecordedEvent(
            type: type,
            timestamp: relativeTime,
            keyCode: keyCode,
            mouseX: locX,
            mouseY: locY
        )
        events.append(recorded)
    }

    private func post(_ recorded: RecordedEvent) {
        switch recorded.type {
        case .keyDown, .keyUp:
            guard let code = recorded.keyCode else { return }
            let src = CGEventSource(stateID: .hidSystemState)
            if let keyEvent = CGEvent(keyboardEventSource: src,
                                      virtualKey: code,
                                      keyDown: recorded.type == .keyDown) {
                keyEvent.post(tap: .cghidEventTap)
            }

        case .leftMouseDown, .leftMouseUp,
             .rightMouseDown, .rightMouseUp:
            guard let x = recorded.mouseX, let yPts = recorded.mouseY else { return }
            // Convert points to Quartz screen coords: flip vertical origin
            guard let screenFrame = NSScreen.main?.frame else { return }
            let flippedY = screenFrame.height - yPts
            let loc = CGPoint(x: x, y: flippedY)
            let src = CGEventSource(stateID: .hidSystemState)
            let mouseType: CGEventType
            let button: CGMouseButton
            switch recorded.type {
            case .leftMouseDown:
                mouseType = .leftMouseDown; button = .left
            case .leftMouseUp:
                mouseType = .leftMouseUp;   button = .left
            case .rightMouseDown:
                mouseType = .rightMouseDown;button = .right
            case .rightMouseUp:
                mouseType = .rightMouseUp;  button = .right
            default:
                return
            }
            if let mouseEvent = CGEvent(mouseEventSource: src,
                                        mouseType: mouseType,
                                        mouseCursorPosition: loc,
                                        mouseButton: button) {
                mouseEvent.post(tap: .cghidEventTap)
            }
        }
    }
}
