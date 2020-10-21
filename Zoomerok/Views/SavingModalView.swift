import SwiftUI

struct SavingModalView: View {
    var errorText: String = ""
    var onCancel: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack {
            if errorText.isEmpty {
                ActivityIndicator()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)

                Text("Saving video...")
                    .foregroundColor(Color.white)
                    .padding()

                Text("Please do not close the app")
                    .foregroundColor(Color.white)
                    .padding()
                //            Button("Cancel") {
                //                self.showModal.toggle()
                //            }
            } else {
                Text("Save error: \(self.errorText)")
                    .foregroundColor(Color.white)
                    .padding()

                Color.black.edgesIgnoringSafeArea(.all)
                Spacer()
                
                Button("Close") {
                    self.onClose()
                }
                    .padding()
                    .foregroundColor(.white)
            }

            Color.black.edgesIgnoringSafeArea(.all)
        }
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct SavingModalView_Previews: PreviewProvider {
    @State static var isShow: Bool = true

    static var previews: some View {
        SavingModalView(
            onCancel: {
                print("Cancel")
            },
            onClose: {
                print("Close")
            })
    }
}
