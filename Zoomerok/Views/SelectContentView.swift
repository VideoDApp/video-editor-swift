import SwiftUI

struct SelectContentView: View {
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    var onContentChanged: (URL) -> ()
    var isSimulator: Bool = false

    init(
        isSimulator: Bool,
        @ViewBuilder onContentChanged: @escaping (URL) -> ()
    ) {
        self.onContentChanged = onContentChanged
        self.isSimulator = isSimulator
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.primary)
                
            VStack {
                Text("Choose a video for montage")
                    .foregroundColor(.white)
                    .padding()

                Image(systemName: "plus.square")
                    .foregroundColor(.white)
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
                            let fileUrl = DownloadTestContent.getFilePath("test-files/3Big.mov")
                            print("Local test file", fileUrl)
                            self.onContentChanged(fileUrl)
                        }, at: 0)
                    buttons.insert(.default(Text("LOCAL TEST 1")) {
                            let fileUrl = DownloadTestContent.getFilePath("test-files/mouth_mask.mov")
                            print("Local test file", fileUrl)
                            self.onContentChanged(fileUrl)
                        }, at: 1)
                } else {
                    buttons.insert(.default(Text("Camera")) {
                            self.showImagePicker = true
                            self.sourceType = .camera
                        }, at: buttons.count - 2)
                }

                return ActionSheet(title: Text("Choose a video source"), buttons: buttons)
            }
            .foregroundColor(SwiftUI.Color.white)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    isShown: self.$showImagePicker,
                    sourceType: self.sourceType,
                    onPicked: { result in
                        print("ImagePicker picked \(result)")
                        self.onContentChanged(result)
                    })
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
