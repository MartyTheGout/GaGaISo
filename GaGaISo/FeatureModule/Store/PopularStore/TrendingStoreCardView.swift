////
////  StoreCard.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////

import SwiftUI

struct TrendingStoreCard: View {
    
    @StateObject var viewModel: TrendingStoreCardViewModel
    
    init(viewModel: TrendingStoreCardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let storeImage = viewModel.storeImage {
                    Image(uiImage: storeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if viewModel.isImageLoading {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                            .tint(.blackSprout)
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    }
                }
            }
            .frame(width: 250, height: 200)
            .clipped()
            
            VStack {
                HStack {
                    Button(action: {
                        viewModel.toggleLike()
                    }) {
                        Image(systemName: viewModel.isPick ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isPick ? .red : .white)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    if viewModel.isPicchelin {
                        Button(action: {
                            // 픽슐랭 액션
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .font(.caption2)
                                Text("픽슐랭")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blackSprout)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(8)
                    }
                }
                .frame(width: 250)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewModel.name)
                        .foregroundStyle(.gray90)
                        .pretendardFont(size: .body3, weight: .bold)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.brightForsythia)
                            .pretendardFont(size: .body3, weight: .bold)
                        
                        Text("\(viewModel.totalReviewCount)개")
                            .foregroundStyle(.gray90)
                            .pretendardFont(size: .body3, weight: .bold)
                    }
                }
                
                HStack(spacing: 12) {
                    Label("\(String(format: "%.1f", viewModel.distance))km", systemImage: "location.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                    
                    Label(viewModel.closeTime, systemImage: "clock.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                    
                    Label("\(viewModel.pickCount)회", systemImage: "person.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                .gray0
            )
            .frame(width: 250)
        }
        .frame(width: 250, height: 200)
        .cornerRadius(12)
        .onAppear() {
            viewModel.loadStoreImage()
        }
    }
}
