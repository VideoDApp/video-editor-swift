import SwiftUI
import SpriteKit
import Firebase

struct WarpView: View {
    @Binding var userPhoto: UIImage?
    var onClose: () -> ()

    @State var isGridHidden = true
    @State var maskStatus = "yes"
    @State var observed = SKObserved()
    @State var showingResetAlert = false
    @State var showingSavedAlert = false

    func getMaskIcon() -> String {
        var result = ""
        if maskStatus == "no" {
            result = "person.2"
//        } else if maskStatus == "yes" {
//            result = "skew"
        } else {
            result = "person"
        }

//        print("maskStatus \(maskStatus), result \(result)")
        return result
    }

    var body: some View {
        GeometryReader { geometry in
            Color.black.edgesIgnoringSafeArea(.all)
            Spacer()
            HStack {
                Spacer()
                CloseVideoView() {
                    print("Close clicked")
                    //                self.playerModel.playerController.player!.pause()
                    //                self.resetEditor()
                    self.onClose()
                }
                    .padding()
            }
            .padding()


            if self.userPhoto != nil {
                VStack {
                    Spacer()
                    Text("#zoomerok")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    SpriteKitContainer(scene: self.$observed.scene)
                        .frame(width: geometry.size.width, height: geometry.size.width)

                    VStack {
                        HStack {
                            Button(action: {
                                self.observed.showHideGrid(self.isGridHidden)
                                self.isGridHidden.toggle()
                            }) {
                                Image(systemName: "circle.grid.3x3")
                                //                        Image(systemName: "grid")
                                .foregroundColor(.white)
                                    .font(.system(size: 40))
                            }
                                .padding()

                            Button(action: {
                                if self.maskStatus == "no" {
                                    self.maskStatus = "yes"
                                } else if(self.maskStatus == "yes") {
//                                self.maskStatus = "skew"
                                    self.maskStatus = "no"
                                } else {
                                    self.maskStatus = "no"
                                }

                                self.observed.showMask(self.maskStatus == "yes" || self.maskStatus == "skew")
                            }) {
                                Image(systemName: self.getMaskIcon())
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            }
                                .padding()

//                        Button(action: {
//                            self.observed.warpReset()
//                        }) {
//                            Image(systemName: "clear")
//                                .foregroundColor(.white)
//                                .font(.system(size: 40))
//                        }
//                            .padding()

                            Button(action: {
                                self.showingResetAlert = true

                            }) {
                                HStack {
//                                Image(systemName: "xmark.circle")
                                    Image(systemName: "clear")
//                                    .font(.title)
                                    .font(.system(size: 40))
                                        .foregroundColor(.white)

                                }
                                    .padding(8)
                                    .foregroundColor(.white)
                            }
                                .alert(isPresented: $showingResetAlert) {
                                Alert(
                                    title: Text("Reset your progress?"),
                                    message: Text("There is no undo"),
                                    primaryButton: .destructive(Text("Reset")) {
                                        self.observed.warpReset()
                                    }, secondaryButton: .cancel())
                            }




                            //                    Button("Animate") {
                            //                        self.observed.warpAnimate()
                            //                    }.padding()


//                        Button(action: {
//                            self.observed.savePhoto()
//                        }) {
//                            Image(systemName: "arrow.down.doc")
//                                .foregroundColor(.white)
//                                .font(.system(size: 40))
//                        }
//                            .padding()


                        }

                        Button(action: {
                            self.observed.savePhoto()
                            self.showingSavedAlert = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.white)
                                Text("Save to gallery")
                            }
                                .padding(8)
                                .foregroundColor(.white)
                                .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                            .alert(isPresented: $showingSavedAlert) {
                            Alert(
                                title: Text("Saved"),
                                message: Text("Photo saved to gallery")
//                                primaryButton: .destructive(Text("Reset")) {
//                                    self.observed.warpReset()
//                                },
//                                secondaryButton: .cancel()
                            )
                        }

                    }


                    Spacer()
                }
                .onAppear() {
                    print("Screen size \(geometry.size)")
                }
            } else {
                ZStack(alignment: .leading) {
                    Text("Loading...")
                        .foregroundColor(.white)
                        .padding(50)
                }
            }
        }
            .onAppear() {
            if self.userPhoto != nil {
                self.observed.setUserPhoto(self.userPhoto!)
            }
        }
    }
}

