import SwiftUI
import AppKit    // for NSSavePanel / NSOpenPanel

struct ContentView: View {
    @State private var isRecording = false
    @State private var loopCountText = "1"
    @State private var alwaysOnTop = false
    private let recorder = EventRecorder()

    var body: some View {
        VStack(spacing: 16) {
            Text("🎬🎬 Macro Recorder").font(.largeTitle)

            Button(isRecording ? "Stop Recording" : "Start Recording") {
                isRecording.toggle()
                isRecording ? recorder.start() : recorder.stop()
            }

            Button("Playback") {
                recorder.playback()
            }

            HStack {
                Text("Loop Count:")
                TextField("", text: $loopCountText)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
            }

            Toggle("Always On Top", isOn: $alwaysOnTop)
                .onChange(of: alwaysOnTop) { newValue in
                    if newValue {
                        setAlwaysOnTop(true)
                    } else {
                        setAlwaysOnTop(false)
                    }
                }

            HStack {
                // Save Recording with error handling
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

                // Load Recording with error handling
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
