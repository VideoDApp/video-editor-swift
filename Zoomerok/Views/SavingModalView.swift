import SwiftUI

struct SavingModalView: View {
    @Binding var showModal: Bool

    var onCancel: () -> Void

    var body: some View {
        
        VStack {
            ActivityIndicator()
                .frame(width: 200, height: 200)
                .foregroundColor(.orange)

            Text("Saving video...")
                .foregroundColor(Color.white)
                .padding()

            Text("Please do not close the app")
                .foregroundColor(Color.white)
                .padding()


//            Button("Cancel") {
//                self.showModal.toggle()
//            }
          
            Color.black.edgesIgnoringSafeArea(.all)
        }
        .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct SavingModalView_Previews: PreviewProvider {
    @State static var isShow: Bool = true

    static var previews: some View {
        SavingModalView(showModal: self.$isShow, onCancel: {
            print("Cancel")
        })
    }
}
