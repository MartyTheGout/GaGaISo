//
//  LocationRevealingView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/20/25.
//

import SwiftUI
import ComposableArchitecture

struct LocationRevealingView: View {
    let store: StoreOf<LocationRevealingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                VStack(alignment: .leading) {
                    Text("현재 위치")
                        .font(.headline)
                    
                    switch viewStore.locationState {
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
                        Text(viewStore.address)
                            .font(.body)
                        
                        if let location = viewStore.currentLocation {
                            Text("좌표: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                    case .error(let error):
                        Text("오류: \(error.localizedDescription)")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        
                        Button("다시 시도") {
                            viewStore.send(.startLocationUpdates)
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
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
    }
}
