//
//  PopularSearchView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import SwiftUI
import Combine

struct PopularKeywordView: View {
    // State for Logic / Data Layer
    @StateObject private var viewModel: PopularKeywordViewModel
    
    // State for View Layer
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    init(viewModel: PopularKeywordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.deepSprout)
                    .pretendardFont(size: .caption1, weight: .semibold)
                
                Text("인기검색어")
                    .pretendardFont(size: .caption1, weight: .semibold)
                    .foregroundColor(.deepSprout)
            }
            
            if !viewModel.searchKeywords.isEmpty {
                RollingTextView(
                    items: viewModel.searchKeywords,
                    currentIndex: $currentIndex
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .task {
            await viewModel.loadPopularSearches()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: viewModel.searchKeywords, initial: false, { oldValue, newValue in
            stopTimer()
            currentIndex = 0
            startTimer()
        })
    }
    
    private func startTimer() {
        guard !viewModel.searchKeywords.isEmpty else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % viewModel.searchKeywords.count
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
