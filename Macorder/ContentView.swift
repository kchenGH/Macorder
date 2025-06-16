import SwiftUI
import AppKit    // for NSSavePanel / NSOpenPanel

struct ContentView: View {
    @State private var isRecording = false
    @State private var loopCountText = "1"
    private let recorder = EventRecorder()

    var body: some View {
        VStack(spacing: 16) {
            Text("🎬 Macro Recorder").font(.largeTitle)

            Button(isRecording ? "Stop Recording" : "Start Recording") {
                isRecording.toggle()
                isRecording ? recorder.start() : recorder.stop()
            }

            HStack {
                TextField("Loop Count", text: $loopCountText)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)

                Button("▶️ Play Macro") {
                    let times = Int(loopCountText) ?? 1
                    recorder.playback(times: times)
                }
            }

            Divider().padding(.vertical, 8)

            HStack(spacing: 12) {
                Button("💾 Save Macro…") {
                    let panel = NSSavePanel()
                    panel.allowedFileTypes = ["json"]
                    panel.nameFieldStringValue = "macro_recording.json"
                    if panel.runModal() == .OK, let url = panel.url {
                        do {
                            try recorder.saveRecording(to: url)
                            print("✅ Saved to \(url.path)")
                        } catch {
                            print("⚠️ Save failed: \(error)")
                        }
                    }
                }

                Button("📂 Load Macro…") {
                    let panel = NSOpenPanel()
                    panel.allowedFileTypes = ["json"]
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK, let url = panel.url {
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
        .frame(width: 360, height: 300)
        .padding()
    }
}
