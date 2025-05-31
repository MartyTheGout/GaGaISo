//
//  PostItemView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//

import SwiftUI

struct PostItemView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject var viewModel: PostItemViewModel
    
    init(viewModel: PostItemViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            authorSection
            
            if viewModel.hasImages {
                imageSection
            }
            
            contentSection
        
            statsSection
            
            if viewModel.hasStore {
                storeSection
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray0)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            viewModel.loadPostImages()
        }
    }
    
    private var authorSection: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.gray15)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray60)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.authorName)
                    .pretendardFont(size: .body3, weight: .medium)
                    .foregroundColor(.gray90)
                
                Text(viewModel.createdAt)
                    .pretendardFont(size: .caption1)
                    .foregroundColor(.gray60)
            }
            
            Spacer()
        }
    }
    
    private var imageSection: some View {
        VStack {
            if viewModel.isImageLoading {
                HStack {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray15)
                            .frame(height: 120)
                            .overlay(
                                ProgressView()
                                    .tint(.blackSprout)
                            )
                    }
                }
            } else if !viewModel.postImages.isEmpty {
                imageGrid
            } else {
                HStack {
                    ForEach(0..<min(3, viewModel.imageUrls.count), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray15)
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray60)
                                    .font(.title2)
                            )
                    }
                }
            }
        }
    }
    
    private var imageGrid: some View {
        HStack(spacing: 4) {
            if viewModel.postImages.count == 1 {
                Image(uiImage: viewModel.postImages[0])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            } else if viewModel.postImages.count == 2 {
                ForEach(0..<2, id: \.self) { index in
                    Image(uiImage: viewModel.postImages[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                }
            } else {
                Image(uiImage: viewModel.postImages[0])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width * 0.5, height: 200)
                    .clipped()
                    .cornerRadius(8)
                
                VStack(spacing: 4) {
                    ForEach(1..<min(3, viewModel.postImages.count), id: \.self) { index in
                        ZStack {
                            Image(uiImage: viewModel.postImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 96)
                                .clipped()
                                .cornerRadius(8)
                            
                            if index == 2 && viewModel.additionalImageCount > 0 {
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .cornerRadius(8)
                                    .overlay(
                                        Text("+\(viewModel.additionalImageCount)")
                                            .pretendardFont(size: .body1, weight: .bold)
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .pretendardFont(size: .body1, weight: .bold)
                .foregroundColor(.gray90)
                .lineLimit(2)
            
            if !viewModel.content.isEmpty {
                Text(viewModel.content)
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray75)
                    .lineLimit(3)
            }
        }
    }
    
    private var statsSection: some View {
        HStack {
            Button(action: {
                viewModel.toggleLike()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isLiked ? .red : .gray60)
                        .pretendardFont(size: .body3)
                    
                    Text(viewModel.likeCountText)
                        .pretendardFont(size: .body3)
                        .foregroundColor(.gray60)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .foregroundColor(.blackSprout)
                    .font(.caption)
                
                Text(viewModel.distance)
                    .pretendardFont(size: .body3)
                    .foregroundColor(.blackSprout)
            }
        }
    }
    
    private var storeSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "storefront")
                .foregroundColor(.deepSprout)
                .font(.caption)
            
            Text(viewModel.storeName)
                .pretendardFont(size: .body3, weight: .medium)
                .foregroundColor(.deepSprout)
            
            Spacer()
            
            Button(action: {
                // 스토어 상세로 이동
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.deepSprout)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray15)
        .cornerRadius(8)
    }
}
