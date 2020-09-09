import SwiftUI
import AVKit

struct EffectSelectorView: View {
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
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
                                    let fileUrl = DownloadTestContent.getFilePath("test-files/1VideoBig.mov")
                                    //self.playerController.player = self.makeSimplePlayer(url: fileUrl)
                            }

                            Text("CRP")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.red)
                                .onTapGesture {
                                    let fileUrl = DownloadTestContent.getFilePath("test-files/1VideoBig.mov")
                                    //self.playerController.player = self.makeCropPlayer(url: fileUrl)
                            }
                        }
                    }

                }
            }
        }
            .padding()
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}
