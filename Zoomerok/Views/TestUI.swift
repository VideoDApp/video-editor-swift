import SwiftUI
import AVKit

struct TestUI: View {
    @State var time: CMTime?
    @State var showModal = true

    var body: some View {
        VStack {
//            Button(action: {
//                print("Btn clicked")
//
//            }) {
//                Text("Change time")
//            }
//
////            ActivityIndicator()
////                .frame(width: 200, height: 200)
////                .foregroundColor(.orange)
//            ModalView(showModal: self.$showModal)

            Button("Show Modal") {
                // 2.
                self.showModal.toggle()
                // 3.
            }.sheet(isPresented: $showModal) {
                ModalView(showModal: self.$showModal)
            }
        }
    }
}

struct ModalView: View {
    // 1.
    @Binding var showModal: Bool

    var body: some View {
        VStack {
            ActivityIndicator()
                .frame(width: 200, height: 200)
                .foregroundColor(.orange)

            Text("Inside Modal View")
                .padding()
            // 2.
            Button("Dismiss") {
                self.showModal.toggle()
            }
        }
    }
}

struct TestUI1: View {
    @State private var test = ""

    var body: some View {

        let binding = Binding(
            get: { self.test },
            set: { self.test = $0 }
        )

        return VStack {

            Button(action: {
                print("Btn clicked")
                print("Bnd clicked \(binding)")

            }) {
                Text("Change time \(test)")
            }

        }
    }
}

struct TestUI_Previews: PreviewProvider {
    static var previews: some View {
        TestUI()
    }
}

