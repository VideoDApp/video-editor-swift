import SwiftUI
import AVKit

struct VideoRangeSliderView: View {
    @Binding var asset: AVAsset?
    @Binding var effectState: EffectState?
    @Binding var cursorTimeSeconds: Double

    @State var offsetLeftLimit: CGFloat = 0
    @State var offsetRightLimit: CGFloat = 0
    @State var effectPosition = CGPoint(x: 0, y: 0)
    @State var activeTimelineWidth: CGFloat = 0
    @State var activeTimelineOffsetX: CGFloat = 0
    @State var tempCurX: CGFloat = 0
    @State var checkX: CGFloat = 0
    @State var offsetCursor: CGFloat = 0
    @State var effectTime: Float64 = 0

    var margins: CGFloat = 45
    var timelineBorderWidth: CGFloat = 2
    var cursorWidth: CGFloat = 3
    var totalWidth = UIScreen.main.bounds.width - 45 // minus right+left margins
    var timelineControlSize = CGSize(width: 11, height: 53)
    var effectElementSize = CGSize(width: 40, height: 40)

    var onResize: (SliderChange) -> ()
    var onEffectMove: (Float64) -> ()
    var onEffectMoveEnd: (Float64) -> ()

    init(
        asset: Binding<AVAsset?>,
        cursorTimeSeconds: Binding<Double>,
        effectState: Binding<EffectState?>,
        @ViewBuilder onResize: @escaping (SliderChange) -> (),
        @ViewBuilder onEffectMove: @escaping (Float64) -> (),
        @ViewBuilder onEffectMoveEnd: @escaping (Float64) -> ()) {

        self._offsetRightLimit = State(initialValue: totalWidth)
        self._effectState = effectState
        self._asset = asset
        self._cursorTimeSeconds = cursorTimeSeconds

        //self.cursorPosition = cursorPosition
        self.onResize = onResize
        self.onEffectMoveEnd = onEffectMoveEnd
        self.onEffectMove = onEffectMove

        self.onTimelineResize()
        //self.printVars()
        //print("asset", self.asset )
    }

    func getCursorPosition() -> CGFloat {
        if self.asset == nil {
            return 0
        }

        let totalSeconds = self.asset!.duration.seconds
        if self.cursorTimeSeconds > totalSeconds {
            print("Incorrect param. Passed time more than content time \(totalSeconds) \(self.cursorTimeSeconds)")
            return 0
        }

        let percent = self.cursorTimeSeconds / (totalSeconds / 100)
        let result = self.totalWidth / 100 * CGFloat(percent)
        // print("getCursorPosition, \(percent), \(totalSeconds), \(self.cursorTimeSeconds), \(result)")

        return result
    }

    func onTimelineResize(changeType: TimelineResizeType = .none) {
        self.activeTimelineWidth = self.offsetRightLimit - self.offsetLeftLimit + self.timelineBorderWidth * 2
        self.activeTimelineOffsetX = self.margins / 2 + self.offsetLeftLimit - self.timelineBorderWidth

        // todo check that cursor fully inside in active timeline, not out cut
        if changeType == .leftControl {
            self.offsetCursor = self.offsetLeftLimit
            if self.effectPosition.x < self.offsetCursor {
                self.effectPosition.x = self.offsetCursor
            }
        } else if changeType == .rightControl {
            self.offsetCursor = self.offsetRightLimit
            if self.effectPosition.x + self.effectElementSize.width > self.offsetCursor {
                self.effectPosition.x = self.offsetCursor - self.effectElementSize.width
            }
        }

        if self.asset == nil {
            print("Empty asset, skip")
            return
        }

        let onePercent = self.totalWidth / 100
        let startPositionPercent = self.offsetLeftLimit / onePercent
        let rightOffsetPercent = self.offsetRightLimit / onePercent
        let videoSizePercent = rightOffsetPercent - startPositionPercent
        let cursorPositionPercent = self.offsetCursor / onePercent
//        print("onePercent \(onePercent)")
//        print("leftOffsetPercent \(leftOffsetPercent)")
//        print("rightOffsetPercent \(rightOffsetPercent)")
//        print("videoSizePercent \(videoSizePercent)")
//        print("cursorPositionPercent \(cursorPositionPercent)")

        let duration = CMTimeGetSeconds(self.asset!.duration)
        let timescale = self.asset!.duration.timescale
        let change = SliderChange()
        change.startPositionPercent = startPositionPercent
        change.startPositionSeconds = CMTimeMakeWithSeconds(duration / 100 * Float64(startPositionPercent), preferredTimescale: timescale)
        change.cursorPositionPercent = cursorPositionPercent
        change.cursorPositionSeconds = CMTimeMakeWithSeconds(duration / 100 * Float64(cursorPositionPercent), preferredTimescale: timescale)
        change.sizePercent = videoSizePercent
        change.sizeSeconds = CMTimeMakeWithSeconds(duration / 100 * Float64(videoSizePercent), preferredTimescale: timescale)
        print("Asset duration total: \(duration), cursor position: \(CMTimeGetSeconds(change.cursorPositionSeconds))")

        self.onResize(change)
        //printVars()
    }

