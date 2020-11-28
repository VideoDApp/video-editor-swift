import SwiftUI

struct SelectContentView: View {
    @State private var showSheet: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showTiktok: Bool = false
    @State private var showWarp: Bool = false
    @State private var warpPhoto: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    var onContentChanged: (URL) -> ()
    var isSimulator: Bool = false
//    var onOpenTiktokDownload: () -> ()
    var onOpenWarp: (UIImage) -> ()

    init(
        isSimulator: Bool,
        @ViewBuilder onContentChanged: @escaping (URL) -> (),
        @ViewBuilder onOpenWarp: @escaping (UIImage) -> ()
//        ,
//        @ViewBuilder onOpenTiktokDownload: @escaping () -> ()
    ) {
        self.onContentChanged = onContentChanged
        self.isSimulator = isSimulator
        self.onOpenWarp = onOpenWarp
//        self.onOpenTiktokDownload = onOpenTiktokDownload
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)

            VStack {
                Text("Zoomerok")
                    .font(.system(size: 60))
                    .padding()

                VStack {
                    Text("Choose a photo for warp")
                        .foregroundColor(.white)
                        .padding()
                        .sheet(isPresented: self.$showPhotoPicker) {
                        ImagePicker(
                            isShown: self.$showPhotoPicker,
                            sourceType: UIImagePickerController.SourceType.photoLibrary,
                            isVideo: false,
                            onPicked: { (result: URL) in
                                print("ImagePicker warp video \(result)")
                                return ()
                            },
                            onPickedImage: { (result: UIImage) in
                                print("ImagePicker warp picked photo \(result)")
                                //self.onContentChanged(result)
//                                self.warpPhoto = result
//                                self.showWarp = true
                                self.onOpenWarp(result)
                            }
                        )
                    }

                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 60))
                        .sheet(isPresented: self.$showWarp) {
//                        WarpView(userPhoto: self.$warpPhoto)
                    }

                }

                    .onTapGesture {
                    self.showPhotoPicker = true
                }

                VStack {
                    Text("Choose a video for montage")
                        .foregroundColor(.white)
                        .padding()

                    Image(systemName: "plus.square")
                        .foregroundColor(.white)
                        .font(.system(size: 60))

                }
                    .sheet(isPresented: $showImagePicker) {
                    ImagePicker(
                        isShown: self.$showImagePicker,
                        sourceType: self.sourceType,
                        onPicked: { result in
                            print("ImagePicker picked \(result)")
                            self.onContentChanged(result)
                        },
                        onPickedImage: { result in
                            return ()
                        })
                }
                    .onTapGesture {
                    self.showSheet = true
                }

//                VStack {
//                    Text("Download video from TikTok")
//                        .foregroundColor(.white)
//                        .padding()
//
//                    Image(systemName: "tray.and.arrow.down")
//                        .foregroundColor(.white)
//                        .font(.system(size: 60))
//                }
//                    .sheet(isPresented: self.$showTiktok) {
//                    DownloadTiktokView(onCancel: {
//                        self.showTiktok = false
//                    })
//                }
//                    .padding()
//                    .onTapGesture {
//                    //self.onOpenTiktokDownload()
//                    self.showTiktok = true
//                }
            }

                .actionSheet(isPresented: $showSheet) {
                var buttons: [ActionSheet.Button] = [
                        .default(Text("Video Library")) {
                        print("Video library selected")
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
        }

            .foregroundColor(.white)

    }
}

struct SelectContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectContentView(
            isSimulator: true,
            onContentChanged: { result in
                print(result)

                return ()
            },
            onOpenWarp: {result in
                return ()
            }
//            ,
//            onOpenTiktokDownload: {
//                return ()
//            }
        )
    }
}
