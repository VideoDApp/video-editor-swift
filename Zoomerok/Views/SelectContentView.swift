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
                Text("Zoomerok")
                    .font(.system(size: 60))
                    .padding()

                Text("Choose a video for montage")
                    .foregroundColor(.white)
                    .padding()

                Image(systemName: "plus.square")
                    .foregroundColor(.white)
                    .font(.system(size: 60))
            }
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
                                let fileUrl = DownloadTestContent.getFilePath("test-files/3Big.mov")
                                print("Local test file", fileUrl)
                                self.onContentChanged(fileUrl)
                            }, at: 0)
                        buttons.insert(.default(Text("LOCAL TEST 1")) {
                                let fileUrl = DownloadTestContent.getFilePath("test-files/mouth_mask.mov")
                                print("Local test file", fileUrl)
                                self.onContentChanged(fileUrl)
                            }, at: 1)
                        buttons.insert(.default(Text("LOCAL Horizontal")) {
                                let fileUrl = DownloadTestContent.getFilePath("test-files/horizontal.mov")
                                print("Local test file", fileUrl)
                                self.onContentChanged(fileUrl)
                            }, at: 2)
                    } else {
                        buttons.insert(.default(Text("Camera")) {
                                self.showImagePicker = true
                                self.sourceType = .camera
                            }, at: buttons.count - 1)
                    }

                    return ActionSheet(title: Text("Choose a video source"), buttons: buttons)
                }
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
            .onTapGesture {
                self.showSheet = true
            }
            .foregroundColor(.white)

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
