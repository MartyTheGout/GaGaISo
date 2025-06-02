//
//  ProfileView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.diContainer) private var diContainer
    
    var body: some View {
        
        Text("Profile")
            .font(.largeTitle)
        
        ChatListView(viewModel: diContainer.getChatListViewModel())
    }
}
