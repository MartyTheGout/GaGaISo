//
//  FavoriteSectionView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import SwiftUI

struct FavoriteStoresSection: View {
    @Binding var currentTab: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("내가 가간 가게")
                    .pretendardFont(size: .body2, weight: .bold)
                
                Spacer()
                
                Button(action: {
                }) {
                    HStack {
                        Text("거리순")
                            .pretendardFont(size: .caption1, weight: .semibold)
                            .foregroundStyle(.blackSprout)
                        
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.caption)
                            .foregroundStyle(.blackSprout)
                    }
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                Button(action: {
                    currentTab = 0
                }) {
                    HStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(currentTab == 0 ? .blackSprout : .brightSprout)
                        
                        Text("픽슐랭")
                            .pretendardFont(size: .caption1, weight: .semibold)
                            .foregroundColor(currentTab == 0 ? .blackSprout : .brightSprout)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    
                }
                
                Button(action: {
                    currentTab = 1
                }) {
                    HStack {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(currentTab == 1 ? .blackSprout : .brightSprout)
                        
                        Text("My Pick")
                            .pretendardFont(size: .caption1, weight: .semibold)
                            .foregroundColor(currentTab == 1 ? .blackSprout : .brightSprout)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    FavoriteStoresSection(currentTab: .constant(0))
}
