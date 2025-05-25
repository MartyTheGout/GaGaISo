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
                        
                        Text("리뷰")
                            .foregroundStyle(.blackSprout)
                            .pretendardFont(size: .body3, weight: .bold)
                           
                        Text(viewModel.totalReviewCount)
                            .foregroundStyle(.gray90)
                            .pretendardFont(size: .body3, weight: .bold)
                    }
                }
                
                HStack(spacing: 12) {
                    Label(viewModel.totalOrderCount, systemImage: "bag.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                    
                    Label(viewModel.closeTime, systemImage: "clock.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                    
                    Label(viewModel.totalRating, systemImage: "star.bubble")
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
        .background(.clear)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        .onAppear() {
            viewModel.loadStoreImage()
        }
    }
}
