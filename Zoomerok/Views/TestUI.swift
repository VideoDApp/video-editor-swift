import SwiftUI
import AVKit

struct TestUI: View {
    @State var time: CMTime?
    @State var showModal = true
    @ObservedObject var model = PlayerModel()

    var body: some View {
        VStack {
            Button(action: {
                print("Btn 1 clicked")
                self.model.setPlayer()
            }) {
                Text(model.player)

            }

            TestUI1(model: model)
        }
    }
}

final class PlayerModel: ObservableObject {
    @Published var player: String = "Uno"

    func setPlayer() {
        // todo here set callback for seek
        self.player = "new player data here"
    }
}

struct TestUI1: View {
    // @ObjectBinding renamed to @ObservedObject
    @ObservedObject var model: PlayerModel
    @State private var test = ""

    var body: some View {
        return VStack {
            Button(action: {
                print("Btn 2 clicked")

            }) {
                Text("My test var \(test)")
            }
        }
    }
}

struct TestUI_Previews: PreviewProvider {
    static var previews: some View {
        TestUI()
    }
}

