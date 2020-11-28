import SwiftUI
import AVKit
import Photos
import Firebase
import StoreKit

enum ActiveSheet {
    case none
    case saveOrShare
    case saveProcess}

struct ContentView: View {
    @State var cursorTimeSeconds: Double = 0
    @State var player: AVPlayer?
    @State var previewAsset: AVAsset?
    @State var isPlay: Bool = false

    @State var playerModel: CustomPlayerModel = CustomPlayerModel()
    // todo merge EffectState and EffectInfo?
    @State var effectState: EffectState?
    @State var effectInfo: EffectInfo?
    @State var sliderChange: SliderChange?

    @State var activeSheet: ActiveSheet = ActiveSheet.none
    @State var saveError = ""
    @State var showGeneralError = false
    @State var showAlertBeforeShare = false
    @State var generalError = ""

    @State var montageInstance = Montage()
    @State var videoUrl: URL?
    @State var overlaySeconds: Float64 = 0
    @State var isPaid: Bool = false
    @State var isHideWatermark: Bool = false
    
    @State var userPhoto: URL?
    @State var warpPhoto: UIImage?

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
        self.overlaySeconds = 0
        self.montageInstance = Montage()
    }

//    func onOpenTiktok(localIdentifier: String) {
//        //                    let req = TikTokOpenPlatformShareRequest()
//        let req = TikTokOpenSDKShareRequest()
//        req.mediaType = .video
//        req.landedPageType = .clip
//        req.hashtag = "#zoomerok"
//        req.localIdentifiers = [localIdentifier]
//        req.send(complete: { result in
//            print("Share result: \(result)")
//        })
//    }

    func openTiktok() {
        guard let url = URL(string: "snssdk1233://") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func openTiktokDescription() {
        self.showAlertBeforeShare = true
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

    func onSaveStart(isTiktok: Bool = false) {
        print("onSaveStart")
        Analytics.logEvent("z_save_video_start", parameters: nil)
        self.saveError = ""
        self.playerModel.playerController.player!.pause()
        self.activeSheet = .saveProcess
        let change = self.sliderChange!
        do {
            let watermarkUrl = Bundle.main.url(forResource: "Watermark2", withExtension: "mov")!
            let startTimeSeconds = CMTimeGetSeconds(change.startPositionSeconds)
            let endTimeSeconds = CMTimeGetSeconds(change.startPositionSeconds + change.sizeSeconds)
            print("Save params startTimeSeconds \(startTimeSeconds), endTimeSeconds \(endTimeSeconds), self.overlaySeconds \(self.overlaySeconds), diff: \(self.overlaySeconds - startTimeSeconds)")
            // todo optimize beacuse already exists in makeOverlayPlayer
            self.montageInstance = Montage()
            _ = try self.montageInstance
                .setBottomVideoSource(url: self.videoUrl!)
                .setBottomPart(startTime: startTimeSeconds, endTime: endTimeSeconds)
            if self.effectState != nil {
                _ = try self.montageInstance
                    .setOverlayVideoSource(url: self.effectInfo!.videoUrl)
                    .setOverlayPart(offsetTime: self.overlaySeconds - startTimeSeconds)
            }

            if !self.isHideWatermark {
                _ = try self.montageInstance.setWatermark(url: watermarkUrl)
            }

            self.montageInstance.saveToFile(
                completion: { resultUrl in
                    Analytics.logEvent("z_save_video_end", parameters: nil)
                    self.montageInstance.removeWatermark()
                    print("Save OK \(resultUrl)")
                    var placeholder: PHObjectPlaceholder?
                    PHPhotoLibrary.shared().performChanges({
                        let req = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: resultUrl)
                        placeholder = req!.placeholderForCreatedAsset
                    }) { (saved, error) in
                        print("PHPhotoLibrary saved \(saved), error \(String(describing: error))")

                        if error != nil {
                            self.saveError = "PHPhotoLibrary error - \(error!)"
                            return ()
                        }

                        print("local placeholder \(placeholder!)")
//                        self.onOpenTiktok(localIdentifier: placeholder!.localIdentifier)
                        self.activeSheet = .none
                        if isTiktok {
                            self.openTiktokDescription()
                        }
                    }
                },
                error: { result in
                    Analytics.logEvent("z_save_video_error", parameters: nil)
                    self.montageInstance.removeWatermark()
                    print("Save error \(result)")
                    self.saveError = "Montage save to file error - \(result)"
                })
        } catch {
            print("Error onSaveStart \(error)")
            self.saveError = "Montage prepare error - \(error)"
        }
    }

    func getSheet() -> some View {
//        print("self.activeSheet \(self.activeSheet)")
        if self.activeSheet == .saveOrShare {
            return AnyView(ExportShareModalView(
                isPaid: self.$isPaid,
                isHideWatermark: self.$isHideWatermark,
                onSaveStart: {
                    self.onSaveStart()
                },
                onCancel: {
                    print("onCancel")
                    self.activeSheet = .none
                },
                onOpenSubscription: {
                    print("Subscribtion window opened")
                },
                onTiktokShare: {
                    print("Tiktok share code here")
                    self.onSaveStart(isTiktok: true)
                }
                ))
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
        VStack {
            if self.videoUrl == nil && self.warpPhoto == nil {
//                WarpView(userPhoto: self.$userPhoto)
                SelectContentView(isSimulator: self.isSimulator,
                    onContentChanged: { (result: URL) in
                        Analytics.logEvent("z_video_selected", parameters: nil)
                        print("SelectContentView result", result)
                        do {
                            let size = Montage.getVideoSize(url: result)
                            let duration = Montage.getVideoDuration(result)
                            if size.width > size.height || size.width == size.height {
                                self.showGeneralError = true
                                self.generalError = "Only vertical video format is supported. Try to select a different video."
                                print("User select horizontal or square video! Skip \(size)")
                                return ()
                            }

                            if duration < 2 {
                                self.showGeneralError = true
                                self.generalError = "Video duration less than 2 seconds. Try to select a different video."
                                print("User select short video! Duration \(duration)")
                                return ()
                            }

                            // todo call resetEditor?
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
                    },
                    onOpenWarp:{result in
                        self.warpPhoto = result
                        Analytics.logEvent("warp_photo_selected", parameters: nil)
                        return ()
                    }
//                    ,onOpenTiktokDownload: {
//                        print("onOpenTiktokDownload clicked")
//                        return ()
//                    }
                )
                    .alert(isPresented: self.$showGeneralError) {
                        Alert(title: Text("Incorrect video"), message: Text(self.generalError), dismissButton: .default(Text("OK")))
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            } else if self.warpPhoto != nil {
                VStack{
                    WarpView(userPhoto: self.$warpPhoto, onClose: {
                        self.warpPhoto = nil
                    })
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }
            } else {
                HStack {
                    Button(action: {
                        print("Btn export clicked")
                        self.saveError = ""
                        self.requestAuthorization(
                            complete: {
                                self.activeSheet = .saveOrShare
                            },
                            error: {
                                print("requestAuthorization error")
                                // todo show error (try to reinstall app)
                            })
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
                        .alert(isPresented: Binding<Bool>(get: {
                                return self.activeSheet == .none && self.showAlertBeforeShare
                        },
                            set: { p in self.showAlertBeforeShare = p }
                                )) {
                            Alert(title: Text("Info about sharing"), message: Text("After opening TikTok tap \"+\" button and choose \"Upload\". Use #zoomerok tag in title for promotion"), dismissButton: .default(Text("OK")) {
                                    self.openTiktok()
                                })
                        }
                        .padding()

                    CloseVideoView() {
                        print("Close clicked")
                        self.playerModel.playerController.player!.pause()
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
//                            let currentTime = String(describing: self.playerModel.playerController.player!.currentItem?.currentTime())
//                                print("VideoRangeSliderView Seek \(currentTime) \(result.cursorPositionSeconds)")
                            self.playerModel.playerController.player!.seek(
                                to: result.cursorPositionSeconds,
                                toleranceBefore: .zero,
                                toleranceAfter: .zero)
                        }

                        return ()
                    },
                    onEffectMove: { (result: Float64) in
                        let playerController = self.playerModel.playerController
                        playerController.player!.seek(to: CMTimeMakeWithSeconds(result, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)

                        return ()
                    },
                    onEffectMoveEnd: { (result: Float64) in
                        self.overlaySeconds = result
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

                EffectSelectorView(
                    onEffectSelected: { (result: EffectInfo) in
                        print("EffectSelectorView clicked \(result)")
                        self.effectInfo = result
                        do {
                            let playerController = self.playerModel.playerController
                            if self.effectState?.previewUrl == result.previewUrl {
                                self.effectState = nil
                                self.playerModel.setPlayer(player: try self.makeOverlayPlayer(mainUrl: self.videoUrl!))
                                playerController.player!.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                            } else {
                                let startCMTime = self.sliderChange!.startPositionSeconds
                                let startTime = CMTimeGetSeconds(startCMTime)
                                self.overlaySeconds = startTime
                                self.cursorTimeSeconds = startTime
                                self.effectState = EffectState(result.previewUrl, Montage.getVideoDuration(result.videoUrl))
                                let player = try self.makeOverlayPlayer(mainUrl: self.videoUrl!, overlayUrl: result.videoUrl, overlayOffset: startTime)
                                self.playerModel.setPlayer(player: player)
                                playerController.player!.seek(to: startCMTime, toleranceBefore: .zero, toleranceAfter: .zero)
                            }
                        } catch {
                            print("EffectSelectorView error \(error)")
                        }

                        return ()
                    })
            }

            Color.black.edgesIgnoringSafeArea(.all)
            Spacer()
        }
            .onAppear() {
//                ZoomerokProducts.store.requestProducts { (success, products: [SKProduct]?) in
//                    print("requestProducts \(success) \(String(describing: products!.first))")
//                }
//                self.userPhoto = Bundle.main.url(forResource: "face", withExtension: "jpg")!
                self.userPhoto = Bundle.main.url(forResource: "face_horizontal", withExtension: "jpg")!
//                self.userPhoto = Bundle.main.url(forResource: "face_horizontal", withExtension: "jpg")!
            }

            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))

        // for NavigationView. Two properties for removing space from top
        // https://stackoverflow.com/questions/57517803/how-to-remove-the-default-navigation-bar-space-in-swiftui-navigiationview
//            .navigationBarTitle("")
//                .navigationBarHidden(true)
        //}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
