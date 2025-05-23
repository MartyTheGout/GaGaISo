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
    let storeStateManager: StoreStateManager
    
    let imageService: ImageService
    
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
        self.storeStateManager = StoreStateManager(storeService: storeService)
        self.imageService = ImageService(authManager: authManager, networkManager: networkManager)
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
        PopularStoreViewModel(storeService: storeService, storeStateManager: storeStateManager)
    }
    
    func getTrendingStoreCardViewModel(storeId: String) -> TrendingStoreCardViewModel {
        TrendingStoreCardViewModel(storeId: storeId, storeStateManager: storeStateManager, imageService: imageService)
    }
}
