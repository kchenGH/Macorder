# Macro Recorder for macOS

> A lightweight SwiftUI app that records and plays back keyboard and mouse events on your Mac.  
> Events are stored as a local JSON file (`~/Documents/macro_recording.json`) and can be triggered via the UI or global hot-keys.

---


## Introduction

Macro Recorder for macOS is designed for power users, QA engineers, and accessibility enthusiasts who need to automate repetitive tasks by capturing keyboard and mouse events with frame-accurate timing. Unlike heavyweight automation suites, Macro Recorder is minimal, open-source, and runs locally—no cloud or App Store distribution.

Key benefits:

- **Privacy**: All data stays on your machine in a human-readable JSON file.  
- **Precision**: Accurate timing between events, down to the millisecond.  
- **Extensibility**: JSON format allows manual editing, merging, or programmatic generation.  
- **Lightweight**: Single-window SwiftUI app, minimal dependencies.  

---

## Features

- **Record / Stop recording** of:
  - `keyDown`  
  - `keyUp`  
  - `leftMouseDown`  
  - `leftMouseUp`  
  - `rightMouseDown`  
  - `rightMouseUp`  
- **Play Macro** with original inter-event timing  
- **Global hot-keys** (active even when app in background)  
- **Loop** macros any number of times  
- **Adjust playback speed** (e.g., 0.5×, 1×, 2×)  
- **Merge** multiple JSON macro files  
- **Chain** macros sequentially  
- **JSON schema** validation built in  
- **AppleScript / CLI** hooks for external automation  
- **Minimal UI** with real-time event counter  

---

## Requirements

- **macOS** 10.15 Catalina or later  
- **Xcode** 13 or later  
- **Swift** 5.5+  

> _Note: Swift Concurrency (`async`/`await`) is used for timing accuracy; ensure you build with Xcode 13 or newer._

---
