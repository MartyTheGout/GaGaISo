//
//  EntryView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import SwiftUI
import ComposableArchitecture

struct AppEntryView: View {
    let store: StoreOf<AppFeature>
    
    @Dependency(\.authManager) private var authManagerDependency
        @ObservedObject private var authManager: AuthenticationManager
        
        init(store: StoreOf<AppFeature>) {
            self.store = store
        
            let manager = AuthManagerKey.liveValue
            self._authManager = ObservedObject(wrappedValue: manager as! AuthenticationManager)
        }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.isBootstrapping {
                    ProgressView("로그인 상태 확인 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    NavigationStack {
                        ContentView(
                            store: store.scope(
                                state: \.content,
                                action: \.content
                            )
                        )
                        .fullScreenCover(isPresented:
                                            Binding(
                                                get: { !self.authManager.isLoggedIn },
                                                set: { _ in }
                                            )
                        ) {
                            NavigationStack {
                                LoginView(
                                    store: store.scope(
                                        state: \.login,
                                        action: \.login
                                    )
                                )
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
