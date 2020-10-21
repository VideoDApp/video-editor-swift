import SwiftUI
import AVKit
import Photos

enum ActiveSheet {
    case none
    case saveOrShare
    case saveProcess
}

struct ContentView: View {
    @State var cursorTimeSeconds: Double = 0
    @State var videoUrl: URL?
    @State var player: AVPlayer?
    @State var montageInstance = Montage()
    @State var previewAsset: AVAsset?
    @State var isPlay: Bool = false
    @State var effectState: EffectState?
    @State var activeSheet: ActiveSheet = ActiveSheet.none
    @State var saveError = ""
    @State var playerModel: CustomPlayerModel = CustomPlayerModel()
    @State var effectInfo: EffectInfo?
    @State var sliderChange: SliderChange?
    @State var overlayOffset: Float64 = 0

    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var offset: CGFloat = .zero

    private var isSimulator: Bool = false

    init() {
        #if targetEnvironment(simulator)
            // your simulator code
            print("ContentView Document directory", DownloadTestContent.getDocumentsDirectory())
            //initTestVideoForSimulator()
            self.isSimulator = true
            //DownloadTestContent.downloadAll()
        #else
            // your real device code
            self.isSimulator = false
        #endif

        UINavigationBar.appearance().largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
        ]

        self.playerModel.playerController.showsPlaybackControls = false
    }

    func resetEditor() {
        self.videoUrl = nil
        self.effectState = nil
        self.sliderChange = nil
        self.overlayOffset = 0
        self.montageInstance = Montage()
    }

    func requestAuthorization(complete: @escaping () -> Void, error: @escaping () -> Void) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        //print("authorizationStatus \(authorizationStatus.rawValue)")
        if authorizationStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                print("requestAuthorization status \(status)")
                DispatchQueue.main.async {
                    complete()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            DispatchQueue.main.async {
                complete()
            }
        } else {
            DispatchQueue.main.async {
                error()
            }
        }
    }

    func getSheet() -> some View {
//        print("self.activeSheet \(self.activeSheet)")
        if self.activeSheet == .saveOrShare {
            return AnyView(ExportShareModalView(
                onSaveStart: {
                    print("onSaveStart")
                    self.activeSheet = .saveProcess
                    let change = self.sliderChange!
                    do {
                        let watermarkUrl = Bundle.main.url(forResource: "Watermark2", withExtension: "mov")!
                        let startTime = CMTimeGetSeconds(change.startPositionSeconds)
                        let endTime = CMTimeGetSeconds(change.startPositionSeconds + change.sizeSeconds)
                        print("Save params startTime \(startTime), endTime \(endTime), self.overlayOffset \(self.overlayOffset), diff: \(self.overlayOffset - startTime)")
                        // todo optimize beacuse already exists in makeOverlayPlayer
                        self.montageInstance = Montage()
                        _ = try self.montageInstance
                            .setBottomVideoSource(url: self.videoUrl!)
                            .setBottomPart(startTime: startTime, endTime: endTime)
                        if self.effectState != nil {
                            _ = try self.montageInstance
                                .setOverlayVideoSource(url: self.effectInfo!.videoUrl)
                                .setOverlayPart(offsetTime: self.overlayOffset - startTime)
                        }

                        _ = try self.montageInstance.setWatermark(url: watermarkUrl)

                        self.montageInstance.saveToFile(
                            completion: { resultUrl in
                                self.montageInstance.removeWatermark()
                                print("Save OK \(resultUrl)")
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: resultUrl)
                                }) { (saved, error) in
                                    print("PHPhotoLibrary saved \(saved), error \(String(describing: error))")
                                    if saved {
                                        self.activeSheet = .none
                                        return ()
                                    }

                                    if error != nil {
                                        self.saveError = "PHPhotoLibrary error - \(error!)"
                                    }
                                }
                            },
                            error: { result in
                                self.montageInstance.removeWatermark()
                                print("Save error \(result)")
                                self.saveError = "Montage save to file error - \(result)"
                            })
                    } catch {
                        print("Error onSaveStart \(error)")
                        self.saveError = "Montage prepare error - \(error)"
                    }
                },
                onCancel: {
                    print("onCancel")
                    self.activeSheet = .none
                }))
        } else if self.activeSheet == .saveProcess {
            return AnyView(SavingModalView(
                errorText: self.saveError,
                onCancel: {
                    print("Cancel saving here")
                },
                onClose: {
                    self.activeSheet = .none
                }))
        } else if self.activeSheet == .none {
            return AnyView(Text("None"))
        }

        return AnyView(Text("Hello"))
    }

//    func initTestVideoForSimulator() {
//        let testFileName = "test-files/1VideoBig.mov"
//        let fileUrl = DownloadTestContent.getFilePath(testFileName)
//        if !DownloadTestContent.isFileExists(testFileName) {
//            print("Test file not found in simulator mode")
//            return
//        }
//
//        print("initTestVideoForSimulator")
//        // todo check is file exists
//        self.previewAsset = AVAsset(url: fileUrl)
//        self.videoUrl = fileUrl
//        self.playerController.player = self.makeSimplePlayer(url: fileUrl)
//    }

//    func getSliderValue() -> Float {
//        return Float(self.playerController.player!.currentTime().seconds / (self.playerController.player!.currentItem?.duration.seconds)!)
//    }

