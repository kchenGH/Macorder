Macro Recorder for macOS
A lightweight SwiftUI app that records and plays back keyboard and mouse events on your Mac.
Events are stored as a local JSON file (~/Documents/macro_recording.json) and can be triggered via the UI or global hot-keys.

🔑 Features
Record / Stop recording of keyDown, keyUp, leftMouseDown, rightMouseDown

Play Macro with accurate timing between events

Global hot-keys (work even in the background):

⌃⌘R → Start / Stop recording

⌃⌘P → Play macro

No App Store distribution—just build and run locally

JSON storage makes it easy to inspect or edit saved macros

🛠 Requirements
macOS 10.15 Catalina or later

Xcode 13+

Swift 5+

🚀 Installation & Setup
Clone the repo

                    
git clone https://github.com/kchenGH/macorder.git
cd macorder
Open in Xcode
Double-click Macorder.xcodeproj (or select File → Open… in Xcode).

Configure Signing & Capabilities

Select your target → Signing & Capabilities

Check Automatically manage signing and choose your Team

Add Hardened Runtime; enable Allow Unsigned Executable Memory and Apple Events

Grant Accessibility Permissions

System Settings → Privacy & Security → Accessibility

Add Xcode (for development) and/or the built Macorder.app, then check it

Build & Run
Press ⌘ B to build, then ⌘ R to launch the app

🎬 Usage
Record a Macro

Click Start Recording or press ⌃⌘R

Perform any key presses and mouse clicks

Click Stop Recording (or ⌃⌘R again)

A file named macro_recording.json will appear in your ~/Documents folder

Play Back

Click ▶️ Play Macro or press ⌃⌘P

Your recorded events will replay with the original timing

Inspect / Edit

Open ~/Documents/macro_recording.json in your editor to tweak timings or add/remove events manually

📂 Project Structure
Macorder/
├─ Macorder.xcodeproj       ← Xcode project
├─ MacorderApp.swift        ← @main entry + AppDelegate adaptor
├─ ContentView.swift        ← SwiftUI UI controls
├─ EventRecorder.swift      ← CGEventTap recording & playback logic
├─ HotkeyManager.swift      ← Carbon hot-key registration
└─ Assets.xcassets + Info.plist



🤝 Contributing
Fork the repo

Create a feature branch (git checkout -b feature/foo)

Commit your changes (git commit -am "Add foo feature")

Push to your branch (git push origin feature/foo)

Open a Pull Request

Please keep code style consistent, add tests if possible, and update this README if you add new features.

⚖️ License
This project is released under the MIT License.
Feel free to use, modify, and redistribute!
