//
//  DIContainer.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

class DIContainer: ObservableObject {
    
    let notificationManager: NotificationManager
    
    let authStore: AuthStore
    let authManager: AuthManagerProtocol
    
    let locationManager: LocationManager
    
    let networkClient: RawNetworkClient
    let networkManager: StrategicNetworkHandler
    
    let kakaoUserApi: KakaoUserApiProtocol
    
    let storeService: StoreService
    let storeContext: StoreContext
    
    let imageContext: ImageContext
    
    let orderContext: OrderContext
    
    let chatContext: ChatContext
    let chatService: ChatService
    
    let communityService: CommunityService
    let communityContext: CommunityContext
    
    init(
        authStore: AuthStore = AuthStore(),
        networkClient: RawNetworkClient = RawNetworkClient(),
        notificationManager: NotificationManager = NotificationManager(),
        locationManager: LocationManager = LocationManager(),
        kakaoUserApi: KakaoUserApiProtocol = KakaoUserApi()
    ) {
        self.authStore = authStore
        self.networkClient = networkClient
        self.notificationManager = notificationManager
        self.locationManager = locationManager
        self.kakaoUserApi = kakaoUserApi
        
        self.authManager = AuthenticationManager(
            authStore: authStore,
            networkClient: networkClient
        )
        
        self.networkManager = StrategicNetworkHandler(client: networkClient, authManager: authManager)
        self.storeService = StoreService(networkManager: networkManager)
        self.storeContext = StoreContext(storeService: storeService)
        self.imageContext = ImageContext(authManager: authManager)
        self.orderContext = OrderContext()
        
        self.chatService = ChatService(networkManager: networkManager)
        self.chatContext = ChatContext(chatService: chatService)
        
        self.communityService = CommunityService(networkManager: networkManager)
        self.communityContext = CommunityContext(communityService: communityService, locationManager: locationManager)
    }
    
    func getEntryViewModel() -> AppEntryViewModel {
        AppEntryViewModel(authManager: authManager)
    }
    
    func getLogInViewModel() -> LoginViewModel {
        LoginViewModel(authManager: authManager)
    }
    
    func getSignUpViewModel() -> SignUpViewModel {
        SignUpViewModel(authManager: authManager)
    }
    
    func getAppleSignInViewModel() -> AppleSignInViewModel {
        AppleSignInViewModel(authManager: authManager)
    }
    
    func getKaKaoSignInViewModel() -> KakaoSignInViewModel {
        KakaoSignInViewModel(
            authManager: authManager,
            kakaoUserApi: kakaoUserApi
        )
    }
    
    func getHomeViewModel() -> HomeViewModel {
        HomeViewModel(locationManager: locationManager, networkHandler: networkManager)
    }
    
    func getLocationViewModel() -> LocationRevealingViewModel {
        LocationRevealingViewModel(locationManager: locationManager)
    }
    
    func getPopularKeywordViewModel() -> PopularKeywordViewModel {
        PopularKeywordViewModel(storeService: storeService)
    }
    
    func getPoupularStoreViewModel() -> PopularStoreViewModel {
        PopularStoreViewModel(storeService: storeService, storeContext: storeContext)
    }
    
    func getTrendingStoreCardViewModel(storeId: String) -> TrendingStoreCardViewModel {
        TrendingStoreCardViewModel(storeId: storeId, storeContext: storeContext, imageContext: imageContext)
    }
    
    func getStoreListViewModel() -> StoreListViewModel {
        StoreListViewModel(locationManager: locationManager, storeService: storeService, storeContext: storeContext)
    }
    
    func getStoreItemViewModel(storeId: String) -> StoreItemViewModel {
        StoreItemViewModel(storeId: storeId, storeContext: storeContext, imageContext: imageContext)
    }
    
    func getStoreDetailViewModel(storeId: String) -> StoreDetailViewModel {
        StoreDetailViewModel(storeId: storeId, storeService: storeService, imageContext: imageContext, chatContext: chatContext, orderContext: orderContext)
    }
    
    func getMenuItemViewModel(menu: MenuList) -> MenuItemViewModel {
        MenuItemViewModel(menu: menu, imageContext: imageContext)
    }
    
    func getMenuDetailViewModel(menu: MenuList) -> MenuDetailViewModel {
        MenuDetailViewModel(menu: menu, imageContext: imageContext, orderContext: orderContext)
    }
    
    func getChatListViewModel() -> ChatListViewModel {
        ChatListViewModel(chatContext: chatContext)
    }
    
    func getChatRoomViewModel(roomId: String) -> ChatRoomViewModel {
        ChatRoomViewModel(roomId: roomId, chatContext: chatContext)
    }
    
    func getCommunityViewModel() -> CommunityViewModel {
        CommunityViewModel(communityContext: communityContext, chatContext: chatContext)
    }
    
    func getPostItemViewModel(postId: String) -> PostItemViewModel {
        PostItemViewModel(postId: postId, communityContext: communityContext, imageContext: imageContext, locationManager: locationManager)
    }
    
    func getOrderViewModel() -> OrderViewModel {
        OrderViewModel(orderContext: orderContext)
    }
}
