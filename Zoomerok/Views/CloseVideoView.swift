import SwiftUI

struct CloseVideoView: View {
    @State private var showingAlert = false

    var onClose: () -> ()

    var body: some View {
        Button(action: {
            self.showingAlert = true
        }) {
            HStack {
                Image(systemName: "xmark.circle")
                    .font(.title)
                    .foregroundColor(.white)

            }
                .padding(8)
                .foregroundColor(.white)
        }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Reset your progress?"),
                    message: Text("There is no undo"),
                    primaryButton: .destructive(Text("Reset")) {
                        self.onClose()
                    }, secondaryButton: .cancel())
        }
    }
}

struct CloseVideoView_Previews: PreviewProvider {
    static var previews: some View {
        CloseVideoView(onClose: {
            return ()
        })
    }
}
