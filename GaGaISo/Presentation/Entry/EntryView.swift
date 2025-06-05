//
//  EntryView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import SwiftUI

struct AppEntryView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var viewModel: AppEntryViewModel
    
    init(viewModel: AppEntryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        print("EntryView" + #function)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                ContentView()
            } else {
                NavigationStack {
                    LoginView(viewModel: diContainer.getLogInViewModel())
                }
            }
        }
    }
}
