//
//  EntryView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import SwiftUI

struct AppEntryView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            ContentView()
                .fullScreenCover(isPresented: .constant(!authManager.isLoggedIn)) {
                    LoginView()
                }
        }
        .onAppear {
            Task {
                await authManager.bootstrap()
            }
        }
    }
}
