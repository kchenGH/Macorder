
import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    private let recorder = EventRecorder()
    var body: some View {
        VStack(spacing: 20) {
            Text("🎬 Macro Recorder").font(.largeTitle)
            
            Button(isRecording ? "Stop Recording" : "Start Recording") {
                isRecording.toggle()
                isRecording ? recorder.start() : recorder.stop()
            }
            
            Button("▶️ Play Macro") {
                recorder.playback()
            }
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}
