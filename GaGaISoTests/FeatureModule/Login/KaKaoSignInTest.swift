//
//  KaKaoSignInTest.swift
//  GaGaISoTests
//
//  Created by marty.academy on 5/19/25.
//

import Foundation
import XCTest
import ComposableArchitecture
@testable import GaGaISo

final class KakaoSignInFeatureTests: XCTestCase {
    
    func testKakaoTalkLoginSuccess() async {
        let mockAuthManager = MockAuthManager()
        mockAuthManager.kakaoLoginResult = .success(())
        
        var mockKakaoApi = MockKakaoUserApi()
        mockKakaoApi.isKakaoTalkLoginAvailableResult = true
        mockKakaoApi.loginWithKakaoTalkResult = (OAuthToken(accessToken: "test-access-token"), nil)
        
        let store = await TestStore(
            initialState: KakaoSignInFeature.State()
        ) {
            KakaoSignInFeature()
        } withDependencies: { dependencies in
            dependencies.authManager = mockAuthManager
            dependencies.kakaoUserApi = mockKakaoApi
        }
        
        await store.send(.kakaoLoginTapped) { state in
            state.isLoading = true
            state.errorMessage = nil
        }
        
        await store.receive(.kakaoLoginSuccess("test-access-token"))
        
        await store.receive(.loginProcessed) { state in
            state.isLoading = false
        }
        
        await store.finish()
    
        XCTAssertTrue(mockAuthManager.kakaoLoginCalled)
    }
    
    func testKakaoAccountLoginSuccess() async {
        let mockAuthManager = MockAuthManager()
        mockAuthManager.kakaoLoginResult = .success(())
        
        var mockKakaoApi = MockKakaoUserApi()
        mockKakaoApi.isKakaoTalkLoginAvailableResult = false  // 카카오톡 앱 미설치
        mockKakaoApi.loginWithKakaoAccountResult = (OAuthToken(accessToken: "test-account-token"), nil)
        
        let store = await TestStore(
            initialState: KakaoSignInFeature.State()
        ) {
            KakaoSignInFeature()
        } withDependencies: { dependencies in
            dependencies.authManager = mockAuthManager
            dependencies.kakaoUserApi = mockKakaoApi
        }
        
        await store.send(.kakaoLoginTapped) { state in
            state.isLoading = true
            state.errorMessage = nil
        }
        
        await store.receive(.kakaoLoginSuccess("test-account-token"))
        
        await store.receive(.loginProcessed) { state in
            state.isLoading = false
        }
        
        await store.finish()
    }
    
    func testKakaoTalkLoginFailure() async {
        let mockAuthManager = MockAuthManager()
        
        var mockKakaoApi = MockKakaoUserApi()
        mockKakaoApi.isKakaoTalkLoginAvailableResult = true
        let testError = NSError(domain: "KakaoSDK", code: 123, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인을 취소했습니다."])
        mockKakaoApi.loginWithKakaoTalkResult = (nil, testError)
        
        let store = await TestStore(
            initialState: KakaoSignInFeature.State()
        ) {
            KakaoSignInFeature()
        } withDependencies: { dependencies in
            dependencies.authManager = mockAuthManager
            dependencies.kakaoUserApi = mockKakaoApi
        }
        
        await store.send(.kakaoLoginTapped) { state in
            state.isLoading = true
            state.errorMessage = nil
        }
        
        await store.receive(.kakaoLoginFailure("사용자가 로그인을 취소했습니다.")) { state in
            state.isLoading = false
            state.errorMessage = "사용자가 로그인을 취소했습니다."
        }
        
        await store.finish()
        
        XCTAssertFalse(mockAuthManager.kakaoLoginCalled)
    }
    
    func testServerLoginFailure() async {
        let serverError = NSError(domain: "ServerAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "인증 실패"])
        
        let mockAuthManager = MockAuthManager()
        mockAuthManager.kakaoLoginResult = .failure(serverError)
        
        var mockKakaoApi = MockKakaoUserApi()
        mockKakaoApi.isKakaoTalkLoginAvailableResult = true
        mockKakaoApi.loginWithKakaoTalkResult = (OAuthToken(accessToken: "test-access-token"), nil)
        
        let store = await TestStore(
            initialState: KakaoSignInFeature.State()
        ) {
            KakaoSignInFeature()
        } withDependencies: { dependencies in
            dependencies.authManager = mockAuthManager
            dependencies.kakaoUserApi = mockKakaoApi
        }
        
        await store.send(.kakaoLoginTapped) { state in
            state.isLoading = true
            state.errorMessage = nil
        }
        
        await store.receive(.kakaoLoginSuccess("test-access-token"))
        
        await store.receive(.loginFailed("인증 실패")) { state in
            state.isLoading = false
            state.errorMessage = "인증 실패"
        }
        
        await store.finish()
        
        XCTAssertTrue(mockAuthManager.kakaoLoginCalled)
    }
}