    func printVars() {
        print("START =======")
        print("UIScreen.main.bounds.width", UIScreen.main.bounds.width)
        print("totalWidth", self.totalWidth)
        print("activeTimelineWidth", self.activeTimelineWidth)
        print("activeTimelineOffsetX", self.activeTimelineOffsetX)
        print("offsetLeftLimit", self.offsetLeftLimit)
        print("offsetRightLimit", self.offsetRightLimit)
        print("timelineBorderWidth", self.timelineBorderWidth)
        //print("offsetCursor", self.offsetCursor)
        //print("cursorTime", self.cursorTime!.seconds)
        print("END =======")
    }

    // todo округлять если маленькие граничные значения ( почти влево почти вправо)
    var body: some View {
        VStack {
//            Text("Value")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color.white)

//            Text("\(self.widthLeft / self.totalWidth) - \(self.widthRight / self.totalWidth)")
//                .foregroundColor(Color.white)

//            VStack() {
//                Text("activeTimelineWidth \(self.activeTimelineWidth)")
//                Text("activeTimelineOffsetX \(self.activeTimelineOffsetX)")
//                Text("offsetLeftLimit \(self.offsetLeftLimit)")
//                Text("offsetRightLimit \(self.offsetRightLimit)")
//                Text("timelineBorderWidth \(self.timelineBorderWidth)")
//                Text("totalWidth \(self.totalWidth)")
//                Text("tempCurX \(self.tempCurX)")
//                Text("effectPosition.x \(self.effectPosition.x)")
//                Text("checkX \(self.checkX)")
//            }.background(Color.white)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0))
                    .frame(width: UIScreen.main.bounds.width, height: timelineControlSize.height)

                // muted timeline (background)
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: self.totalWidth, height: timelineControlSize.height)
                    .offset(x: self.margins / 2)

                // active timeline
                Rectangle()
                    .fill(Color.gray)
                    .border(Color(hex: "e9445a"), width: self.timelineBorderWidth)
                    .frame(width: self.activeTimelineWidth, height: timelineControlSize.height)
                // y: -10 temp val for tests
                .offset(x: self.activeTimelineOffsetX, y: 0)

                // left timeline control base
                TimelineLimitBase()
                    .fill(Color(hex: "e9445a"))
                    .frame(width: timelineControlSize.width, height: timelineControlSize.height)
                    .offset(x: self.offsetLeftLimit + self.margins / 2 - self.timelineControlSize.width - self.timelineBorderWidth, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let checkX = value.location.x - self.timelineControlSize.width - self.timelineControlSize.width / 2
                                self.checkX = checkX
                                self.tempCurX = value.location.x

                                if checkX < 0 || checkX >= self.offsetRightLimit {
                                    return
                                }

                                self.offsetLeftLimit = value.location.x - self.timelineControlSize.width - self.timelineControlSize.width / 2
                                self.onTimelineResize(changeType: .leftControl)
                            })
                    )

                // left timeline control lines
                TimelineLimitLines()
                    .fill(Color.white)
                    .frame(width: timelineControlSize.width, height: timelineControlSize.height / 3)
                    .offset(x: self.offsetLeftLimit - timelineControlSize.width + self.timelineBorderWidth + self.margins / 2)

                // current time cursor
                Rectangle()
                    .fill(Color.white)
                    .frame(width: self.cursorWidth, height: timelineControlSize.height)
                    .offset(x: self.getCursorPosition() + self.margins / 2)

                // right timeline control base
                TimelineLimitBase()
                    .fill(Color(hex: "e9445a"))
                    .frame(width: timelineControlSize.width, height: timelineControlSize.height)
                    .offset(x: self.offsetRightLimit + self.timelineBorderWidth + self.margins / 2, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let checkX = value.location.x - self.margins / 2 - self.timelineControlSize.width / 2 - self.timelineBorderWidth
                                self.tempCurX = value.location.x
                                self.checkX = checkX

                                if checkX < 0 || self.offsetLeftLimit >= checkX || checkX > self.totalWidth {
                                    return
                                }

                                self.offsetRightLimit = value.location.x - self.margins / 2 - self.timelineControlSize.width / 2 - self.timelineBorderWidth
                                self.onTimelineResize(changeType: .rightControl)
                            })
                    )

                // right timeline control lines
                TimelineLimitLines()
                    .fill(Color.white)
                    .frame(width: timelineControlSize.width, height: timelineControlSize.height / 3)
                    .offset(x: self.offsetRightLimit + self.timelineBorderWidth + 2 + self.margins / 2)
            }

            // effect control
            HStack {
                VStack(alignment: .leading) {
                    if self.effectState != nil && !self.effectState!.previewUrl.isEmpty {
                        Image(self.effectState!.previewUrl)
                            .resizable()
                            .frame(width: self.effectElementSize.width, height: self.effectElementSize.height)
                            .offset(x: self.effectPosition.x + self.margins / 2, y: self.effectPosition.y)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        let checkX = value.location.x - self.margins / 2 - self.effectElementSize.width + self.effectElementSize.width / 2
                                        //print("Drag effect val ", value.location, checkX, self.totalWidth, self.offsetLeftLimit, self.offsetRightLimit)

                                        // check timeline limit
                                        if checkX < 0 || checkX > self.totalWidth - self.effectElementSize.width {
                                            return
                                        }

                                        if checkX < self.offsetLeftLimit || checkX > self.offsetRightLimit - self.effectElementSize.width {
                                            return
                                        }

                                        self.effectPosition.x = value.location.x - self.effectElementSize.width / 2 - self.margins / 2
                                        self.checkX = checkX
                                        self.tempCurX = value.location.x

                                        let duration = self.asset!.duration.seconds
                                        let effectDuration = self.effectState!.seconds
                                        let onePercent = self.totalWidth / 100
//                                        let time = CMTimeMakeWithSeconds(  duration / 100 * Float64(self.effectPosition.x / onePercent), preferredTimescale: timescale)

                                        var newEffectTime = duration / 100 * Float64(self.effectPosition.x / onePercent)
                                        let endVideoTime = duration / 100 * Float64(self.offsetRightLimit / onePercent)
                                        print("newEffectTime \(newEffectTime), endVideoTime \(endVideoTime), duration: \(duration), effectDuration: \(effectDuration)")
                                        // check is effect in bottom video timeline
                                        if newEffectTime + effectDuration > endVideoTime {
                                            newEffectTime = endVideoTime - effectDuration
                                            print("Set max newEffectTime \(newEffectTime)")
                                        }

                                        self.effectTime = newEffectTime
                                        self.onEffectMove(newEffectTime)
                                    })
                                    .onEnded({ result in
                                        self.onEffectMoveEnd(self.effectTime)
                                    })
                            )
                    }

                }
                Spacer()
            }
        }
            .padding()
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
//        .background(SwiftUI.Color.green.edgesIgnoringSafeArea(.all))
        .onAppear {
            self.onTimelineResize()
        }
    }
}

