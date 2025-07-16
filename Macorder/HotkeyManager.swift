import Cocoa
import Carbon.HIToolbox

class HotkeyManager {
    var onToggleRecord: (() -> Void)?
    var onTogglePlayback: (() -> Void)?
    
    private var recordHotKeyID = EventHotKeyID(signature: OSType("RKey".fourCharCodeValue), id: 1)
    private var playHotKeyID = EventHotKeyID(signature: OSType("PKey".fourCharCodeValue), id: 2)
    
    private var recordHotKeyRef: EventHotKeyRef?
    private var playHotKeyRef: EventHotKeyRef?
    
    func startMonitoring() {
        let eventSpec = [
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        ]
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject),
                            EventParamType(typeEventHotKeyID),
                            nil, MemoryLayout.size(ofValue: hotKeyID),
                            nil, &hotKeyID)
            
            switch hotKeyID.id {
            case 1:
                HotkeyManager.shared.onToggleRecord?()
            case 2:
                HotkeyManager.shared.onTogglePlayback?()
            default:
                break
            }
            
            return noErr
        }, 1, eventSpec, nil, nil)
        
        RegisterEventHotKey(UInt32(kVK_ANSI_R), UInt32(cmdKey | controlKey), recordHotKeyID, GetApplicationEventTarget(), 0, &recordHotKeyRef)
        
        RegisterEventHotKey(UInt32(kVK_ANSI_P), UInt32(cmdKey | controlKey), playHotKeyID, GetApplicationEventTarget(), 0, &playHotKeyRef)
        
        print("🔑🔑 Hotkeys registered with Carbon")
    }
    
    func stopMonitoring() {
        if let recordRef = recordHotKeyRef {
            UnregisterEventHotKey(recordRef)
        }
        if let playRef = playHotKeyRef {
            UnregisterEventHotKey(playRef)
        }
    }
    
    static let shared = HotkeyManager()
}

extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        for char in utf16 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}
