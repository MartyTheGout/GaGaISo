//
//  LocationRevealingView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/20/25.
//

import SwiftUI

struct LocationRevealingView: View {
    @StateObject private var viewModel: LocationRevealingViewModel
    
    init(viewModel: LocationRevealingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "location.fill")
                .font(.system(size: 16))
            
            Text(viewModel.displayLocation)
                .pretendardFont(size: .body1, weight: .bold)
        
            Spacer()
        }
        .foregroundStyle(.gray90)
        .padding(.horizontal)
        .onAppear {
            viewModel.startLocationUpdates()
        }
        .onDisappear {
            viewModel.stopLocationUpdates()
        }
    }
}
