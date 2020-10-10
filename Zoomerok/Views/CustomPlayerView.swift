import SwiftUI
import AVKit

struct CustomPlayerView: View {
    @Binding var url: URL?
    @Binding var isPlay: Bool
    @Binding var montage: Montage
    @Binding var playerModel: CustomPlayerModel

    var onSeek: (CMTime) -> ()

    var body: some View {
        ZStack {
            CustomPlayer(url: $url,
                isPlay: $isPlay,
                montage: $montage,
                playerController: $playerModel.playerController)

            HStack {
                if !self.isPlay {
                    Image(systemName: "play.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(20)
                }
            }
        }
            .onTapGesture {
                let playerController = self.playerModel.playerController
                print("Click play, current state isPlay: \(self.isPlay)")
                if self.playerModel.getSliderValue() == 1.0 {
                    playerController.player!.seek(to: .zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                    self.onSeek(.zero)
                }

                if self.isPlay {
                    playerController.player?.pause()
                } else {
                    playerController.player?.play()
                }

                self.isPlay.toggle()
            }
            .onAppear() {
                self.playerModel.setOnPlayPause(onPlayPause: { result in
                    self.isPlay = result
                })
                self.playerModel.setOnSeek(onSeek: { result in
                    self.onSeek(result)
                })
        }
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
        print("CustomPlayerView updateUIViewController")

//        if isPlay {
//            uiViewController.player?.play()
//        } else {
//            uiViewController.player?.pause()
//        }
    }
}


//struct CustomPlayerView_Previews: PreviewProvider {
//    @State static var url: URL? = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
//    @State static var isPlay: Bool = false
//    @State static var montage: Montage = Montage()
//    @State static var playerController: AVPlayerViewController = AVPlayerViewController()
//
//    static var previews: some View {
//
//        CustomPlayerView(
//            url: $url,
//            isPlay: $isPlay,
//            montage: $montage,
//            playerController: $playerController,
//            onSeek: { result in
//                return ()
//            })
//    }
//}

final class CustomPlayerModel: ObservableObject {
    @Published var playerController: AVPlayerViewController = AVPlayerViewController()
    var onSeek: (CMTime) -> () = { result in

    }
    var onPlayPause: (Bool) -> () = { result in

    }

    func setPlayer(player: AVPlayer) {
        self.playerController.player = player
        self.playerController.player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { (_) in
            print("addPeriodicTimeObserver \(self.playerController.player!.currentTime().seconds)")
            self.onSeek(self.playerController.player!.currentTime())

            let value = self.getSliderValue()

            if value == 1.0 {
                //self.isPlay = false
                self.onPlayPause(false)
            }
        }
    }

    func setOnSeek(onSeek: @escaping (CMTime) -> ()) {
        self.onSeek = onSeek
    }

    func setOnPlayPause(onPlayPause: @escaping (Bool) -> ()) {
        self.onPlayPause = onPlayPause
    }

    func getSliderValue() -> Float {
        return Float(self.playerController.player!.currentTime().seconds / (self.playerController.player!.currentItem?.duration.seconds)!)
    }
}
