import Foundation
import AppKit
import Quartz

struct RecordedEvent: Codable {
    enum EventType: String, Codable {
        case keyDown, keyUp
        case leftMouseDown, leftMouseUp
        case rightMouseDown, rightMouseUp
        case mouseMoved
    }

    let type: EventType
    let timestamp: TimeInterval
    let keyCode: UInt16?
    let mouseX: Double?
    let mouseY: Double?
}

class EventRecorder: ObservableObject {
    private var eventMonitors: [Any] = []
    @Published private(set) var events: [RecordedEvent] = []
    private var sessionStartTime: TimeInterval?
    private var lastMousePosition: CGPoint?
    private let movementThreshold: CGFloat = 3.0
    private var isPlaying = false
    
    var isRecording: Bool {
        return !eventMonitors.isEmpty
    }

    func start() {
        events.removeAll()
        sessionStartTime = nil
        lastMousePosition = nil

        let keyDownMon = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.capture(event)
        }
        let keyUpMon = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) { [weak self] event in
            self?.capture(event)
        }

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

        let mouseMoveMon = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.capture(event)
        }

        eventMonitors = [keyDownMon, keyUpMon,
                        leftDownMon, leftUpMon,
                        rightDownMon, rightUpMon,
                        mouseMoveMon]
        
        objectWillChange.send()
    }

    func stop() {
        for mon in eventMonitors {
            NSEvent.removeMonitor(mon)
        }
        eventMonitors.removeAll()
        objectWillChange.send()
    }

    func playback(loopCount: Int = 1) {
        guard !events.isEmpty else { return }
        guard !isPlaying else { return }
        isPlaying = true
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            for i in 0..<loopCount {
                print("Playing back loop \(i + 1)/\(loopCount)")
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
            
            self.isPlaying = false
        }
    }

    func saveRecording(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(events)
        try data.write(to: url)
    }

    func loadRecording(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        events = try decoder.decode([RecordedEvent].self, from: data)
        objectWillChange.send()
    }

    private func capture(_ event: NSEvent) {
        if sessionStartTime == nil {
            sessionStartTime = event.timestamp
        }
        guard let start = sessionStartTime else { return }

        if event.type == .mouseMoved {
            let currentPosition = NSEvent.mouseLocation
            if let lastPos = lastMousePosition {
                let distance = hypot(currentPosition.x - lastPos.x, currentPosition.y - lastPos.y)
                if distance < movementThreshold {
                    return
                }
            }
            lastMousePosition = currentPosition
        }

        let relativeTime = event.timestamp - start
        let type: RecordedEvent.EventType
        var keyCode: UInt16? = nil
        var locX: Double? = nil
        var locY: Double? = nil

        switch event.type {
        case .keyDown: type = .keyDown; keyCode = event.keyCode
        case .keyUp: type = .keyUp; keyCode = event.keyCode
        case .leftMouseDown: type = .leftMouseDown
        case .leftMouseUp: type = .leftMouseUp
        case .rightMouseDown: type = .rightMouseDown
        case .rightMouseUp: type = .rightMouseUp
        case .mouseMoved: type = .mouseMoved
        default: return
        }

        if [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .mouseMoved].contains(event.type) {
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
        objectWillChange.send()
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
            guard let screenFrame = NSScreen.main?.frame else { return }
            let flippedY = screenFrame.height - yPts
            let loc = CGPoint(x: x, y: flippedY)
            let src = CGEventSource(stateID: .hidSystemState)
            let mouseType: CGEventType
            let button: CGMouseButton
            switch recorded.type {
            case .leftMouseDown: mouseType = .leftMouseDown; button = .left
            case .leftMouseUp: mouseType = .leftMouseUp; button = .left
            case .rightMouseDown: mouseType = .rightMouseDown; button = .right
            case .rightMouseUp: mouseType = .rightMouseUp; button = .right
            default: return
            }
            if let mouseEvent = CGEvent(mouseEventSource: src,
                                      mouseType: mouseType,
                                      mouseCursorPosition: loc,
                                      mouseButton: button) {
                mouseEvent.post(tap: .cghidEventTap)
            }
            
        case .mouseMoved:
            guard let x = recorded.mouseX, let yPts = recorded.mouseY else { return }
            guard let screenFrame = NSScreen.main?.frame else { return }
            let flippedY = screenFrame.height - yPts
            let loc = CGPoint(x: x, y: flippedY)
            let src = CGEventSource(stateID: .hidSystemState)
            
            if let moveEvent = CGEvent(mouseEventSource: src,
                                     mouseType: .mouseMoved,
                                     mouseCursorPosition: loc,
                                     mouseButton: .left) {
                moveEvent.post(tap: .cghidEventTap)
            }
        }
    }
}
