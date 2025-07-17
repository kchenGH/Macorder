import SwiftUI
import AppKit

struct ContentView: View {
    @State private var loopCountText = "1"
    @State private var alwaysOnTop = false
    @EnvironmentObject var recorder: EventRecorder
    var onLoopCountChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🎬 Macorder").font(.largeTitle)

            HStack(spacing: 8) {
                Button(recorder.isRecording ? "Stop Recording (^⌘R)" : "Start Recording (^⌘R)") {
                    recorder.isRecording ? recorder.stop() : recorder.start()
                }
                .keyboardShortcut("r", modifiers: [.control, .command])
            }

            HStack(spacing: 8) {
                Button("Playback (^⌘P)") {
                    let loopCount = Int(loopCountText) ?? 1
                    onLoopCountChange(loopCount)
                    recorder.playback(loopCount: max(1, loopCount))
                }
                .keyboardShortcut("p", modifiers: [.control, .command])
            }

            HStack {
                Text("Loop Count:")
                TextField("", text: $loopCountText)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .onChange(of: loopCountText) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        loopCountText = filtered
                        if let count = Int(filtered) {
                            onLoopCountChange(count)
                        }
                    }
            }

            Toggle("Always On Top", isOn: $alwaysOnTop)
                .onChange(of: alwaysOnTop) { newValue in
                    setAlwaysOnTop(newValue)
                }

            HStack {
                Button("Save Recording") {
                    let panel = NSSavePanel()
                    panel.allowedFileTypes = ["json"]
                    panel.begin { response in
                        if response == .OK, let url = panel.url {
                            do {
                                try recorder.saveRecording(to: url)
                                print("✅ Saved to \(url.path)")
                            } catch {
                                print("⚠️ Save failed: \(error)")
                            }
                        }
                    }
                }

                Button("Load Recording") {
                    let panel = NSOpenPanel()
                    panel.allowedFileTypes = ["json"]
                    panel.begin { response in
                        if response == .OK, let url = panel.url {
                            do {
                                try recorder.loadRecording(from: url)
                                print("✅ Loaded from \(url.path)")
                            } catch {
                                print("⚠️ Load failed: \(error)")
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 360, height: 350)
        .padding()
    }

    private func setAlwaysOnTop(_ onTop: Bool) {
        guard let window = NSApp.windows.first else { return }
        window.level = onTop ? .floating : .normal
    }
}
