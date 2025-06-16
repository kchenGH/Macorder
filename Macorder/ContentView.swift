import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    @State private var loopCountText = "1"
    private let recorder = EventRecorder()

    var body: some View {
        VStack(spacing: 20) {
            Text("🎬 Macro Recorder")
                .font(.largeTitle)

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
        }
        .frame(width: 300, height: 220)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
