//
//  ProfileView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("Profile")
                .font(.largeTitle)
        }
    }
}
