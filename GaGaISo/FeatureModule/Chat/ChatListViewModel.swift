//
//  ChatListViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//

import Foundation
import Combine

class ChatListViewModel: ObservableObject {
    private let chatContext: ChatContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showingNewChatSheet = false
    @Published var searchText = ""
    @Published var selectedUsers: [Participant] = []
    
    init(chatContext: ChatContext) {
        self.chatContext = chatContext
        chatContext.initializeWithLocationDB() //HISTORY: having userRealmManager dependency, which also depends on AuthManager lead to the isuse that realm cannot be used without currentUserId, To delay the ChatContext's complete initialization with local data, push it later with "initializeWithLocationDB()". and call it when ChatList i
    }
    
    // MARK: - Public Properties
    var chatRooms: [ChatRoom] {
        chatContext.chatRooms
    }
    
    var isLoading: Bool {
        chatContext.isLoading
    }
    
    var totalUnreadCount: Int {
        chatContext.totalUnreadCount
    }
    
    // MARK: - Public Methods
    func loadChatRooms() async {
        await chatContext.loadChatRoomsPublic()
    }
    
    func refreshChatRooms() async {
        await chatContext.refreshChatRooms()
    }
    
    func createChatRoom(with user: Participant) async -> Bool {
        if let _ = await chatContext.createOrGetChatRoom(with: user.userId) {
            await MainActor.run {
                showingNewChatSheet = false
            }
            return true
        }
        return false
    }
    
    func deleteChatRoom(at offsets: IndexSet) {
        for index in offsets {
            let roomId = chatRooms[index].id
            chatContext.deleteChatRoom(roomId)
        }
    }
    
    func showNewChatSheet() {
        showingNewChatSheet = true
    }
    
    func hideNewChatSheet() {
        showingNewChatSheet = false
    }
}
