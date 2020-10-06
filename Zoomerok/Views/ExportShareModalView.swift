import SwiftUI

struct ExportShareModalView: View {
    //@Binding var showModal: Bool

    var onSaveStart: () -> Void
    var onCancel: () -> Void

    var body: some View {

        VStack {
//            Text("Export or share title")
//                .foregroundColor(Color.white)
//                .padding()

            Button("Save to gallery") {
                self.onSaveStart()
            }
                .padding()
                .foregroundColor(Color.white)

            Button("Close") {
                self.onCancel()
            }
                .padding()
                .foregroundColor(Color.white)

            Color.black.edgesIgnoringSafeArea(.all)
        }
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ExportShareModalView_Previews: PreviewProvider {
    //@State static var isShow: Bool = true

    static var previews: some View {
        ExportShareModalView(
            //showModal: self.$isShow,
            onSaveStart: {
                print("onSaveStart")
            },
            onCancel: {
                print("onCancel")
            })
    }
}
