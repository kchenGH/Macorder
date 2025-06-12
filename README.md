# Macro Recorder for macOS

> A lightweight SwiftUI app that records and plays back keyboard and mouse events on your Mac.  
> Events are stored as a local JSON file (`~/Documents/macro_recording.json`) and can be triggered via the UI or global hot-keys.

---

## Table of Contents

1. [Introduction](#introduction)  
2. [Features](#features)  
3. [Requirements](#requirements)  
4. [Installation & Setup](#installation--setup)  
   - [Clone the Repository](#clone-the-repository)  
   - [Open in Xcode](#open-in-xcode)  
   - [Configure Signing & Capabilities](#configure-signing--capabilities)  
   - [Grant Accessibility Permissions](#grant-accessibility-permissions)  
   - [Build & Run](#build--run)  
5. [Usage](#usage)  
   - [Start / Stop Recording](#start--stop-recording)  
   - [Play Back Macro](#play-back-macro)  
   - [Inspect & Edit JSON](#inspect--edit-json)  
   - [Custom Playback Speed](#custom-playback-speed)  
   - [Looping & Repetition](#looping--repetition)  
6. [JSON File Format](#json-file-format)  
   - [Top-Level Structure](#top-level-structure)  
   - [Event Object Schema](#event-object-schema)  
   - [Sample JSON](#sample-json)  
7. [Global Hot-Keys](#global-hot-keys)  
   - `⌃⌘R` — Toggle Recording  
   - `⌃⌘P` — Play Macro  
   - [Customizing Hot-Keys](#customizing-hot-keys)  
8. [Advanced Features](#advanced-features)  
   - [Merging Multiple Macros](#merging-multiple-macros)  
   - [Chaining Macros](#chaining-macros)  
   - [Scheduling with Automator / cron](#scheduling-with-automator--cron)  
   - [AppleScript & CLI Integration](#applescript--cli-integration)  
9. [Project Structure & Architecture](#project-structure--architecture)  
   - [`MacorderApp.swift`](#macorderappswift)  
   - [`ContentView.swift`](#contentviewswift)  
   - [`EventRecorder.swift`](#eventrecorderswift)  
   - [`HotkeyManager.swift`](#hotkeymanagerswift)  
   - [Assets & Configuration](#assets--configuration)  
10. [Development & Contributing](#development--contributing)  
    - [Coding Style](#coding-style)  
    - [Writing Tests](#writing-tests)  
    - [Continuous Integration](#continuous-integration)  
    - [Reporting Issues](#reporting-issues)  
11. [Troubleshooting & FAQ](#troubleshooting--faq)  
12. [Roadmap](#roadmap)  
13. [License](#license)

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

## Installation & Setup

### Clone the Repository

```bash
git clone https://github.com/kchenGH/macorder.git
cd macorder