struct Background: UIViewRepresentable {
    var tappedCallback: ((CGPoint) -> Void)

    func makeUIView(context: UIViewRepresentableContext<Background>) -> UIView {
        let v = UIView(frame: .zero)
        let gesture = UITapGestureRecognizer(target: context.coordinator,
            action: #selector(Coordinator.tapped))
        v.addGestureRecognizer(gesture)
        return v
    }

    class Coordinator: NSObject {
        var tappedCallback: ((CGPoint) -> Void)
        init(tappedCallback: @escaping ((CGPoint) -> Void)) {
            self.tappedCallback = tappedCallback
        }
        @objc func tapped(gesture: UITapGestureRecognizer) {
            print("Background tapped")
            let point = gesture.location(in: gesture.view)
            self.tappedCallback(point)
        }
    }

    func makeCoordinator() -> Background.Coordinator {
        return Coordinator(tappedCallback: self.tappedCallback)
    }

    func updateUIView(_ uiView: UIView,
        context: UIViewRepresentableContext<Background>) {
    }

}

class TouchableShapeNode: SKShapeNode
{
    public var onMoved: (CGPoint) -> ()
    public var onBegan: () -> ()
    public var onEnded: () -> ()
    public var startDragPosition = CGPoint(x: 0, y: 0)
    public var initialPosition = CGPoint(x: 0, y: 0)
    public var warpN = -1

    override init() {
        self.onMoved = { result in

        }
        self.onBegan = { }
        self.onEnded = { }

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onBegan()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self.parent!)
//            print("touchLocation \(touchLocation), self.position \(self.position)")
            self.position = touchLocation

            self.onMoved(touchLocation)

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        self.onEnded()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
        self.onEnded()
    }

    func setOnMoved(_ onMoved: @escaping (CGPoint) -> ()) {
        self.onMoved = onMoved
    }

    func setOnBegan(_ onBegan: @escaping () -> ()) {
        self.onBegan = onBegan
    }

    func setOnEnded(_ onEnded: @escaping () -> ()) {
        self.onEnded = onEnded
    }
}

class TouchableScene: SKScene
{
    public var onMoved: ([TouchableShapeNode]) -> () = { result in

    }

    private var points = [TouchableShapeNode]()
    private var startLocation: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let start = touches.first?.location(in: self)
        print("start loc \(String(describing: start))")
        self.startLocation = start
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = UIScreen.main.bounds.size
//        let maxOffset: CGFloat = 30.0
   
        let maxOffset: CGFloat = screenSize.width / 12
        let maxDistance: CGFloat = screenSize.width / 11
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)

            let startLocation = self.startLocation!
//            print("touchLocation \(touchLocation), dist \(touchLocation.distance(point: startLocation)), self.points.count \(self.points.count)")
            if self.points.count > 0 {
                let offset = CGPoint(x: touchLocation.x - startLocation.x, y: touchLocation.y - startLocation.y)
                let offsetAbs = CGPoint(x: abs(offset.x), y: abs(offset.y))

                if offsetAbs.x.isLess(than: maxOffset) && offsetAbs.y.isLess(than: maxOffset) {

                } else {
                    self.points = []
                    self.startLocation = touchLocation
                    return
                }

                let correctOffset = CGPoint(
                    x: offset.x / 4,
                    y: offset.y / 4
                )
//                print("offset \(offset), offsetAbs \(offsetAbs), correctOffset \(correctOffset)")
                self.points.forEach({ item in
                    item.position = CGPoint(x: item.startDragPosition.x + correctOffset.x, y: item.startDragPosition.y + correctOffset.y)

                })
                self.onMoved(self.points)
            } else {
                let closest = self.closestChilds(point: touchLocation, maxDistance: maxDistance)
//                print("Found closest \(closest.count)")
                self.points = closest
//                self.children.forEach({item in
//                    if item.name != nil {
//                        //                    item.alpha = 0.1
//                        //                    item.isHidden = true
//                    }
//                })
                closest.forEach({ item in

                    //                    item.alpha = 1
//                    item.isHidden = false
                    item.startDragPosition = item.position

                })
            }

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        //        self.onEnded()
        self.reset()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
        //        self.onEnded()
        self.reset()
    }

    func reset() {
        self.points = []
        self.startLocation = nil
    }

    //    func setOnMoved(_ onMoved: @escaping (CGPoint)->()){
    //        self.onMoved = onMoved
    //    }
    //
    //    func setOnBegan(_ onBegan: @escaping ()->()){
    //        self.onBegan = onBegan
    //    }
    //
    //    func setOnEnded(_ onEnded: @escaping ()->()){
    //        self.onEnded = onEnded
    //    }
}

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - self.x), Float(point.y - self.y)))
    }
}

