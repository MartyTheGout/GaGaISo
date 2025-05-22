//
//  SearchBarView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                    .foregroundColor(.gray60)
                
                TextField("검색어를 입력해주세요", text: $searchText)
                    .pretendardFont(size: .body2, weight: .regular)
                    .foregroundColor(.gray60)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray0)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SearchBarView()
}