//    func makeCropPlayer(url: URL) -> AVPlayer {
//        _ = montageInstance.setVideoSource(url: url)
//        let size = montageInstance.getCorrectSourceSize()
//        //print("size", size)
//        let rect = CGRect(x: (size.width / 2) + 180, y: 0, width: (size.width / 2) - 180, height: size.height)
//        var player: AVPlayer?
//        do {
//            let item = try montageInstance
//                .setTopPart(startTime: 1, endTime: 3)
//                .setBottomPart(startTime: 3, endTime: 12)
//                .cropTopPart(rect: rect)
//                .getAVPlayerItem()
//
//            player = AVPlayer(playerItem: item)
//        } catch {
//            print("Smth not ok")
//        }
//
//        return player!
//    }

    func makeOverlayPlayer(mainUrl: URL, overlayUrl: URL? = nil, overlayOffset: Float64 = 0) throws -> AVPlayer {
        self.montageInstance = Montage()
        _ = try self.montageInstance.setBottomVideoSource(url: mainUrl)
            .setBottomPart(
                startTime: 0,
                endTime: CMTimeGetSeconds(montageInstance.bottomVideoSource!.duration)
            )

        if overlayUrl != nil {
            _ = try self.montageInstance
                .setOverlayVideoSource(url: overlayUrl!)
                .setOverlayPart(offsetTime: overlayOffset)
        }

        let item = self.montageInstance.getAVPlayerItem()
        return AVPlayer(playerItem: item)
    }

    var body: some View {
        NavigationView {
            VStack {
                if self.videoUrl == nil {
                    SelectContentView(isSimulator: self.isSimulator,
                        onContentChanged: { result in
                            print("SelectContentView result", result)
                            do {
                                self.sliderChange = nil
                                self.previewAsset = AVAsset(url: result)
                                self.videoUrl = result
                                let player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!)
                                self.playerModel.setPlayer(player: player)
                                self.playerModel.playerController.player!.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                            } catch {
                                print("SelectContentView error \(error)")
                            }

                            return ()
                        })
                        .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.height / 2)
                } else {
                    HStack {
                        Button(action: {
                            print("Btn export clicked")
                            self.requestAuthorization(
                                complete: {
                                    self.activeSheet = .saveOrShare
                                }, error: {
                                    print("requestAuthorization error")
                                    // todo show error (try to reinstall app)
                                })

                            self.saveError = ""

                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                                Text("Export")

                            }
                                .padding(8)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            Spacer()
                        }
                            .sheet(isPresented: Binding<Bool>(get: { return self.activeSheet != .none },
                                set: { p in self.activeSheet = p ? .saveOrShare : .none })) {
                                getSheet()
                            }
                            .padding()

                        CloseVideoView() {
                            print("Close clicked")
                            self.resetEditor()
                        }
                            .padding()
                    }

                    ZStack {
                        CustomPlayerView(
                            url: $videoUrl,
                            isPlay: $isPlay,
                            montage: $montageInstance,
                            playerModel: $playerModel,
                            onSeek: { (result: CMTime) in
//                                print("CustomPlayerView result seek", result)
                                self.cursorTimeSeconds = result.seconds
                                return ()
                            })
                            .frame(height: UIScreen.main.bounds.height / 2)
                    }

                    VideoRangeSliderView(
                        asset: self.$previewAsset,
                        cursorTimeSeconds: self.$cursorTimeSeconds,
                        effectState: self.$effectState,
                        onResize: { (result: SliderChange) in
                            self.sliderChange = result
                            print("VideoRangeSliderView startPositionSeconds \(CMTimeGetSeconds(result.startPositionSeconds)) \(CMTimeGetSeconds(result.sizeSeconds))")

                            if self.playerModel.playerController.player != nil {
                                let currentTime = String(describing: self.playerModel.playerController.player!.currentItem?.currentTime())
//                                print("VideoRangeSliderView Seek \(currentTime) \(result.cursorPositionSeconds)")
                                self.playerModel.playerController.player!.seek(
                                    to: result.cursorPositionSeconds,
                                    toleranceBefore: CMTime.zero,
                                    toleranceAfter: CMTime.zero)
                            }

                            return ()
                        },
                        onEffectMove: { (result: Float64) in
                            let playerController = self.playerModel.playerController
                            playerController.player!.seek(to: CMTimeMakeWithSeconds(result, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)

                            return ()
                        },
                        onEffectMoveEnd: { (result: Float64) in
                            self.overlayOffset = result
                            print("onEffectMoveEnd \(result)")
                            if self.effectInfo == nil {
                                print("empty self.effectInfo")
                                return ()
                            }

                            do {
                                let player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!, overlayUrl: self.effectInfo!.videoUrl, overlayOffset: result)
                                self.playerModel.setPlayer(player: player)
                            } catch {
                                print("onEffectMoved error \(error)")
                            }

                            return ()
                        })

                    EffectSelectorView(onEffectSelected: { (result: EffectInfo) in
                        print("EffectSelectorView clicked \(result)")
                        self.effectInfo = result
                        do {
                            let playerController = self.playerModel.playerController
                            if self.effectState?.previewUrl == result.previewUrl {
                                self.effectState = nil
                                self.playerModel.setPlayer(player: try self.makeOverlayPlayer(mainUrl: self.videoUrl!))
                            } else {
                                self.cursorTimeSeconds = 0
                                self.effectState = EffectState(result.previewUrl, DownloadTestContent.getVideoDuration(result.videoUrl))
                                let overlayOffset = CMTimeGetSeconds(self.sliderChange!.startPositionSeconds)
                                let player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!, overlayUrl: result.videoUrl, overlayOffset: overlayOffset)
                                self.playerModel.setPlayer(player: player)
                            }

                            playerController.player!.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                        } catch {
                            print("EffectSelectorView error \(error)")
                        }

                        return ()
                    })
                }

                Color.black.edgesIgnoringSafeArea(.all)
                Spacer()
            }

                .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))

            // for NavigationView. Two properties for removing space from top
            // https://stackoverflow.com/questions/57517803/how-to-remove-the-default-navigation-bar-space-in-swiftui-navigiationview
            .navigationBarTitle("")
                .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