extension SKScene {
    func closestChild(point: CGPoint, maxDistance: CGFloat) -> SKNode? {
        return self
            .children
            .filter { $0.position.distance(point: point) <= maxDistance }
            .min { (a, b)in a.position.distance(point: point) < b.position.distance(point: point) }
    }

    func closestChilds(point: CGPoint, maxDistance: CGFloat) -> [TouchableShapeNode] {
        return self
            .children
            .filter { $0.position.distance(point: point) <= maxDistance && $0.name != nil && $0 is TouchableShapeNode }
            .map({ item in
            return item as! TouchableShapeNode
        })
    }
}

class PinchSprite: SKSpriteNode {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.onBegan()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("PinchSprite touch \(touches.count)")

        if let touch = touches.first {
//            let touchLocation = touch.location(in: self.parent!)
////            print("touchLocation \(touchLocation), self.position \(self.position)")
//            self.position = touchLocation
//
//            self.onMoved(touchLocation)

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded PinchSprite")
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled PinchSprite")
    }
}

class SKObserved: ObservableObject {
    @Published var scene: TouchableScene

//    var userPhotoUrl: URL?
//    var photo = SKSpriteNode(imageNamed: "face-square")
    var photo: SKSpriteNode?
    var mask = PinchSprite(imageNamed: "warp-squid")
    let grid = Grid(blockSize: 30.0, rows: 10, cols: 10)!
    var points = [TouchableShapeNode]()
    var photoWarpGridSource = [SIMD2<Float>]()
    var photoWarpGridDestination = [SIMD2<Float>]()
    var photoSize = CGSize(width: 0, height: 0)
    var cols = 10
    var rows = 10
    var gridCellSize = 0
    var pointSize = 0
    var halfPointSize = 0

    init() {
        let screenSize = UIScreen.main.bounds.size
        self.photoSize = CGSize(width: screenSize.width, height: screenSize.width)
        self.gridCellSize = Int(self.photoSize.width) / cols
//        self.pointSize = 10
        self.pointSize = Int(screenSize.width / 37.5)
        self.halfPointSize = pointSize / 2

        self.scene = TouchableScene(fileNamed: "MyScene")!
        self.scene.onMoved = { result in
            self.warpPoints(result)
        }

        self.scene.isUserInteractionEnabled = true
        self.photoWarpGridSource = self.makeVectorArray(self.cols, self.rows)
        self.photoWarpGridDestination = self.photoWarpGridSource

        self.mask.size = CGSize(width: self.photoSize.width, height: self.photoSize.height)
        self.mask.name = "mask"
        self.mask.zPosition = 30

//        self.addGrid()
        self.addPoints()
//        mask.isUserInteractionEnabled = true
    }

    func setUserPhoto(_ userPhotoUrl: UIImage) {
//        let data = NSData(contentsOf: userPhotoUrl)
//        let theImage = UIImage(data: data! as Data)
        let userPhotoTexture = SKTexture(image: userPhotoUrl)

//        self.userPhotoUrl = userPhotoUrl
        self.photo = SKSpriteNode(texture: userPhotoTexture)
//        self.photo!.size = CGSize(width: self.photoSize.width, height: self.photoSize.height)
//        self.photo!.
//        self.scene.addChild(self.photo!)
        let screenSize = CGSize(width: self.photoSize.width, height: self.photoSize.height)
        let userPhoto = self.photo!
        let photoSize = self.photo!.size
//        var userPhotoSize = CGPoint(x: 0, y: 0)
        if photoSize.height < photoSize.width {
            // horizontal
            print("horizontal")
            userPhoto.setScale(screenSize.width / userPhoto.size.height)
        } else if photoSize.height > photoSize.width {
            // vertical
            print("vertical")
            userPhoto.setScale(screenSize.width / userPhoto.size.width)
        } else {
            // square
            print("square")
            userPhoto.size = screenSize
        }

        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 0)
        cropNode.zPosition = 10
        cropNode.maskNode = nil
        cropNode.addChild(userPhoto)
//        cropNode. = CGSize(width: self.photoSize.width, height: self.photoSize.height)

