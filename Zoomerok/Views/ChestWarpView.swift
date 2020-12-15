import SwiftUI
import SpriteKit
import Firebase

struct ChestWarpView: View {
    @Binding var userPhoto: UIImage?
    var onClose: () -> ()

    @State var isGridHidden = true
    @State var maskStatus = "yes"
    @State var observed = ChestSKObserved()
    @State var showingResetAlert = false
    @State var showingSavedAlert = false

    func getMaskIcon() -> String {
        var result = ""
        if maskStatus == "no" {
            result = "person.2"
        } else {
            result = "person"
        }

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

                    ChestSpriteKitContainer(scene: self.$observed.scene)
                        .frame(width: geometry.size.width, height: geometry.size.width)

                    VStack {
                        HStack {
                            Button(action: {
                                self.observed.showHideGrid(self.isGridHidden)
                                self.isGridHidden.toggle()
                            }) {
                                Image(systemName: "circle.grid.3x3")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            }
                                .padding()

//                            Button(action: {
//                                if self.maskStatus == "no" {
//                                    self.maskStatus = "yes"
//                                } else if(self.maskStatus == "yes") {
////                                self.maskStatus = "skew"
//                                    self.maskStatus = "no"
//                                } else {
//                                    self.maskStatus = "no"
//                                }
//
//                                self.observed.showMask(self.maskStatus == "yes" || self.maskStatus == "skew")
//                            }) {
//                                Image(systemName: self.getMaskIcon())
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 40))
//                            }
//                                .padding()

//                            Button(action: {
//                                self.observed.showMask(false)
//                                self.observed.warpAnimate()
//                            }) {
//                                Image(systemName: "play")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 40))
//                            }
//                                .padding()

                            Button(action: {
                                self.observed.chestAnimation()
                            }) {
                                Image(systemName: "play")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            }
                                .padding()

                            Button(action: {
                                self.showingResetAlert = true

                            }) {
                                HStack {
                                    Image(systemName: "clear")
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

//                        Button(action: {
//                            self.observed.savePhoto()
//                            self.showingSavedAlert = true
//                        }) {
//                            HStack {
//                                Image(systemName: "square.and.arrow.down")
//                                    .foregroundColor(.white)
//                                Text("Save to gallery")
//                            }
//                                .padding(8)
//                                .foregroundColor(.white)
//                                .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.white, lineWidth: 1)
//                            )
//                        }
//                            .alert(isPresented: $showingSavedAlert) {
//                            Alert(
//                                title: Text("Saved"),
//                                message: Text("Photo saved to gallery")
////                                primaryButton: .destructive(Text("Reset")) {
////                                    self.observed.warpReset()
////                                },
////                                secondaryButton: .cancel()
//                            )
//                        }

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

class ChestTouchableScene: SKScene, SKSceneDelegate
{
    private var points = [ChestTouchableShapeNode]()
    private var leftChestPoints = [ChestTouchableShapeNode]()
    private var rightChestPoints = [ChestTouchableShapeNode]()
    private var startLocation: CGPoint?
    private var leftCirclePosition: CGPoint?
    private var rightCirclePosition: CGPoint?

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
//        nodePosition = node.position
//        print("update")
//        self.leftCircle = self.childNode(withName: "left_circle")!.position
//        self.rightCircle = self.childNode(withName: "right_circle")!.position
//        print("left right: \(self.leftCircle), \(self.rightCircle)")

//        let maxDistance: CGFloat = screenSize.width / 11
//        let closest = self.closestChilds(point: touchLocation, maxDistance: maxDistance)
////                print("Found closest \(closest.count)")
//        self.points = closest
//        closest.forEach({ item in
//            item.startDragPosition = item.position
//        })
    }

    func didEvaluateActions(for scene: SKScene) {
//        print("didEvaluateActions")
        if self.leftCirclePosition == nil || self.rightCirclePosition == nil {
            return
        }

        let leftCircle = self.childNode(withName: "left_circle") as! ChestPinchNode
        let rightCircle = self.childNode(withName: "right_circle") as! ChestPinchNode
        if self.leftCirclePosition == leftCircle.position && self.rightCirclePosition == rightCircle.position {
            return
        }
//        if self.leftCirclePosition! != leftCircle.position || self.rightCirclePosition! != rightCircle.position {
//            self.onCircleMoved(leftCircle, rightCircle)
//        }

        let leftOffset = CGPoint(x: self.leftCirclePosition!.x - leftCircle.position.x, y: self.leftCirclePosition!.y - leftCircle.position.y)
        let rightOffset = CGPoint(x: self.rightCirclePosition!.x - rightCircle.position.x, y: self.rightCirclePosition!.y - rightCircle.position.y)
//        print("y \(self.leftCirclePosition!.y) \(leftCircle.position.y), leftOffset \(leftOffset)")
        self.leftChestPoints.forEach({ item in
            item.position.x = item.startDragPosition.x - leftOffset.x
            item.position.y = item.startDragPosition.y - leftOffset.y
        })
        self.rightChestPoints.forEach({ item in
            item.position.x = item.startDragPosition.x - rightOffset.x
            item.position.y = item.startDragPosition.y - rightOffset.y
        })
        
        
        self.onMoved(self.leftChestPoints + self.rightChestPoints)
    }

    public var onMoved: ([ChestTouchableShapeNode]) -> () = { result in

    }

    func setCirclePositions(left: CGPoint?, right: CGPoint?, radius: CGFloat) {
        self.leftCirclePosition = left
        self.rightCirclePosition = right
        if self.leftCirclePosition == nil || self.rightCirclePosition == nil {
            return
        }

//        let maxDistance: CGFloat = screenSize.width / 11
        let leftClosest = self.closestChestChilds(point: left!, maxDistance: radius)
        let rightClosest = self.closestChestChilds(point: right!, maxDistance: radius)
//        print("Found closest \(closest.count)")
//        print("Found closest \(closest)")
        self.leftChestPoints = leftClosest
        self.leftChestPoints.forEach({ item in
            item.startDragPosition = item.position
        })
        
        self.rightChestPoints = rightClosest
        self.rightChestPoints.forEach({ item in
            item.startDragPosition = item.position
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let start = touches.first?.location(in: self)
        print("start loc \(String(describing: start))")
        self.startLocation = start
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = UIScreen.main.bounds.size
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
                let closest = self.closestChestChilds(point: touchLocation, maxDistance: maxDistance)
//                print("Found closest \(closest.count)")
                self.points = closest
                closest.forEach({ item in
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

class ChestPinchNode: SKShapeNode {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.onBegan()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("PinchSprite touch \(touches.count)")

        if let touch = touches.first {
            let touchLocation = touch.location(in: self.parent!)
            print("touchLocation \(touchLocation)")
//            print("touchLocation \(touchLocation), self.position \(self.position)")
            self.position = touchLocation

//            self.onMoved(touchLocation)

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded ChestPinchNode")
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled ChestPinchNode")
    }
}

extension SKScene {
    func closestChestChilds(point: CGPoint, maxDistance: CGFloat) -> [ChestTouchableShapeNode] {
        return self
            .children
            .filter { $0.position.distance(point: point) <= maxDistance && $0.name != nil && $0 is ChestTouchableShapeNode }
            .map({ item in
            return item as! ChestTouchableShapeNode
        })
    }
}

class ChestSKObserved: ObservableObject {
    @Published var scene: ChestTouchableScene

    var photo: SKSpriteNode?
//    var mask = PinchSprite(imageNamed: "warp-squid")
    var leftCircle: ChestPinchNode?
    var rightCircle: ChestPinchNode?
    var points = [ChestTouchableShapeNode]()
    var photoWarpGridSource = [SIMD2<Float>]()
    var photoWarpGridDestination = [SIMD2<Float>]()
    var photoSize = CGSize(width: 0, height: 0)
    var cols = 10
    var rows = 10
    var gridCellSize = 0
    var pointSize = 0
    var halfPointSize = 0
    var circleRadius: CGFloat = 0

    init() {
        let screenSize = UIScreen.main.bounds.size
        self.photoSize = CGSize(width: screenSize.width, height: screenSize.width)
        self.gridCellSize = Int(self.photoSize.width) / cols
        self.pointSize = Int(screenSize.width / 37.5)
        self.halfPointSize = pointSize / 2
        self.circleRadius = screenSize.width / 10

        self.scene = ChestTouchableScene(fileNamed: "MyScene")!
        self.scene.onMoved = { result in
            self.warpPoints(result)
        }

        self.scene.isUserInteractionEnabled = false
        self.photoWarpGridSource = self.makeVectorArray(self.cols, self.rows)
        self.photoWarpGridDestination = self.photoWarpGridSource

//        self.mask.size = CGSize(width: self.photoSize.width, height: self.photoSize.height)
//        self.mask.name = "mask"
//        self.mask.zPosition = 30

//        self.addGrid()
        self.addPoints()
//        mask.isUserInteractionEnabled = true

        self.leftCircle = self.getCircle(x: -68, y: -58)
        self.leftCircle!.name = "left_circle"
        self.rightCircle = self.getCircle(x: 22, y: -54)
        self.rightCircle!.name = "right_circle"
    }

    func getCircle(x: CGFloat, y: CGFloat) -> ChestPinchNode {
//        let screenSize = UIScreen.main.bounds.size
        let circle = ChestPinchNode(circleOfRadius: self.circleRadius)
//        circle.isUserInteractionEnabled = true
        circle.zPosition = 20
        circle.position = .init(x: x, y: y)
        circle.strokeColor = .black
        circle.glowWidth = 0.3
        circle.alpha = 0.2
        circle.fillColor = .white

        return circle
    }

    func setUserPhoto(_ userPhotoUrl: UIImage) {
        let userPhotoTexture = SKTexture(image: userPhotoUrl)
        self.photo = SKSpriteNode(texture: userPhotoTexture)
        let screenSize = CGSize(width: self.photoSize.width, height: self.photoSize.height)
        let userPhoto = self.photo!
        let photoSize = self.photo!.size
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

        self.scene.delegate = self.scene
        self.scene.addChild(cropNode)
        self.scene.addChild(self.leftCircle!)
        self.scene.addChild(self.rightCircle!)
//        self.scene.addChild(self.mask)
    }

//    func addGrid() {
//        grid.position = CGPoint (x: 0, y: 0)
//        self.scene.addChild(grid)
//    }

    func addPoints() {
        let halfPhotoWidth = self.photoSize.width / 2
        let halfPhotoHeight = self.photoSize.height / 2
        var n = 0
        for j in 0...self.cols {
            for i in 0...self.rows {
                let x = i * Int(self.gridCellSize) - Int(halfPhotoWidth)
                let y = j * Int(self.gridCellSize) - Int(halfPhotoHeight)
                //                print("=> n=\(n) x=\(x) y=\(y) i=\(i) j=\(j)")
                let shape = ChestTouchableShapeNode()
                shape.isUserInteractionEnabled = true
                shape.setOnMoved({(result: CGPoint) in
                    self.warpPoints([shape])
                })
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
                if  i > self.rows || j > self.cols {
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

    func warpPoints(_ points: [ChestTouchableShapeNode]) {
        let canvasWidth = self.photoSize.width
        let canvasHeight = self.photoSize.height
        points.forEach({ item in
//            print("item.position \(item.position) \(item.startDragPosition) \(item.name) \(item.warpN)")
            let move = item.position
            let x: Float = Float(move.x + canvasWidth / 2) / Float(canvasWidth)
            let y: Float = Float(move.y + canvasHeight / 2) / Float(canvasHeight)
            let moveNormalized = vector_float2(x: x, y: y)
//            print("old move \(self.photoWarpGridDestination[item.warpN]), new \(moveNormalized)")
            self.photoWarpGridDestination[item.warpN] = moveNormalized
        })

        let warpGeometryGrid = SKWarpGeometryGrid(columns: self.cols, rows: self.rows, sourcePositions: self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: 0)
        self.photo!.run(warpAction!)
    }

    func warpReset() {
        self.points.forEach({ item in
            item.position = item.initialPosition
        })
        self.photoWarpGridDestination = self.photoWarpGridSource
        let warpGeometryGrid = SKWarpGeometryGrid(columns: self.cols, rows: self.rows, sourcePositions: self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: 0)
        self.photo!.run(warpAction!)
    }

    func warpAnimate() {
//    func warpAnimate(onComplete: @escaping () -> ()) {
        let animationTime: NSNumber = 2
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: self.cols, rows: self.rows)
        let warpGeometryGrid = SKWarpGeometryGrid(columns: self.cols, rows: self.rows, sourcePositions: self.photoWarpGridSource, destinationPositions: self.photoWarpGridDestination)
        let warpAction = SKAction.animate(withWarps: [warpGeometryGridNoWarp, warpGeometryGrid], times: [0, animationTime])
        self.photo!.run(warpAction!)

        // because animation complete not work here
//        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
//            onComplete()
//        }
    }

    func chestAnimation() {
        // todo reset warp before start or after end
        self.leftCircle!.isHidden = true
        self.rightCircle!.isHidden = true
        let onComplete = {
            self.scene.setCirclePositions(left: nil, right: nil, radius: self.circleRadius)
            self.leftCircle!.isHidden = false
            self.rightCircle!.isHidden = false
        }
        self.scene.setCirclePositions(left: self.leftCircle!.position, right: self.rightCircle!.position, radius: self.circleRadius)

        let maxY = 20
        let maxSeconds: Double = 1.0
        let maxActions = 5
        var actions = [SKAction]()
        let actionSecond: Double = maxSeconds / Double(maxActions)
        for i in 0...maxActions - 1 {
            let yStep = maxY - (maxY / maxActions) * i
            actions.append(SKAction.move(by: CGVector(dx: 0, dy: -yStep), duration: actionSecond))
            actions.append(SKAction.move(by: CGVector(dx: 0, dy: yStep), duration: actionSecond))
        }

        // todo organize to group with one complete?
        self.leftCircle!.run(.sequence([
                .group([
                    .sequence(actions)
                ])
            ])) {
            onComplete()
        }
        self.rightCircle!.run(.sequence([
                .group([
                    .sequence(actions)
                ])
            ])) {
            onComplete()
        }
    }

    func showMask(_ isShow: Bool) {
//        self.mask.isHidden = !isShow
    }

    func showHideGrid(_ isShow: Bool) {
//        self.grid.isHidden = !isShow
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
        Analytics.logEvent("warp_chest_photo_saved", parameters: nil)
        returnScene()
    }
}

class ChestTouchableShapeNode: SKShapeNode
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

struct ChestSpriteKitContainer: UIViewRepresentable {
    @Binding var scene: ChestTouchableScene

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

class ChestGrid: SKSpriteNode {
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

struct ChestWarpView_Previews: PreviewProvider {
    @State static var userPhoto: UIImage? = UIImage()

    static var previews: some View {
        ChestWarpView(userPhoto: $userPhoto,
            onClose: {
                return()
            })
    }
}
