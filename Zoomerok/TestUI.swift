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
            ZStack(alignment: .leading) {

                Rectangle()
                    .frame(width: 50, height: 50)
                    .border(Color.blue)
                    .foregroundColor(Color.red)
                    

                Rectangle()
                    .frame(width: self.w, height: 50)
                    .border(Color.orange)
                    .offset(x: pos, y: 10)
                    .foregroundColor(Color.green)
                    

                Button("Resize +") {
                    self.pos -= 5
                    self.w += 5
                }.offset(x: 0, y: 100)
                
                Button("Resize -") {
                    self.pos += 5
                    self.w -= 5
                }.offset(x: 0, y: 150)

            }

//            HStack(spacing: 0) {
//                ZStack() {
//                    Rectangle()
//                        .frame(width: 50, height: 50)
//                        .foregroundColor(Color.red)
//
//                    Rectangle()
//                        .frame(width: 50, height: 50)
//                        .foregroundColor(Color.green)
//
//                    Rectangle()
//                        .frame(width: 50, height: 50)
//                        .foregroundColor(Color.blue)
//                }
//            }
        }
    }
}

struct TestUI_Previews: PreviewProvider {
    static var previews: some View {
        TestUI()
    }
}
