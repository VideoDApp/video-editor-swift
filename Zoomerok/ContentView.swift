import SwiftUI
import AVKit

struct ContentView: View {
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State var videoUrl: URL? = Bundle.main.url(forResource: "TestVideo2", withExtension: "mov")!
    @State var player: AVPlayer?
    @State var isPlay: Bool = false
    @State var montageInstance = Montage()
    @State var playerController = AVPlayerViewController()
    @State var previewAsset: AVAsset?

    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    //@State private var offset: CGPoint = .zero
    //var scrollPosition: CGFloat = .zero
    @State private var offset: CGFloat = .zero

    @State private var image: UIImage?
    private var isSimulator: Bool = false

    init() {
        #if targetEnvironment(simulator)
            // your simulator code
            print("Document directory", DownloadTestContent.getDocumentsDirectory())
            self.isSimulator = true
            //DownloadTestContent.downloadAll()
        #else
            // your real device code
            self.isSimulator = false
        #endif
        // 1.
        //UINavigationBar.appearance().backgroundColor = .yellow

        // 2.
        UINavigationBar.appearance().largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
        ]

        // 3.
        /*UINavigationBar.appearance().titleTextAttributes = [
         .font : UIFont(name: "HelveticaNeue-Thin", size: 20)!]*/
        //playerController.player = makeSimplePlayer(url: videoUrl!)
        //playerController.showsPlaybackControls = false

        let fileUrl = Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!
        print("previewAsset")
        self.previewAsset = AVAsset(url: fileUrl)
        self.videoUrl = fileUrl
        self.playerController.player = self.makeSimplePlayer(url: fileUrl)
        self.playerController.showsPlaybackControls = false

        self.playerController.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { (_) in
            print("OBSERVE")
            /*self.value = self.getSliderValue()
             
             if self.value == 1.0{
             
             self.isplaying = false
             }*/
        }
    }

    func getSliderValue() -> Float {
        return Float(self.playerController.player!.currentTime().seconds / (self.playerController.player!.currentItem?.duration.seconds)!)
    }

    func makeCropPlayer(url: URL) -> AVPlayer {
        _ = montageInstance.setVideoSource(url: url)
        let size = montageInstance.getCorrectSourceSize()
        //print("size", size)
        let rect = CGRect(x: (size.width / 2) + 180, y: 0, width: (size.width / 2) - 180, height: size.height)
        var player: AVPlayer?
        do {
            let item = try montageInstance
                .setTopPart(startTime: 1, endTime: 3)
                .setBottomPart(startTime: 3, endTime: 12)
                .cropTopPart(rect: rect)
                .getAVPlayerItem()

            player = AVPlayer(playerItem: item)
        } catch {
            print("Smth not ok")
        }

        return player!
    }

    func makeSimplePlayer(url: URL) -> AVPlayer {
        _ = montageInstance.setVideoSource(url: url)

        var player: AVPlayer?
        do {
            let item = try montageInstance
            //.setTopPart(startTime: 1, endTime: 12)
            .setBottomPart(startTime: 3, endTime: 11)
                .getAVPlayerItem()

            player = AVPlayer(playerItem: item)
        } catch {
            print("Something not ok")
        }

        return player!
    }

    func onScroll(r: CGFloat) -> Void {
        if (self.offset == r) {
            //print("STORED scroll offset")
            return
        } else {
            self.offset = r
        }
        print("Scroll percent", r)
        //print("OK RES 2", r)
        /*let duration = (self.playerController.player?.currentItem?.duration)!
         print("duration", duration)
         let toTime=CMTimeMultiplyByRatio(duration, multiplier: 9,divisor: 100000)*/
        //print("toTime", toTime)
        //self.playerController.player?.seek(to: CMTimeMakeWithSeconds(5, preferredTimescale: 60))
        let percentCoeff = Float(r / 100)
        let duration = Float((self.playerController.player?.currentItem?.duration.seconds)!)
        let sec = Double(percentCoeff * duration)

        let toTime = CMTime(seconds: sec, preferredTimescale: 1000)
        print(percentCoeff, duration, sec)
        self.playerController.player?.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    var body: some View {
        NavigationView {
            VStack {
                /*Image(systemName: "square.and.arrow.down.fill")
                 .padding(.vertical)
                 .frame(width: 30.0, height: 100.0)
                 .font(.system(size: 30))
                 .foregroundColor(SwiftUI.Color.white)
                 .onTapGesture {
                 print("Export file")
                 }*/

                CustomPlayer(url: $videoUrl, isPlay: $isPlay, montage: $montageInstance, playerController: $playerController)
                    .frame(height: UIScreen.main.bounds.height / 2)


                /*ScrollPreviewView() { (result) -> () in
                 // do stuff with the result
                 self.onScroll(r: result)
                 //print("IT WORKS", result)
                 //print("IT WORKS 2", result)
                 //self.playerController.player?.seek(to: CMTimeMakeWithSeconds(10, preferredTimescale: 60))
                 }*/

                VideoRangeSliderView(asset: $previewAsset, duration: 10, onResize: { result in
                    print(result)
                }, onChangeCursorPosition: { result in
                        print(result)
                    })

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {

                        Text("SCR")
                            .foregroundColor(.white)
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .onTapGesture {
                                print("Screamer button clicked")
                        }

                        Text("SMP")
                            .foregroundColor(.white)
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .onTapGesture {
                                let fileUrl = Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!
                                self.playerController.player = self.makeSimplePlayer(url: fileUrl)
                        }

                        Text("CRP")
                            .foregroundColor(.white)
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .onTapGesture {
                                let fileUrl = Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!
                                self.playerController.player = self.makeCropPlayer(url: fileUrl)
                        }

                    }
                }


                Button(self.isPlay ? "Pause" : "Play") {
                    print("play / pause")
                    self.isPlay.toggle()
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
                                    let fileUrl = Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!
                                    print(fileUrl)
                                    self.videoUrl = fileUrl
                                    self.playerController.player = self.makeSimplePlayer(url: fileUrl)
                                }, at: 0)
                        } else {
                            buttons.insert(.default(Text("Camera")) {
                                    self.showImagePicker = true
                                    self.sourceType = .camera
                                }, at: buttons.count - 2)
                        }

                        return ActionSheet(title: Text("Select Video"), message: Text("Choose an option"), buttons: buttons)
                    }.foregroundColor(SwiftUI.Color.white)

                Spacer()
            }


            //.navigationBarTitle("Xux Editor")
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))

            // for NavigationView. Two properties for removing space from top
            // https://stackoverflow.com/questions/57517803/how-to-remove-the-default-navigation-bar-space-in-swiftui-navigiationview
            .navigationBarTitle("")
                .navigationBarHidden(true)
        }


        // for View
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomPlayer: UIViewControllerRepresentable {
    @Binding var url: URL?
    @Binding var isPlay: Bool
    @Binding var montage: Montage
    @Binding var playerController: AVPlayerViewController


    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomPlayer>) -> AVPlayerViewController {

        return playerController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<CustomPlayer>) {
        print("updateUIViewController")

        if isPlay {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }

}
