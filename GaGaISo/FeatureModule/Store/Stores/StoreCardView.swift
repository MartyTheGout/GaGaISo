////
////  StoreCard.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////
import SwiftUI

struct StoreCard: View {
    
    @StateObject var viewModel: StoreItemViewModel
    
    init(viewModel: StoreItemViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                ZStack(alignment: .topLeading) {
                    Group {
                        if let storeImage = viewModel.storeImages[safe: 0] {
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
                    .frame(width: 280, height: 150)
                    .cornerRadius(12)
                    
                    Button(action: {
                    }) {
                        Image(systemName: "heart")
                            .foregroundColor( .white)
                            .padding(8)
                            .padding(8)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            if viewModel.isPicchelin {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("픽슐랭")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blackSprout)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(8)
                            }
                        }
                        .frame(width: 280)
                    }
                }
                
                VStack(spacing: 6) {
                    Group {
                        if let storeImage = viewModel.storeImages[safe: 1] {
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
                    .frame(width: 80, height: 70)
                    .cornerRadius(8)
                    
                    Group {
                        if let storeImage = viewModel.storeImages[safe: 2] {
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
                    .frame(width: 80, height: 70)
                    .cornerRadius(8)
                }
            }
            
            HStack {
                Text(viewModel.name)
                    .foregroundStyle(.gray90)
                    .pretendardFont(size: .body1, weight: .bold)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.bubble.fill")
                        .foregroundColor(.brightForsythia)
                        .pretendardFont(size: .body1, weight: .bold)
                    
                    Text(viewModel.totalReviewCount)// Review Count 와 Rating 이 맞지 않다. 
                        .foregroundStyle(.gray90)
                        .pretendardFont(size: .body1, weight: .bold)
                    
                }
                .padding(.leading, 8)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.brightForsythia)
                        .pretendardFont(size: .body1, weight: .bold)
                    
                    Text(viewModel.totalRating)
                        .pretendardFont(size: .body1, weight: .bold)
                        .foregroundStyle(.gray90)
                }
            }
            .padding(.vertical, 4)
            
            HStack(spacing: 12) {
                Label(viewModel.distance, systemImage: "location.fill")
                    .pretendardFont(size: .body2)
                    .foregroundStyle(.blackSprout)
                
                Label(viewModel.closeTime, systemImage: "clock.fill")
                    .pretendardFont(size: .body2)
                    .foregroundStyle(.blackSprout)
                
                Label(viewModel.totalOrderCount, systemImage: "bag.fill")
                    .pretendardFont(size: .body2)
                    .foregroundStyle(.blackSprout)
            }
            
            HStack {
                ForEach(viewModel.hashTags, id: \.self) { tag in
                    Text(tag)
                        .pretendardFont(size: .caption1, weight: .bold)
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .background(.deepSprout)
                        .cornerRadius(5)
                        .foregroundColor(.gray0)
                }
            }
        }
        .background(.gray0)
        .cornerRadius(12)
        .onAppear() {
            viewModel.loadStoreImage()
        }
    }
}
