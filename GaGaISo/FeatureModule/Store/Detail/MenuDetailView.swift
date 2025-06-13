//
//  MenuDetailView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import SwiftUI

struct MenuDetailView: View {
    @StateObject var viewModel: MenuDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: MenuDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            menuImageSection
            
            menuInfoSection
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadMenuImage()
        }
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
    
    private var menuImageSection: some View {
        ZStack {
            if let menuImage = viewModel.menuImage {
                Image(uiImage: menuImage)
                    .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
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
    }
    
    private var menuInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.menu.name)
                .pretendardFont(size: .title1, weight: .bold)
                .foregroundColor(.gray90)
            
            Text(viewModel.menu.description)
                .pretendardFont(size: .body1)
                .foregroundColor(.gray60)
                .lineLimit(2)
            
            Spacer()
            
            HStack {
                Text("수량")
                    .pretendardFont(size: .body2, weight: .medium)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.decreaseQuantity()
                    }) {
                        Image(systemName: "minus")
                            .frame(width: 32, height: 32)
                            .background(Color.brightSprout.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.quantity <= 1)
                    
                    Text("\(viewModel.quantity)개")
                        .pretendardFont(size: .body2, weight: .bold)
                        .frame(minWidth: 50)
                    
                    Button(action: {
                        viewModel.increaseQuantity()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.brightSprout)
                            .clipShape(Circle())
                    }
                }
            }
            
            HStack {
                Text(viewModel.formattedTotalPrice)
                    .pretendardFont(size: .title1, weight: .bold)
                    .foregroundColor(.gray90)
                
                Spacer()
                
                Button(action: {
                    viewModel.addToOrder()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("추가하기")
                        .pretendardFont(size: .body1, weight: .bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.brightForsythia)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.gray0)
    }
}
