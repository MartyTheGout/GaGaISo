//
//  TabBarButton.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blackSprout : .gray60)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
