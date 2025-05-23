//
//  SwiftUIView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/16/25.
//

import SwiftUI

struct InputField: View {
    let title: String
    let text: String
    let errorMessage: String
    var isSecure: Bool = false
    let isTouched: Bool
    let isValid: Bool
    let onTextChanged: (String) -> Void
    var onFocusChanged: ((Bool) -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .pretendardFont(size: .body1, weight: .bold)
                    .foregroundStyle(.gray75)
                
                Spacer()
                
                if !isValid && isTouched {
                    Text(errorMessage)
                        .pretendardFont(size: .caption2, weight: .bold)
                        .foregroundStyle(.red)
                }
            }
            
            Group {
                if isSecure {
                    SecureField("", text: Binding(
                        get: { text },
                        set: { onTextChanged($0) }
                    ))
                    .focused($isFocused)
                } else {
                    TextField("", text: Binding(
                        get: { text },
                        set: { onTextChanged($0) }
                    ))
                    .focused($isFocused)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .onChange(of: isFocused, initial: false) { _, newValue in
                onFocusChanged?(newValue)
            }
        }
    }
}
