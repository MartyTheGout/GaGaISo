//
//  TabBar.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI

enum Tab {
    case home, orders, favorites, profile
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var isMiddleButtonActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(.white)
                .frame(height: 80)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
            
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "house.fill",
                    isSelected: selectedTab == .home,
                    action: { selectedTab = .home }
                )
                
                TabBarButton(
                    icon: "doc.text.fill",
                    isSelected: selectedTab == .orders,
                    action: { selectedTab = .orders }
                )
                
                ZStack {
                    Circle()
                        .fill(.blackSprout)
                        .frame(width: 70, height: 70)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(y: -20)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isMiddleButtonActive.toggle()
                    }
                }
                
                TabBarButton(
                    icon: "person.2.fill",
                    isSelected: selectedTab == .favorites,
                    action: { selectedTab = .favorites }
                )
                
                TabBarButton(
                    icon: "person.circle.fill",
                    isSelected: selectedTab == .profile,
                    action: { selectedTab = .profile }
                )
            }
            .padding(.bottom, 20) // Account for bottom safe area
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.favorites), isMiddleButtonActive: .constant(false))
}