        self.scene.addChild(cropNode)
        self.scene.addChild(self.mask)
    }

    func addGrid() {
        grid.position = CGPoint (x: 0, y: 0)
        self.scene.addChild(grid)
    }

    func addPoints() {
        let halfPhotoWidth = self.photoSize.width / 2
        let halfPhotoHeight = self.photoSize.height / 2
        var n = 0
        for j in 0...self.cols {
            for i in 0...self.rows {
                let x = i * Int(self.gridCellSize) - Int(halfPhotoWidth)
                let y = j * Int(self.gridCellSize) - Int(halfPhotoHeight)
                //                print("=> n=\(n) x=\(x) y=\(y) i=\(i) j=\(j)")
                let shape = TouchableShapeNode()
                shape.warpN = n
                shape.name = "point_\(x)_\(y)"
                //                print(shape.name!)
                shape.path = UIBezierPath(roundedRect: CGRect(x: -halfPointSize, y: -halfPointSize, width: pointSize, height: pointSize), cornerRadius: 0).cgPath
                shape.position = CGPoint(x: x, y: y)
                shape.initialPosition = shape.position
                shape.fillColor = UIColor.yellow
                shape.alpha = 0.5
                shape.isHidden = true
                shape.zPosition = 20
                if i == 0 || j == 0 || i >= self.rows || j >= self.cols {
                    //                    print("Not added")
                } else {
                    //                    print("Added")
                    self.points.append(shape)
                    self.scene.addChild(shape)
                }

                n += 1
            }
        }
    }

    func showHidePoints(_ isShow: Bool) {
        self.points.forEach({ item in
            item.isHidden = !isShow
        })
    }

    func makeVectorArray(_ cols: Int, _ rows: Int) -> [SIMD2<Float>] {
        var result = [SIMD2<Float>]()
        for i in 0...cols {
            for j in 0...rows {
                let x: Float = 1.0 / Float(rows) * Float(j)
                let y: Float = 1.0 / Float(cols) * Float(i)
                result.append(vector_float2(x, y))
            }
        }

        return result
    }

