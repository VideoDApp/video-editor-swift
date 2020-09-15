import SwiftUI
import AVKit

struct PreviewControlView: View {
    //@State private var showImagePicker: Bool = false
//    @State private var showSheet: Bool = false
    @State var isPlay: Bool = false
    //@State private var image: UIImage?
//    @State private var sourceType: UIImagePickerController.SourceType = .camera
    //@State var videoUrl: URL?

    //private var isSimulator: Bool = false
    private var onPlayPause: (Bool) -> ()
    //private var onContentChanged: (URL) -> ()

    init(//isSimulator: Bool,
        @ViewBuilder onPlayPause: @escaping (Bool) -> ()
        //,onContentChanged: @escaping (URL) -> ()
    ) {
        self.onPlayPause = onPlayPause
        //self.onContentChanged = onContentChanged
        //self.isSimulator = isSimulator
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
