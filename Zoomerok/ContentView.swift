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
        print("self.activeSheet \(self.activeSheet)")
        if self.activeSheet == .saveOrShare {
            return AnyView(ExportShareModalView(
                onSaveStart: {
                    print("onSaveStart")
                    self.activeSheet = .saveProcess
                    let change = self.sliderChange!
                    do {
                        let startTime = CMTimeGetSeconds(change.startPositionSeconds)
                        let endTime = CMTimeGetSeconds(change.startPositionSeconds + change.sizeSeconds)
                        print("calc setBottomPart \(startTime), \(endTime)")
                        // todo move calculation to view
                        _ = try self.montageInstance.setBottomPart(
                            startTime: startTime,
                            endTime: endTime)
                    } catch {

                    }

                    self.montageInstance.saveToFile(
                        completion: { resultUrl in
                            print("Save OK \(resultUrl)")
                            //self.saveInProgress = false
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: resultUrl)
                            }) { saved, error in
                                print("PHPhotoLibrary \(saved) \(String(describing: error))")
                                self.activeSheet = .none
                                if saved {
                                    // todo do smth
                                }
                            }
                        }, error: { result in
                            print("Save error \(result)")
                            self.saveError = result
                        })
                },
                onCancel: {
                    print("onCancel")
                    self.activeSheet = .none
                }))
        } else if self.activeSheet == .saveProcess {
            return AnyView(SavingModalView(onCancel: {
                print("Cancel saving here")
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
                if videoUrl == nil {
                    SelectContentView(isSimulator: self.isSimulator, onContentChanged: { result in
                        print("SelectContentView result", result)
                        do {
                            self.sliderChange = nil
                            self.previewAsset = AVAsset(url: result)
                            self.videoUrl = result
//                            self.playerModel.playerController.player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!)
                            self.playerModel.setPlayer(player: try self.makeOverlayPlayer(mainUrl: self.videoUrl!))
                            self.playerModel.playerController.player!.seek(to: .zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
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
                                    //print("requestAuthorization complete")
                                    // todo show export/share modal
                                    //self.showSaveShareModal = true

//                                    self.showModalSheet = true

//                                    print("set activeSheet")
                                    self.activeSheet = .saveOrShare
//                                    print("new  self.activeSheet \(self.activeSheet)")
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
//                            print("VideoRangeSliderView cursorPositionSeconds \(result.cursorPositionSeconds)")
//                            do {
//                                _ = try self.montageInstance.setBottomPart(
//                                    startTime: CMTimeGetSeconds(result.startPositionSeconds),
//                                    endTime: CMTimeGetSeconds(result.sizeSeconds)
//                                )
//
//                                self.playerModel.setPlayer(player: try self.makeOverlayPlayer(mainUrl: self.videoUrl!, overlayUrl: self.effectInfo?.videoUrl, overlayOffset: self.overlayOffset))
//                            } catch {
//
//                            }

                            if self.playerModel.playerController.player != nil {
                                let currentTime = String(describing: self.playerModel.playerController.player!.currentItem?.currentTime())
                                print("VideoRangeSliderView Seek \(currentTime) \(result.cursorPositionSeconds)")
                                self.playerModel.playerController.player!.seek(
                                    to: result.cursorPositionSeconds,
                                    toleranceBefore: CMTime.zero,
                                    toleranceAfter: CMTime.zero)
                            }

                            return ()
                        },
                        onEffectMoved: { (result: Float64) in
                            self.overlayOffset = result
                            print("onEffectMoved \(result)")
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
                        //print(result)
                        self.effectInfo = result
                        do {
                            let playerController = self.playerModel.playerController
                            if self.effectState != nil && self.effectState!.previewUrl == result.previewUrl {
                                self.effectState = nil
                                //playerController.player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!)
                                self.playerModel.setPlayer(player: try self.makeOverlayPlayer(mainUrl: self.videoUrl!))
                            } else {
                                self.effectState = EffectState(result.previewUrl, DownloadTestContent.getVideoDuration(result.videoUrl))
//                                playerController.player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!, overlayUrl: result.videoUrl)
                                self.playerModel.setPlayer(player: try self.makeOverlayPlayer(mainUrl: self.videoUrl!, overlayUrl: result.videoUrl))
                            }
                            playerController.player!.seek(to: .zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
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

//struct CustomPlayer: UIViewControllerRepresentable {
//    @Binding var url: URL?
//    @Binding var isPlay: Bool
//    @Binding var montage: Montage
//    @Binding var playerController: AVPlayerViewController
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomPlayer>) -> AVPlayerViewController {
//        return playerController
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<CustomPlayer>) {
//        print("CustomPlayer updateUIViewController")
//
//        if isPlay {
//            uiViewController.player?.play()
//        } else {
//            uiViewController.player?.pause()
//        }
//    }
//}

/// See `View.onChange(of: value, perform: action)` for more information
//struct ChangeObserver<Base: View, Value: Equatable>: View {
//    let base: Base
//    let value: Value
//    let action: (Value) -> Void
//
//    @State var model = Model()
//
//    var body: some View {
//        if model.update(value: value) {
//            DispatchQueue.main.async { self.action(self.value) }
//        }
//        return base
//    }
//
//    class Model {
//        private var savedValue: Value?
//        func update(value: Value) -> Bool {
//            guard value != savedValue else { return false }
//            savedValue = value
//            return true
//        }
//    }
//}

//extension View {
//    /// Adds a modifier for this view that fires an action when a specific value changes.
//    ///
//    /// You can use `onChange` to trigger a side effect as the result of a value changing, such as an Environment key or a Binding.
//    ///
//    /// `onChange` is called on the main thread. Avoid performing long-running tasks on the main thread. If you need to perform a long-running task in response to value changing, you should dispatch to a background queue.
//    ///
//    /// The new value is passed into the closure. The previous value may be captured by the closure to compare it to the new value. For example, in the following code example, PlayerView passes both the old and new values to the model.
//    ///
//    /// ```
//    /// struct PlayerView : View {
//    ///   var episode: Episode
//    ///   @State private var playState: PlayState
//    ///
//    ///   var body: some View {
//    ///     VStack {
//    ///       Text(episode.title)
//    ///       Text(episode.showTitle)
//    ///       PlayButton(playState: $playState)
//    ///     }
//    ///   }
//    ///   .onChange(of: playState) { [playState] newState in
//    ///     model.playStateDidChange(from: playState, to: newState)
//    ///   }
//    /// }
//    /// ```
//    ///
//    /// - Parameters:
//    ///   - value: The value to check against when determining whether to run the closure.
//    ///   - action: A closure to run when the value changes.
//    ///   - newValue: The new value that failed the comparison check.
//    /// - Returns: A modified version of this view
//    func onChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value) -> Void) -> ChangeObserver<Self, Value> {
//        ChangeObserver(base: self, value: value, action: action)
//    }
//}