//    func warpByElement(_ n: Int, _ move: CGPoint){
//        let canvasWidth = self.photoSize.width
//        let canvasHeight = self.photoSize.height
//        let x: Float = Float(move.x + canvasWidth / 2) / Float(canvasWidth)
//        let y: Float = Float(move.y + canvasHeight / 2) / Float(canvasHeight)
//        print("currentValSource \(n) \(self.photoWarpGridSource[n])")
//        print("x \(x), y \(y)")
//        let moveNormalized = vector_float2(x: x, y: y)
//        self.photoWarpGridDestination[n] = moveNormalized
//        let warpGeometryGrid = SKWarpGeometryGrid(columns: 10, rows: 10, sourcePositions:  self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
//        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: 0)
//        photo.run(warpAction!)
//    }

    func warpPoints(_ points: [TouchableShapeNode]) {
        let canvasWidth = self.photoSize.width
        let canvasHeight = self.photoSize.height
        points.forEach({ item in
            let move = item.position
            let x: Float = Float(move.x + canvasWidth / 2) / Float(canvasWidth)
            let y: Float = Float(move.y + canvasHeight / 2) / Float(canvasHeight)
            let moveNormalized = vector_float2(x: x, y: y)
            self.photoWarpGridDestination[item.warpN] = moveNormalized
        })

        let warpGeometryGrid = SKWarpGeometryGrid(columns: 10, rows: 10, sourcePositions: self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: 0)
        self.photo!.run(warpAction!)
    }

    func warpReset() {
        self.points.forEach({ item in
            item.position = item.initialPosition
        })
        self.photoWarpGridDestination = self.photoWarpGridSource
        let warpGeometryGrid = SKWarpGeometryGrid(columns: 10, rows: 10, sourcePositions: self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: 0)
        photo!.run(warpAction!)
    }

    func warpAnimate() {
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 10, rows: 10)
        let warpGeometryGrid = SKWarpGeometryGrid(columns: 10, rows: 10, sourcePositions: self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
        let warpAction = SKAction.animate(withWarps: [warpGeometryGridNoWarp, warpGeometryGrid], times: [0, 3])
        photo!.run(warpAction!)
    }

    func showMask(_ isShow: Bool) {
        self.mask.isHidden = !isShow
    }

    func showHideGrid(_ isShow: Bool) {
        self.grid.isHidden = !isShow
        self.points.forEach({ item in
            item.isHidden = !isShow
        })
    }

    func savePhoto(_ withBeauty: Bool = false) {
        var maskState = false
        var pointsState = false

        func prepareScene() {
            self.scene.children.forEach({ item in
                if item.name == "mask" {
                    maskState = item.isHidden
                    item.isHidden = true
                } else if item.name != nil && item.name!.starts(with: "point_") {
                    pointsState = item.isHidden
                    item.isHidden = true
                }
            })
        }

        func returnScene() {
            self.scene.children.forEach({ item in
                if item.name == "mask" {
                    item.isHidden = maskState
                } else if item.name != nil && item.name!.starts(with: "point_") {
                    item.isHidden = pointsState
                }
            })
        }

//        let container = SKSpriteNode(texture: self.photo.texture)
//        let container = SKScene()
//        container.addChild(self.photo.copy() as! SKSpriteNode)

        if withBeauty {
//            container.addChild()
        }


        prepareScene()
        let view = SKView(frame: .zero)
        let image = UIImage(cgImage: view.texture(from: self.scene)!.cgImage())

//        let image = UIImage(cgImage: (self.photo.texture!.cgImage()))

//        view.scene = self.scene
//        let image = UIImage(cgImage: (view.texture(from: container)!.cgImage()))
//        let image = UIImage(cgImage: (view.texture(from: self.photo.normalTexture)!.cgImage()))
        let imData = image.pngData()!
        let image2 = UIImage(data: imData)!
        UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil)
        Analytics.logEvent("warp_photo_saved", parameters: nil)
        returnScene()
    }
}

struct SpriteKitContainer: UIViewRepresentable {
    @Binding var scene: TouchableScene

    class Coordinator: NSObject {
        var scene: SKScene?
    }

    func makeCoordinator() -> Coordinator {
        print("makeCoordinator")
        return Coordinator()
    }

    func makeUIView(context: Context) -> SKView {
        print("makeUIView")
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
//        view.showsFPS = true
//        view.showsNodeCount = true
        context.coordinator.scene = self.scene
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
    }
}

class Grid: SKSpriteNode {
    var rows: Int!
    var cols: Int!
    var blockSize: CGFloat!

    convenience init?(blockSize: CGFloat, rows: Int, cols: Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize, rows: rows, cols: cols) else {
            return nil
        }
        self.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
        //        self.isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in: self)
            let node = atPoint(position)
            if node != self {
                let action = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
                node.run(action)
            }
            else {
                let x = size.width / 2 + position.x
                let y = size.height / 2 - position.y
                let row = Int(floor(x / blockSize))
                let col = Int(floor(y / blockSize))
                print("\(row) \(col)")
            }
        }
    }


    class func gridTexture(blockSize: CGFloat, rows: Int, cols: Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        //        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        let size = CGSize(width: CGFloat(cols) * blockSize + 0.5, height: CGFloat(rows) * blockSize + 0.5)
        UIGraphicsBeginImageContext(size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset: CGFloat = 0.5

        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }

        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i) * blockSize + offset
            //            print("y \(y)")
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }

        SKColor.white.setStroke()
        //        SKColor.red.setStroke()
        bezierPath.lineWidth = 0.5
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image!)
    }

    func gridPosition(row: Int, col: Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x: x, y: y)
    }
}

//struct WarpView_Previews: PreviewProvider {
//    static var previews: some View {
//        WarpView()
//    }
//}
