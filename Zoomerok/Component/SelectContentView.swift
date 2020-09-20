import SwiftUI

struct SelectContentView: View {
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var image: UIImage?

    var onContentChanged: (URL) -> ()
    var isSimulator: Bool = false

    init(isSimulator: Bool,
        @ViewBuilder onContentChanged: @escaping (URL) -> ()) {
        self.onContentChanged = onContentChanged
        self.isSimulator = isSimulator
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)

            VStack {
                Text("Choose a video")
                    .foregroundColor(Color.white)

                Image(systemName: "plus.square")
                    .foregroundColor(Color.white)
                    .font(.system(size: 60))
            }
        }
            .onTapGesture {
                self.showSheet = true
            }.actionSheet(isPresented: $showSheet) {
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
                            print("Local test file", fileUrl)
                            //self.videoUrl = fileUrl
                            //self.isPlay = false
//                          self.onPlayPause(self.isPlay)
                            self.onContentChanged(fileUrl)
                        }, at: 0)
                } else {
                    buttons.insert(.default(Text("Camera")) {
                            self.showImagePicker = true
                            self.sourceType = .camera
                        }, at: buttons.count - 2)
                }

//                return ActionSheet(title: Text("Choose a video source"), message: Text("Choose an option"), buttons: buttons)
                return ActionSheet(title: Text("Choose a video source"), buttons: buttons)
            }
            .foregroundColor(SwiftUI.Color.white)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        }
    }
}

struct SelectContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectContentView(isSimulator: true, onContentChanged: { result in
            print(result)
            
            return ()
        })
    }
}
