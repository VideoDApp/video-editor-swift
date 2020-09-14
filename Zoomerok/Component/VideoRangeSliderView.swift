import SwiftUI
import AVKit

struct VideoRangeSliderView: View {
    @Binding var asset: AVAsset?
    @Binding var effectState: EffectState
    @State var offsetLeftLimit: CGFloat = 0
    // actual params in init()
    @State var offsetRightLimit: CGFloat = 0
    @State var effectPosition = CGPoint(x: 0, y: 0)

    var totalWidth = UIScreen.main.bounds.width - 45 // minus right left margins?
    var cornerSize = CGSize(width: 11, height: 53)
    //var marginTopBottom: CGFloat = 3
    var effectElementSize = CGSize(width: 40, height: 40)
    var duration: CGFloat
    var onResize: (CGFloat) -> ()
    var onChangeCursorPosition: (CGFloat) -> ()



    private var adapterAsset: Binding<AVAsset> {
        Binding<AVAsset>(get: {
            //self.willUpdate()
            print("---get adapter")
            return self.asset!
        }, set: {
                print("---set adapter")
                self.asset = $0
                //self.didModify()
            })
    }

    init(
        asset: Binding<AVAsset?>,
        duration: CGFloat,
        effectState: Binding<EffectState>,
        @ViewBuilder onResize: @escaping (CGFloat) -> (),
        onChangeCursorPosition: @escaping (CGFloat) -> ()) {

        print("Video range INIT called")
        self._offsetRightLimit = State(initialValue: totalWidth)
        self._effectState = effectState
        self._asset = asset
        self._effectPosition = State(initialValue: CGPoint(x: -(self.effectElementSize.width / 2), y: 0))

        self.duration = duration
        self.onResize = onResize
        self.onChangeCursorPosition = onChangeCursorPosition

        //print("asset", self.asset )
//        if self.asset != nil {
//            self.asset!.generateThumbnail { /*[weak self]*/ (image) in
//                DispatchQueue.main.async {
//                    print("image received")
//                    print(image as Any)
//                    //guard let image = image else { return }
//                    //self?.imageView.image = image
//                }
//            }
//        }
    }

    // todo округлять если маленькие граничные значения ( почти влево почти вправо)
    // сделать callback при движении ползунков
    // в каких ед передавать значения в callback? сек, проценты? Возможно сек, тогда будет легче делать seek
    // сделать минимальны зазор между ползунками
    // определить какой минимальный видос оно может обработать (3-2-1 сек?)
    // кто будет генерить preview? этот класс или нужен какой-то метод (превью могут загружаться не моментально. редактор должен работать, а превью грузиться)
    // как определить сколько preview нужно для полного заполнения?
    var body: some View {
        VStack {
//            Text("Value")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color.white)

//            Text("\(self.widthLeft / self.totalWidth) - \(self.widthRight / self.totalWidth)")
//                .foregroundColor(Color.white)

            ZStack(alignment: .leading) {
                // muted timeline (background)
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: totalWidth, height: cornerSize.height)
                //.frame(width: totalWidth, height: cornerSize.height - marginTopBottom)
                //.offset(x: 3)

                // active timeline
                Rectangle()
                    .fill(Color.white)
                    .border(Color(hex: "e9445a"), width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                    .frame(width: self.offsetRightLimit - self.offsetLeftLimit, height: cornerSize.height)
                //.frame(width: self.widthRight - self.widthLeft, height: cornerSize.height - marginTopBottom)
                .offset(x: self.offsetLeftLimit)




                HStack(spacing: 0) {
                    // left timeline control
                    ZStack() {
                        TimelineLimitBase()
                            .fill(Color(hex: "e9445a"))
                            .frame(width: cornerSize.width, height: cornerSize.height)
                            .offset(x: self.offsetLeftLimit - cornerSize.width)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        if value.location.x >= 0 && value.location.x <= self.offsetRightLimit {
                                            self.offsetLeftLimit = value.location.x
                                        }

                                        self.onResize(111)
                                    })
                            )
                        TimelineLimitLines()
                            .fill(Color.white)
                            .frame(width: cornerSize.width, height: cornerSize.height / 3)
                            .offset(x: self.offsetLeftLimit - cornerSize.width + 4)
                    }


                    // right timeline control
                    ZStack() {
                        TimelineLimitBase()
                            .fill(Color(hex: "e9445a"))
                            .frame(width: cornerSize.width, height: cornerSize.height)
                            .offset(x: self.offsetRightLimit - cornerSize.width)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        if value.location.x <= self.totalWidth && value.location.x >= self.offsetLeftLimit {
                                            self.offsetRightLimit = value.location.x
                                        }

                                        self.onResize(222)
                                    })
                            )
                        TimelineLimitLines()
                            .fill(Color.white)
                            .frame(width: cornerSize.width, height: cornerSize.height / 3)
                            .offset(x: self.offsetRightLimit - cornerSize.width + 2)
                    }
                }

            }

            // effect control
            HStack {
                VStack(alignment: .leading) {
                    if !self.effectState.previewUrl.isEmpty {
                        Image(self.effectState.previewUrl)
                            .resizable()
                            .frame(width: self.effectElementSize.width, height: self.effectElementSize.height)
                            .offset(x: self.effectPosition.x + self.effectElementSize.width / 2, y: self.effectPosition.y)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        let newX = value.location.x - self.effectElementSize.width
                                        //let halfScreen = self.totalWidth / 2
                                        let halfElementWidth = self.effectElementSize.width / 2
                                        print("Drag effect val ", value.location, newX, self.totalWidth, self.offsetLeftLimit, self.offsetRightLimit)

                                        // check timeline limit
                                        if newX < -halfElementWidth || value.location.x > self.totalWidth - halfElementWidth {
                                            return
                                        }

                                        // check offset limit
                                        if newX < self.offsetLeftLimit - halfElementWidth || value.location.x > self.offsetRightLimit - halfElementWidth {
                                            return
                                        }

                                        self.effectPosition.x = newX
                                    })
                            )
                    }

                }
                Spacer()
            }
                .frame(width: totalWidth)
        }
            .padding()
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct VideoRangeSliderView_Previews: PreviewProvider {
    @State static var previewAsset: AVAsset?
    @State static var effectState: EffectState = EffectState("SpiderAttack-preview")

    static var previews: some View {
        VideoRangeSliderView(asset: $previewAsset, duration: 10, effectState: $effectState, onResize: { result in
            print(result)
        }, onChangeCursorPosition: { result in
                print(result)
            })
    }
}

struct EffectState {
    public var previewUrl: String

    init(_ previewUrl: String) {
        self.previewUrl = previewUrl
    }
}

struct TimelineLimitLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRect(CGRect(x: rect.minX, y: rect.minY, width: 1, height: rect.maxY))
        path.addRect(CGRect(x: rect.minX + 2, y: rect.minY, width: 1, height: rect.maxY))
        path.addRect(CGRect(x: rect.minX + 4, y: rect.minY, width: 1, height: rect.maxY))

        return path
    }
}

struct TimelineLimitBase: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRect(CGRect(x: rect.minX, y: rect.minY, width: rect.maxX, height: rect.maxY))
        path.addRect(CGRect(x: rect.minX, y: rect.minY, width: rect.maxX - 5, height: rect.maxY))

        return path
    }
}

extension AVAsset {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        print("generateThumbnail")
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
                .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
