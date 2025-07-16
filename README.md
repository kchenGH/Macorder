# Macro Recorder for macOS - NOW WORKING FOR EVERYTHING

**A lightweight SwiftUI app that records and plays back keyboard & mouse events on your Mac.**  
Events are stored as a human-readable JSON file and can be triggered via the UI or global hot-keys.

---

## Table of Contents

- [Usage](#usage)  
- [Configuration](#configuration)  
- [Features](#features)  
- [Requirements](#requirements)  
- [Installation](#installation)  
- [Development](#development)  
- [License](#license)  

---

## Installation

1. Download the .zip file under Code
2. Unzip the Macorder.zip inside the .zip file
3. Run the app. If it says unidentified developer or such, go to Privacy and Security, scroll down and Open Anyway

---

## Usage

1. Grant the app **Accessibility** & **Input Monitoring** permissions when prompted.  
2. Press **⌃⌘R** to start recording; press again to stop.  
3. Press **⌃⌘P** to start playback; press again to stop.  
4. Use the **File > Save…** menu item or **⌘S** to save your macro to JSON.  
5. Use **File > Open…** or **⌘O** to load an existing macro file.  

---

## Configuration

### Entitlements

- **Accessibility** / **Input Monitoring**  
  - Open **System Settings → Privacy & Security**  
  - Add your built app under **Accessibility** and **Input Monitoring**.

- **File Access**  
  - In Xcode’s **Signing & Capabilities**, add **User Selected File Read/Write**.  
    This lets the Save/Open panel appear correctly.

---

## Features

- **Record & Playback**  
  – Capture keyboard & mouse events with millisecond accuracy.  
  – Play back macros exactly as recorded.  
- **Global Hot-Keys**  
  – ⌃⌘R to start/stop recording  
  – ⌃⌘P to start/stop playback  
- **JSON Storage**  
  – Macros saved as `~/Documents/macro_recording.json`  
  – Easy to inspect or edit by hand.  
- **Minimal UI**  
  – Lightweight SwiftUI interface shows event count & status.  
- **Privacy-First**  
  – All data stays local; no cloud or App Store distribution.  
- **AppleScript / CLI Hooks**  
  – Integrate with external automation workflows.  

---

## Requirements

- **macOS** 10.15 Catalina or later  
- **Xcode** 13 or later  
- **Swift** 5.5+ (uses `async`/`await` for timing)  

---

## Development

- **Lint & Format**  
  - Run SwiftLint if configured.  
- **Testing**  
  - Manual testing via the UI & hot-keys.  
  - Inspect the JSON file for correct event data.  

---

## License

This project is released under the **MIT License**.  
See [LICENSE](./LICENSE) for details.  
