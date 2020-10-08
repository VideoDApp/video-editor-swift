import SwiftUI

struct ExportShareModalView: View {
    //@Binding var showModal: Bool

    var onSaveStart: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Export or share video")
                .foregroundColor(.gray)
                .padding(.bottom, 150)

            Button(action: {
                self.onSaveStart()
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

            Color.black.edgesIgnoringSafeArea(.all)
            Spacer()

            Button("Close") {
                self.onCancel()
            }
                .padding()
                .foregroundColor(.white)
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
