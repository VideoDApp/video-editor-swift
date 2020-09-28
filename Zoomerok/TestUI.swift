import SwiftUI
import AVKit

struct TestUI: View {
    @State var time: CMTime?


    var body: some View {
        VStack {

            if self.time != nil {
                Text("Time \(self.time!.seconds)")
            } else {
                Text("Empty time")
            }
            
            Button(action: {
                print("parent Btn clicked")
                self.time = .zero
            }) {
                Text("Parent change")
            }

//            Text("Hello World!")
//                .frame(width: 200, height: 100)
//                .background(Color.red)
            //.foregroundColor(.white)
            //.font(.largeTitle)
            //.padding(150)

            TestUI1()
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

