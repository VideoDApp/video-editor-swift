import SwiftUI
import AVKit

struct EffectInfo {
    public var title: String
    public var previewUrl: String
    public var videoUrl: URL

    init(_ title: String, _ name: String) {
        self.title = title
        // src from resource
        self.previewUrl = name + "-preview"
        // src from file system
        self.videoUrl = URL(string: name + "/video.mov")!
    }
}

struct EffectSelectorView: View {
    private var onEffectSelected: (EffectInfo) -> ()
    private let effects: [EffectInfo] = [
        EffectInfo("Spider Attack", "SpiderAttack"),
        //EffectInfo("SC2", URL(string: "https://ya.ru/3")!, URL(string: "https://ya.ru/4")!)
    ]

    init(@ViewBuilder onEffectSelected: @escaping (EffectInfo) -> ()) {
        self.onEffectSelected = onEffectSelected
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 3) {

                            ForEach(effects, id: \.title) { item in
                                Image(item.previewUrl)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .onTapGesture {
                                        print("Effect button clicked \(item.title)")
                                        self.onEffectSelected(item)
                                }
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
