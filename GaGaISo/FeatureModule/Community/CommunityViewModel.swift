//
//  CommunityViewMoel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//
import Foundation
import Combine

class CommunityViewModel: ObservableObject {
    
    private let communityContext: CommunityContext
    private let chatContext: ChatContext
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var searchText = ""
    @Published var showingWritePost = false
    
    @Published var showChatRoom = false
    @Published var isChatLoading = false
    @Published var chatRoomId: String?
    
    @Published var chatErrorMessage: String?
    
    @Published var selectedDistance: Double = 300 {
        didSet {
            if selectedDistance != oldValue {
                communityContext.selectedDistance = selectedDistance
            }
        }
    }
    
    @Published var selectedOrderBy: CommunityOrderCriteria = .createdAt {
        didSet {
            if selectedOrderBy != oldValue {
                communityContext.selectedOrderBy = selectedOrderBy
            }
        }
    }
    
    @Published var selectedCategory: String = "" {
        didSet {
            if selectedCategory != oldValue {
                communityContext.selectedCategory = selectedCategory
            }
        }
    }
    
    init(communityContext: CommunityContext, chatContext: ChatContext) {
        self.communityContext = communityContext
        self.chatContext = chatContext
        setupObservers()
    }
    
    private func setupObservers() {
        communityContext.$currentPostIds
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        communityContext.$isLoading
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        communityContext.$errorMessage
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Properties
    var postIds: [String] {
        communityContext.currentPostIds
    }
    
    var isLoading: Bool {
        communityContext.isLoading
    }
    
    var errorMessage: String? {
        communityContext.errorMessage
    }
    
    var hasMorePosts: Bool {
        communityContext.hasMorePosts
    }
    
    // MARK: - Public Methods
    func loadPosts() async {
        await communityContext.loadPosts()
    }
    
    func refreshPosts() async {
        await communityContext.refreshPosts()
    }
    
    func loadMorePosts() async {
        await communityContext.loadMorePosts()
    }
    
    func searchPosts() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        await communityContext.searchPosts(query: query)
    }
    
    func showWritePost() {
        showingWritePost = true
    }
    
    func hideWritePost() {
        showingWritePost = false
    }
    
    func updateDistance(_ distance: Double) {
        selectedDistance = distance
    }
    
    func updateOrderBy(_ orderBy: CommunityOrderCriteria) {
        selectedOrderBy = orderBy
    }
    
    func updateCategory(_ category: String) {
        selectedCategory = category
    }
}


extension CommunityViewModel {
    func startChatWithOwner(userId: String) {
        Task {
            await MainActor.run {
                isChatLoading = true
                chatErrorMessage = nil
            }
            
            if let chatRoom = await chatContext.createOrGetChatRoom(with: userId) {
                print("chatRoomnumber came: \(chatRoom)")
                
                await MainActor.run {
                    self.chatRoomId = chatRoom.id
                    self.showChatRoom = true
                    self.isChatLoading = false
                }
            } else {
                await MainActor.run {
                    self.chatErrorMessage = "채팅방 생성에 실패했습니다."
                    self.isChatLoading = false
                }
            }
        }
    }
}
