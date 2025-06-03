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
                //
            }
            .onAppear {
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
                    viewModel.deleteChatRoom(at: offsets)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Chat Room Row View
struct ChatRoomRowView: View {
    let room: ChatRoom
    
    var body: some View {
        HStack(spacing: 12) {
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
                    Text(room.otherParticipant?.nick ?? "알 수 없음")
                        .pretendardFont(size: .body2, weight: .bold)
                        .foregroundColor(.gray90)
                    
                    Spacer()
                    
                    Text(timeString(from: room.updatedAt))
                        .pretendardFont(size: .caption1)
                        .foregroundColor(.gray60)
                }
                
                HStack {
                    Text(room.lastMessage?.content ?? "채팅을 시작해보세요!")
                        .pretendardFont(size: .body3)
                        .foregroundColor(.gray60)
                        .lineLimit(1)
                    
                    Spacer()
                    
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
           
           // timeString: "오늘"
           if calendar.isDate(date, inSameDayAs: now) {
               let formatter = DateFormatter()
               formatter.timeStyle = .short
               return formatter.string(from: date)
           }
           
           // timeString: "어제"
           if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
              calendar.isDate(date, inSameDayAs: yesterday) {
               return "어제"
           }
           
           // timeString: e.g. "5/28"
           let formatter = DateFormatter()
           formatter.dateFormat = "M/d"
           return formatter.string(from: date)
       }
}
