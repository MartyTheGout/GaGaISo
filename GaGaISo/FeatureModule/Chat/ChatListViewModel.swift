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
    
    @Published var availableUsers: [Participant] = [
        Participant(userId: "1", nick: "김가가", profileImage: nil),
        Participant(userId: "2", nick: "이이소", profileImage: nil),
        Participant(userId: "3", nick: "박맛집", profileImage: nil),
        Participant(userId: "4", nick: "최치킨", profileImage: nil),
        Participant(userId: "5", nick: "정피자", profileImage: nil)
    ]
    
    init(chatContext: ChatContext) {
        self.chatContext = chatContext
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
    
    var filteredUsers: [Participant] {
        if searchText.isEmpty {
            return availableUsers
        } else {
            return availableUsers.filter {
                $0.nick.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Public Methods
    func loadChatRooms() async {
        print(self, #function)
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
