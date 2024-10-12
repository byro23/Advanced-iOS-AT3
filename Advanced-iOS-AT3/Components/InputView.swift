//
//  InputView.swift
//  Advanced-iOS_AT2
//
//  Created by Byron Lester on 4/9/2024.
//

import Foundation
import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecuredField: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.semibold)
                .padding(.leading)
            if(isSecuredField) {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
                
            }
            else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "emailhere@domain.com", isSecuredField: false)
}
