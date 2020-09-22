import SwiftUI
import AVKit

struct PreviewControlView: View {
    @Binding var isPlay: Bool

    private var onPlayPause: (Bool) -> ()

    init(
        isPlay: Binding<Bool>,
        @ViewBuilder onPlayPause: @escaping (Bool) -> ()) {
        self._isPlay = isPlay
        self.onPlayPause = onPlayPause
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Button(self.isPlay ? "Pause" : "Play") {
                        print("play / pause")
                        self.isPlay.toggle()
                        self.onPlayPause(self.isPlay)
                    }.foregroundColor(SwiftUI.Color.white)
                }
            }
        }
            .padding()
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}
