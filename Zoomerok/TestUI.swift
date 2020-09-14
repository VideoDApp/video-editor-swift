//
//  TestUI.swift
//  Zoomerok
//
//  Created by sdancer on 9/14/20.
//  Copyright © 2020 Shadurin Organization. All rights reserved.
//

import SwiftUI

struct TestUI: View {
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text("Hello World")
                    .font(.title)


            }
            Spacer()
        }.background(Color.red)
    }
}

struct TestUI_Previews: PreviewProvider {
    static var previews: some View {
        TestUI()
    }
}
