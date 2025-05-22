//
//  DIContainer.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

class DIContainer: ObservableObject {
    let authStore: AuthStore
    let networkClient: RawNetworkClient
    let authManager: AuthManagerProtocol
    let notificationManager: NotificationManager
    let locationManager: LocationManager
    let kakaoUserApi: KakaoUserApiProtocol
    let networkManager: StrategicNetworkHandler
    let storeManager: StoreManager
    
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
        self.storeManager = StoreManager(networkManager: networkManager)
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
        PopularKeywordViewModel(storeManager: storeManager)
    }
    
    func getPoupularStoreViewModel() -> PopularStoreViewModel {
        PopularStoreViewModel(storeManager: storeManager)
    }
}
