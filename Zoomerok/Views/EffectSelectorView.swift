import SwiftUI
import AVKit

struct EffectInfo {
    public var title: String
    public var previewUrl: String
    public var videoUrl: URL
    public var isTransparent: Bool

    init(_ title: String, _ name: String, _ isTransparent: Bool) {
        self.title = title
        // src from resource
        self.previewUrl = name + "-preview"
        // src from file
        self.videoUrl = Bundle.main.url(forResource: name + "-video", withExtension: "mov")!
        self.isTransparent = isTransparent
    }
}

struct EffectSelectorView: View {
    private var onEffectSelected: (EffectInfo) -> ()
    private let effects: [EffectInfo] = [
        EffectInfo("Spider Attack", "SpiderAttack", true),
        EffectInfo("Soccer Ball", "SoccerBall", true),
//        EffectInfo("Directed By", "DirectedBy", false),
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
                                    .border(Color.white)
//                                    .overlay(
//                                            RoundedRectangle(cornerRadius: 0)
//                                                .stroke(Color.white, lineWidth: 1)
//                                        )
                                    .onTapGesture {
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
