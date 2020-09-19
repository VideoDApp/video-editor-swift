//
//  TestUI.swift
//  Zoomerok
//
//  Created by sdancer on 9/14/20.
//  Copyright © 2020 Shadurin Organization. All rights reserved.
//

import SwiftUI

struct TestUI: View {
    @State var pos: CGFloat = -10
    @State var w: CGFloat = 50


    var body: some View {
        VStack {

            Text("Hello World!")
                .frame(width: 200, height: 100)
                .background(Color.red)
            //.foregroundColor(.white)
            //.font(.largeTitle)
            //.padding(150)
              
        }
    }
}

struct TestUI_Previews: PreviewProvider {
    static var previews: some View {
        TestUI()
    }
}

//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
//
//struct RoundedCorner: Shape {
//
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
