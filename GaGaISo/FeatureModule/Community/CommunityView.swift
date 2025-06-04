//
//  CommunityView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//

import SwiftUI

struct CommunityView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var viewModel: CommunityViewModel
    
    init(viewModel: CommunityViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchAndWriteSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                distanceSliderSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                titleAndFilterSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.postIds, id: \.self) { postId in
                            PostItemView(
                                viewModel: diContainer.getPostItemViewModel(postId: postId),
                                startChat: { userId in
                                    viewModel.startChatWithOwner(userId: userId)
                                }
                            )
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blackSprout)
                                .padding(.vertical, 20)
                        }
                        
                        if viewModel.hasMorePosts && !viewModel.isLoading {
                            Button(action: {
                                Task {
                                    await viewModel.loadMorePosts()
                                }
                            }) {
                                Text("더보기")
                                    .pretendardFont(size: .body2, weight: .medium)
                                    .foregroundColor(.blackSprout)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray15)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    await viewModel.refreshPosts()
                }
            }
            .background(Color.gray15.ignoresSafeArea())
            .sheet(isPresented: $viewModel.showingWritePost) {
                Text("글쓰기 화면") // 임시
            }
            .sheet(isPresented: $viewModel.showChatRoom) {
                if let roomId = viewModel.chatRoomId {
                    ChatRoomView(
                        viewModel: diContainer.getChatRoomViewModel(roomId: roomId)
                    )
                } else {
                    ProgressView("채팅방을 준비하는 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Search TextField + Post Writing Button
    private var searchAndWriteSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray60)
                    .font(.system(size: 16))
                
                TextField("검색어를 입력해주세요", text: $viewModel.searchText)
                    .pretendardFont(size: .body2, weight: .regular)
                    .foregroundColor(.gray90)
                    .onSubmit {
                        Task {
                            await viewModel.searchPosts()
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray0)
            .cornerRadius(12)
            
            Button(action: {
                viewModel.showWritePost()
            }) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(.blackSprout)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Distance Slider
    private var distanceSliderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Distance")
                    .pretendardFont(size: .body3, weight: .medium)
                    .foregroundColor(.gray60)
                
                Spacer()
                
                Text("\(Int(viewModel.selectedDistance))M")
                    .pretendardFont(size: .body3, weight: .bold)
                    .foregroundColor(.blackSprout)
            }
            
            HStack(spacing: 8) {
                ForEach(0..<12, id: \.self) { index in
                    let distance = Double((index + 1) * 100) // 100m, 200m, ..., 1200m
                    let isSelected = abs(viewModel.selectedDistance - distance) < 50
                    
                    Button(action: {
                        viewModel.updateDistance(distance)
                    }) {
                        Circle()
                            .fill(isSelected ? .blackSprout : .gray30)
                            .frame(width: 16, height: 16)
                    }
                }
                
                Spacer()
                
                ForEach(0..<3, id: \.self) { index in
                    let isSelected = false
                    
                    Circle()
                        .fill(isSelected ? .blackSprout : .gray30)
                        .frame(width: 16, height: 16)
                }
            }
        }
    }
    
    private var titleAndFilterSection: some View {
        HStack {
            Text("타임라인")
                .pretendardFont(size: .body2, weight: .bold)
                .foregroundColor(.gray90)
            
            Spacer()
            
            Button(action: {
                if viewModel.selectedOrderBy == .createdAt {
                    viewModel.updateOrderBy(.likes)
                } else {
                    viewModel.updateOrderBy(.createdAt)
                }
            }) {
                HStack(spacing: 4) {
                    Text(viewModel.selectedOrderBy == .createdAt ? "최신순" : "좋아요순")
                        .pretendardFont(size: .caption1, weight: .semibold)
                        .foregroundStyle(.blackSprout)
                    
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.caption)
                        .foregroundStyle(.blackSprout)
                }
            }
        }
    }
}