struct VideoRangeSliderView_Previews: PreviewProvider {
    @State static var previewAsset: AVAsset?
    @State static var effectState: EffectState?
    @State static var duration: CMTime = CMTime(seconds: 7, preferredTimescale: 600)
    @State static var cursorTimeSeconds: Double = 0

    static var previews: some View {
        VideoRangeSliderView(
            asset: $previewAsset,
            cursorTimeSeconds: $cursorTimeSeconds,
            effectState: $effectState,
            onResize: { result in
                print(result)
                return ()
            },
            onEffectMove: { result in
                return ()
            },
            onEffectMoveEnd: { result in
                return ()
            })
    }
}

class SliderChange {
    public var startPositionPercent: CGFloat = 0
    public var startPositionSeconds: CMTime = .zero
    public var cursorPositionPercent: CGFloat = 0
    public var cursorPositionSeconds: CMTime = .zero
    public var sizePercent: CGFloat = 0
    public var sizeSeconds: CMTime = .zero
}

struct EffectState {
    public var previewUrl: String
    public var seconds: Double

    init(_ previewUrl: String, _ seconds: Double) {
        self.previewUrl = previewUrl
        self.seconds = seconds
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
    // Example using
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

enum TimelineResizeType {
    case leftControl
    case rightControl
    case none
}
