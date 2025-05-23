//
//  CategoryView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import SwiftUI

struct CategoryItemView: View {
    let category: CategoryItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(category.isSelected ? Color.brightForsythia.opacity(0.1) : Color.white)
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(category.isSelected ? Color.brightForsythia : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(getImageName(for: category.icon))
                        .font(.title2)
                        .foregroundColor(category.isSelected ? .blackSprout : .gray60)
                }
                
                Text(category.title)
                    .pretendardFont(size: .body3, weight: .bold)
                    .foregroundColor(category.isSelected ? .blackSprout : .gray60)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getImageName(for icon: String) -> String {
        switch icon {
        case "coffee": return "coffee"
        case "fastfood": return "fastfood"
        case "desert": return "desert"
        case "bakery": return "bakery"
        case "etc": return "etc"
        default: return "questionmark.circle.fill"
        }
    }
}
