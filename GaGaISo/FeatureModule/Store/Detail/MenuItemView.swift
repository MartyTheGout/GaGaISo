//
//  MenuItemView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/25/25.
//

import SwiftUI

struct MenuItemView: View {
    @StateObject var viewModel: MenuItemViewModel
    
    init(viewModel: MenuItemViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewModel.name)
                        .pretendardFont(size: .body2, weight: .bold)
                        .foregroundColor(.gray90)
                    
                    if viewModel.isSoldOut {
                        Text("품절")
                            .pretendardFont(size: .caption2, weight: .bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.red)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                Text(viewModel.description)
                    .pretendardFont(size: .body3)
                    .foregroundColor(.gray60)
                    .lineLimit(2)
                
                Text(viewModel.formattedPrice)
                    .pretendardFont(size: .body2, weight: .bold)
                    .foregroundColor(.gray90)
                
                if !viewModel.tags.isEmpty {
                    HStack {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            Text(tag)
                                .pretendardFont(size: .caption2)
                                .foregroundColor(.deepSprout)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.deepSprout.opacity(0.1))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                }
            }
            
            // 메뉴 이미지
            Group {
                if let menuImage = viewModel.menuImage {
                    Image(uiImage: menuImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if viewModel.isImageLoading {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                            .tint(.blackSprout)
                    }
                } else if viewModel.hasImage {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
        }
        .padding(.vertical, 8)
        .opacity(viewModel.isSoldOut ? 0.6 : 1.0)
        .onAppear {
            viewModel.loadMenuImage()
        }
    }
}
