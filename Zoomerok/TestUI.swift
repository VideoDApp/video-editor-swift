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
        HStack(spacing: 0) {
            ZStack() {
                Rectangle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.red)
        
                Rectangle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.green)
           
                Rectangle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.blue)
            }
        }
    }
}

struct TestUI_Previews: PreviewProvider {
    static var previews: some View {
        TestUI()
    }
}
