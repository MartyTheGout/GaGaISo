//
//  LocationRevealingView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/20/25.
//

import SwiftUI
import CoreLocation

struct LocationRevealingView: View {
    @StateObject private var viewModel: LocationRevealingViewModel
    
    init(viewModel: LocationRevealingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("현재 위치")
                    .font(.headline)
                
                switch viewModel.locationState {
                case .idle:
                    Text("위치 정보 준비 중...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                case .loading:
                    HStack {
                        ProgressView()
                            .padding(.trailing, 8)
                        Text("위치 정보를 가져오는 중...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case .success:
                    Text(viewModel.address)
                        .font(.body)
                    
                    if let location = viewModel.currentLocation {
                        Text("좌표: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                case .error(let error):
                    Text("오류: \(error.localizedDescription)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    Button("다시 시도") {
                        viewModel.startLocationUpdates()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}
