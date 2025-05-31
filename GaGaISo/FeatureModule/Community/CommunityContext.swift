//
//  CommunityContext.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//

import Foundation
import Combine

class CommunityContext: ObservableObject {
    // Output
    @Published private(set) var posts: [String: PostDTO] = [:] {
        didSet {
            print("CommunityContext updated")
            dump(posts)
        }
    }
    @Published private(set) var currentPostIds: [String] = [] {
        didSet {
            print("CommunityContext updated")
            dump(currentPostIds)
        }
    }
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var nextCursor = ""
    @Published private(set) var hasMorePosts = true
    
    // Input
    @Published var selectedDistance: Double = 300 
    @Published var selectedOrderBy: CommunityOrderCriteria = .createdAt
    @Published var selectedCategory: String = ""
    @Published var searchText: String = ""
    
    private let communityService: CommunityService
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(communityService: CommunityService, locationManager: LocationManager) {
        self.communityService = communityService
        self.locationManager = locationManager
        setupObservers()
    }
    
    private func setupObservers() {
        locationManager.$location
            .compactMap { $0 }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates { lhs, rhs in
                lhs.distance(from: rhs) < 50
            }
            .sink { [weak self] _ in
                Task {
                    await self?.refreshPosts()
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3($selectedDistance, $selectedOrderBy, $selectedCategory)
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                Task {
                    await self?.refreshPosts()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadPosts() async {
        guard let location = locationManager.location else {
            await MainActor.run {
                errorMessage = "위치 정보를 가져올 수 없습니다."
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await communityService.getPosts(
            category: selectedCategory,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            maxDistance: "\(Int(selectedDistance))",
            limit: 10,
            next: nextCursor,
            orderBy: selectedOrderBy
        )
        
        await MainActor.run {
            switch result {
            case .success(let postsDTO):
                for post in postsDTO.data {
                    self.posts[post.postID] = post
                }
                
                if nextCursor.isEmpty {
                    self.currentPostIds = postsDTO.data.map { $0.postID }
                } else {
                    self.currentPostIds.append(contentsOf: postsDTO.data.map { $0.postID })
                }
                
                self.nextCursor = postsDTO.nextCursor
                self.hasMorePosts = postsDTO.nextCursor != "0"
                print("hasMorePost = \(hasMorePosts)")
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func refreshPosts() async {
        await MainActor.run {
            nextCursor = ""
            hasMorePosts = true
            currentPostIds = []
            posts = [:]
        }
        await loadPosts()
    }
    
    func loadMorePosts() async {
        guard hasMorePosts && !isLoading else { return }
        await loadPosts()
    }
    
    func searchPosts(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await refreshPosts()
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await communityService.searchPosts(title: query)
        
        await MainActor.run {
            switch result {
            case .success(let postsDTO):
                self.posts = [:]
                for post in postsDTO.data {
                    self.posts[post.postID] = post
                }
                self.currentPostIds = postsDTO.data.map { $0.postID }
                self.hasMorePosts = false
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func toggleLike(for postId: String) async {
        guard var post = posts[postId] else { return }
        
        // Optimistic update
        post.isLike.toggle()
        post.likeCount += post.isLike ? 1 : -1
        posts[postId] = post
        
        let result = await communityService.togglePostLike(
            postId: postId,
            isLiked: post.isLike
        )
        
        switch result {
        case .success(let actualLikeStatus):
            if actualLikeStatus != post.isLike {
                post.isLike = actualLikeStatus
                post.likeCount += actualLikeStatus ? 1 : -1
                
                self.posts[postId] = post
                
            }
            
        case .failure:
            post.isLike.toggle()
            post.likeCount += post.isLike ? 1 : -1
            
            self.posts[postId] = post
            
        }
    }
    
    func post(for id: String) -> PostDTO? {
        posts[id]
    }
}
