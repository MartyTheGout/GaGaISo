//
//  HomeView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Text("Home")
                .font(.largeTitle)
                .padding()
            
            LocationRevealingView(viewModel: diContainer.getLocationViewModel())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
        .onAppear {

            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}
