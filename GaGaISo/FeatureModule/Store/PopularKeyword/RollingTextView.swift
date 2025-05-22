//
//  RollingTextView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import SwiftUI

struct RollingTextView: View {
    let items: [String]
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(currentIndex + 1)")
                .pretendardFont(size: .caption1, weight: .semibold)
                .foregroundStyle(.blackSprout)
                .animation(.easeInOut(duration: 0.5), value: currentIndex)
            
            ZStack {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .pretendardFont(size: .caption1, weight: .semibold)
                        .foregroundStyle(.blackSprout)
                        .offset(y: offsetForIndex(index))
                        .opacity(index == currentIndex ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: currentIndex)
                }
            }
            .clipped()
        }
    }
    
    private func offsetForIndex(_ index: Int) -> CGFloat {
        if index == currentIndex {
            return 0
        } else if index == (currentIndex + 1) % items.count {
            return 30
        } else if index == (currentIndex - 1 + items.count) % items.count {
            return -30
        } else {
            return 30
        }
    }
}

