//
//  StoreDetailViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/25/25.
//


import Foundation
import Combine
import SwiftUI

class StoreDetailViewModel: ObservableObject {
    let storeId: String
    
    private let storeService: StoreService
    private let imageService: ImageService
    private let chatContext: ChatContext

    private var cancellables = Set<AnyCancellable>()
    
    @Published var storeImages: [UIImage] = []
    @Published var isImageLoading: Bool = false
    @Published var imageLoadError: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var showChatRoom: Bool = false
    @Published var chatRoomId: String?
    @Published var isChatLoading: Bool = false
    
    var storeDetail: StoreDetailDTO? {
        didSet {
            self.loadStoreImagesIfNeeded()
        }
    }
    
    init(storeId: String, storeService: StoreService, imageService: ImageService, chatContext: ChatContext) {
        self.storeId = storeId
        self.storeService = storeService
        self.imageService = imageService
        self.chatContext = chatContext
    }
    
    func loadStoreDetail() async {
        if storeDetail == nil {
            let result = await storeService.getStoreDetail(storeId: storeId)
            switch result {
            case .success(let storeDetail):
                self.storeDetail = storeDetail
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadStoreImagesIfNeeded() {
        guard let storeDetail, !storeDetail.storeImageUrls.isEmpty else { return }
        
        if !storeImages.isEmpty || isImageLoading { return }
        
        loadStoreImages()
    }
    
    private func loadStoreImages() {
        guard let storeDetail, !storeDetail.storeImageUrls.isEmpty else { return }
        
        let imageUrls = storeDetail.storeImageUrls
        
        Task { @MainActor in
            isImageLoading = true
            imageLoadError = nil
            storeImages.removeAll()
            
            for imageUrl in imageUrls {
                let result = await imageService.fetchImageWith(urlString: imageUrl)
                
                switch result {
                case .success(let image):
                    if let image = image {
                        self.storeImages.append(image)
                    }
                case .failure(let error):
                    print("이미지 로드 실패: \(error.localizedDescription)")
                }
            }
            self.isImageLoading = false
        }
    }
    
    func toggleLike(for storeId: String) async {
        guard var storeDetail else { return }
        
        storeDetail.isPick.toggle()
        
        let result = await storeService.updateStoreLike(
            storeId: storeId,
            isLiked: storeDetail.isPick
        )
        
        switch result {
        case .success(let actualLikeStatus):
            if actualLikeStatus != storeDetail.isPick {
                storeDetail.isPick = actualLikeStatus
            }
            
        case .failure(let error):
            storeDetail.isPick.toggle()
            errorMessage = error.localizedDescription
        }
    }
    
    func startChatWithOwner() {
        guard let ownerId = storeDetail?.creator.userID else {
            errorMessage = "사장님 정보를 찾을 수 없습니다."
            return
        }
        
        Task {
            await MainActor.run {
                isChatLoading = true
                errorMessage = nil
            }
            print("ownerId sent: \(ownerId)")
            
            if let chatRoom = await chatContext.createOrGetChatRoom(with: ownerId) {
                print("chatRoomnumber came: \(chatRoom)")
                
                await MainActor.run {
                    self.chatRoomId = chatRoom.id
                    self.showChatRoom = true
                    self.isChatLoading = false
                }
            } else {
                await MainActor.run {
                    self.errorMessage = "채팅방 생성에 실패했습니다."
                    self.isChatLoading = false
                }
            }
        }
    }
}

extension StoreDetailViewModel {
    var hasStore: Bool {
        storeDetail != nil
    }
    
    var name: String {
        storeDetail?.name ?? "로딩 중..."
    }
    
    var isPick: Bool {
        storeDetail?.isPick ?? false
    }
    
    var isPicchelin: Bool {
        storeDetail?.isPicchelin ?? false
    }
    
    var closeTime: String {
        storeDetail?.close ?? "--:--"
    }
    
    var pickCount: String {
        if let count = storeDetail?.pickCount {
            return "\(count)회"
        }
        return "0회"
    }
    
    var totalRating: String {
        if let totalRating = storeDetail?.totalRating {
            return String(format: "%.1f", totalRating)
        }
        return "0.0"
    }
    
    var totalReviewCount: String {
        if let count = storeDetail?.totalReviewCount {
            return "\(count)개"
        }
        return "0개"
    }
    
    var totalOrderCount: String {
        if let count = storeDetail?.totalOrderCount {
            return "\(count)회"
        }
        return "0회"
    }
    
    var hashTags: [String] {
        storeDetail?.hashTags ?? []
    }
    
    var storeImageUrls: [String] {
        storeDetail?.storeImageUrls ?? []
    }
    
    var ownerInfo: (String?, String?) {
        (storeDetail?.creator.nick, storeDetail?.creator.userID)
    }
}


