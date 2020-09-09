import SwiftUI
import AVKit

struct PreviewControlView: View {
    @State private var showImagePicker: Bool = false
    @State private var showSheet: Bool = false
    @State var isPlay: Bool = false
    @State private var image: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    //@State var videoUrl: URL?

    private var isSimulator: Bool = false
    private var onPlayPause: (Bool) -> ()
    private var onContentChanged: (URL) -> ()

    init(isSimulator: Bool,
        @ViewBuilder onPlayPause: @escaping (Bool) -> (),
        onContentChanged: @escaping (URL) -> ()) {
        self.onPlayPause = onPlayPause
        self.onContentChanged = onContentChanged
        self.isSimulator = isSimulator
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

                    Button("Choose Video") {
                        self.showSheet = true
                    }.padding()
                        .actionSheet(isPresented: $showSheet) {
                            var buttons: [ActionSheet.Button] = [
                                    .default(Text("Video Library")) {
                                        self.showImagePicker = true
                                        self.sourceType = .photoLibrary
                                },
                                    .cancel()
                            ]

                            if self.isSimulator {
                                buttons.insert(.default(Text("LOCAL TEST")) {
                                        let fileUrl = DownloadTestContent.getFilePath("test-files/1VideoBig.mov")
                                        print(fileUrl)
                                        //self.videoUrl = fileUrl
                                        self.isPlay = false
                                        self.onPlayPause(self.isPlay)
                                        self.onContentChanged(fileUrl)
//                                        self.playerController.player = self.makeSimplePlayer(url: fileUrl)
                                    }, at: 0)
                            } else {
                                buttons.insert(.default(Text("Camera")) {
                                        self.showImagePicker = true
                                        self.sourceType = .camera
                                    }, at: buttons.count - 2)
                            }

                            return ActionSheet(title: Text("Select Video"), message: Text("Choose an option"), buttons: buttons)
                        }.foregroundColor(SwiftUI.Color.white)
                }
            }
        }
            .padding()
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        }
    }
}
