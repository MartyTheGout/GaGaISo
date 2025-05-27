//
//  ChatRoomView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//

import SwiftUI

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ChatRoomViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onChange(of: viewModel.shouldScrollToBottom, initial: false) { _, shouldScroll in
                    if shouldScroll, let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                        viewModel.scrolledToBottom()
                    }
                }
                .onAppear {
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            messageInputView
        }
        .navigationTitle(viewModel.otherParticipantName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            Task {
                await viewModel.enterRoom()
            }
        }
        .onDisappear {
            Task {
                await viewModel.leaveRoom()
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var messageInputView: some View {
        HStack(spacing: 12) {
            TextField("메시지를 입력하세요", text: $viewModel.messageText, axis: .vertical)
                .pretendardFont(size: .body2)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray15)
                .cornerRadius(20)
                .lineLimit(1...5)
                .onSubmit {
                    if viewModel.canSendMessage {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }
                }
            
            Button(action: {
                Task {
                    await viewModel.sendMessage()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.canSendMessage ? .blackSprout : .gray45)
                }
            }
            .disabled(!viewModel.canSendMessage || viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray0)
    }
}

// MARK: - Chat Bubble View (메시지 버블)
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isMyMessage {
                Spacer(minLength: 50)
                myMessageBubble
            } else {
                otherMessageBubble
                Spacer(minLength: 50)
            }
        }
    }
    
    private var myMessageBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                if !message.isSent {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.gray60)
                }
                
                Text(message.content)
                    .pretendardFont(size: .body2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.blackSprout)
                    .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
            }
            
            Text(timeString(from: message.createdAt))
                .pretendardFont(size: .caption2)
                .foregroundColor(.gray60)
        }
    }
    
    private var otherMessageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 발신자 이름 (그룹채팅에서 사용)
            if !message.senderNick.isEmpty && !message.isMyMessage {
                Text(message.senderNick)
                    .pretendardFont(size: .caption1, weight: .medium)
                    .foregroundColor(.gray60)
                    .padding(.leading, 4)
            }
            
            Text(message.content)
                .pretendardFont(size: .body2)
                .foregroundColor(.gray90)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray15)
                .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
            
            Text(timeString(from: message.createdAt))
                .pretendardFont(size: .caption2)
                .foregroundColor(.gray60)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
