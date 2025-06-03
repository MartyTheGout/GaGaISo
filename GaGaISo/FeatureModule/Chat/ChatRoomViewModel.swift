//
//  ChatRoomViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//
import Foundation
import Combine

class ChatRoomViewModel: ObservableObject {
    let roomId: String
    private let chatContext: ChatContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var messages: [ChatMessage] = []
    @Published var messageText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldScrollToBottom = false
    
    init(roomId: String, chatContext: ChatContext) {
        self.roomId = roomId
        self.chatContext = chatContext
        chatContext.initializeWithLocationDB() // TODO: fix it later
        
        setupObservers()
    }
    
    private func setupObservers() {
        chatContext.$currentMessages
            .sink { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &cancellables)
        
        
        chatContext.$errorMessage
            .sink { [weak self] error in
                self?.errorMessage = error
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Properties
    var chatRoom: ChatRoom? {
        chatContext.getChatRoom(by: roomId)
    }
    
    var otherParticipantName: String {
        chatRoom?.otherParticipant?.nick ?? "알 수 없음"
    }
    
    var canSendMessage: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Public Methods
    func enterRoom() async {
        await chatContext.enterChatRoom(roomId)
    }
    
    func leaveRoom() async {
        await chatContext.leaveChatRoom()
    }
    
    func sendMessage() async {
        guard canSendMessage else { return }
        
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        await MainActor.run {
            messageText = ""
            isLoading = true
        }
        
        let success = await chatContext.sendMessage(content: content)
        
        await MainActor.run {
            isLoading = false
            if !success {
                errorMessage = "메시지 전송에 실패했습니다."
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func scrolledToBottom() {
        shouldScrollToBottom = false
    }
}
