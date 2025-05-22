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
                Image(systemName: getSystemImageName(for: category.icon))
                    .font(.title2)
                    .foregroundColor(category.isSelected ? .blue : .gray)
                
                Text(category.title)
                    .font(.caption)
                    .foregroundColor(category.isSelected ? .blue : .gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getSystemImageName(for icon: String) -> String {
        switch icon {
        case "coffee": return "cup.and.saucer.fill"
        case "fastfood": return "takeoutbag.and.cup.and.straw.fill"
        case "desert": return "birthday.cake.fill"
        case "bakery": return "croissant.fill"
        case "etc": return "ellipsis.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
}
