//
//  ChatListView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//

import SwiftUI

struct ChatListView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var viewModel: ChatListViewModel
    
    init(viewModel: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading && viewModel.chatRooms.isEmpty {
                    loadingView
                } else if viewModel.chatRooms.isEmpty {
                    emptyStateView
                } else {
                    chatRoomsList
                }
            }
            .navigationTitle("채팅")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showNewChatSheet()
                    }) {
                        Image(systemName: "plus.message")
                            .foregroundColor(.blackSprout)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewChatSheet) {
                NewChatView(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.refreshChatRooms()
            }
            .onAppear {
                viewModel.connectSocket()
                Task {
                    await viewModel.loadChatRooms()
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .tint(.blackSprout)
            Text("채팅 목록을 불러오는 중...")
                .pretendardFont(size: .body2)
                .foregroundColor(.gray60)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.gray45)
            
            Text("아직 채팅이 없어요")
                .pretendardFont(size: .body1, weight: .bold)
                .foregroundColor(.gray60)
            
            Text("새로운 채팅을 시작해보세요!")
                .pretendardFont(size: .body3)
                .foregroundColor(.gray45)
            
            Button(action: {
                viewModel.showNewChatSheet()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("새 채팅 시작")
                }
                .pretendardFont(size: .body2, weight: .medium)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.blackSprout)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatRoomsList: some View {
        List {
            ForEach(viewModel.chatRooms) { room in
                NavigationLink {
                    ChatRoomView(viewModel: diContainer.getChatRoomViewModel(roomId: room.id))
                } label: {
                    ChatRoomRowView(room: room)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete { offsets in
                Task {
                    await viewModel.deleteChatRoom(at: offsets)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Chat Room Row View (채팅방 리스트 행)
struct ChatRoomRowView: View {
    let room: ChatRoom
    
    var body: some View {
        HStack(spacing: 12) {
            // 프로필 이미지
            AsyncImage(url: URL(string: room.otherParticipant?.profileImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray15)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray60)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // 이름
                    Text(room.otherParticipant?.nick ?? "알 수 없음")
                        .pretendardFont(size: .body2, weight: .bold)
                        .foregroundColor(.gray90)
                    
                    Spacer()
                    
                    // 시간
                    Text(timeString(from: room.updatedAt))
                        .pretendardFont(size: .caption1)
                        .foregroundColor(.gray60)
                }
                
                HStack {
                    // 마지막 메시지
                    Text(room.lastMessage?.content ?? "채팅을 시작해보세요!")
                        .pretendardFont(size: .body3)
                        .foregroundColor(.gray60)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 미읽은 메시지 개수
                    if room.unreadCount > 0 {
                        Text("\(room.unreadCount)")
                            .pretendardFont(size: .caption2, weight: .bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func timeString(from date: Date) -> String {
           let now = Date()
           let calendar = Calendar.current
           
           // 오늘인지 확인
           if calendar.isDate(date, inSameDayAs: now) {
               let formatter = DateFormatter()
               formatter.timeStyle = .short
               return formatter.string(from: date)
           }
           
           // 어제인지 확인
           if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
              calendar.isDate(date, inSameDayAs: yesterday) {
               return "어제"
           }
           
           // 그 외의 경우
           let formatter = DateFormatter()
           formatter.dateFormat = "M/d"
           return formatter.string(from: date)
       }
}

// MARK: - New Chat View (새 채팅 생성 화면)
struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ChatListViewModel
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // 검색 바
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray60)
                    
                    TextField("사용자 검색", text: $viewModel.searchText)
                        .pretendardFont(size: .body2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray15)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 사용자 목록
                List(viewModel.filteredUsers, id: \.userId) { user in
                    Button(action: {
                        Task {
                            await createChatRoom(with: user)
                        }
                    }) {
                        HStack(spacing: 12) {
                            // 프로필 이미지
                            Circle()
                                .fill(Color.gray15)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray60)
                                )
                            
                            Text(user.nick)
                                .pretendardFont(size: .body2)
                                .foregroundColor(.gray90)
                            
                            Spacer()
                            
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(isLoading)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("새 채팅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        viewModel.hideNewChatSheet()
                    }
                }
            }
        }
    }
    
    private func createChatRoom(with user: Participant) async {
        isLoading = true
        let success = await viewModel.createChatRoom(with: user)
        isLoading = false
        
        if success {
            dismiss()
        }
    }
}
