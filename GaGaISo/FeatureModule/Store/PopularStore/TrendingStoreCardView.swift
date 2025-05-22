////
////  StoreCard.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////

import SwiftUI

struct TrendingStoreCard: View {
    var store: StoreDTO
    let onLikeTapped: (Bool) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: ExternalDatasource.pickup.baseURLString + "v1/\(store.storeImageUrls[0])")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 250, height: 200)
            .clipped()
            
            VStack {
                HStack {
                    Button(action: {
                        onLikeTapped(!store.isPick)
                    }) {
                        Image(systemName: store.isPick ? "heart.fill" : "heart")
                            .foregroundColor(store.isPick ? .red : .white)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    if store.isPicchelin {
                        Button(action: {
                            // 픽슐랭 액션
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .font(.caption2)
                                Text("픽슐랭")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blackSprout)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(8)
                    }
                }
                .frame(width: 250)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(store.name)
                        .foregroundStyle(.gray90)
                        .pretendardFont(size: .body3, weight: .bold)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.brightForsythia)
                            .pretendardFont(size: .body3, weight: .bold)
                        
                        Text("\(store.totalReviewCount)개")
                            .foregroundStyle(.gray90)
                            .pretendardFont(size: .body3, weight: .bold)
                    }
                }
                
                HStack(spacing: 12) {
                    Label("\(String(format: "%.1f", store.distance ?? "---"))km", systemImage: "location.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                    
                    Label(store.close, systemImage: "clock.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                    
                    Label("\(store.pickCount)회", systemImage: "person.fill")
                        .pretendardFont(size: .body3)
                        .foregroundStyle(.blackSprout)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                .gray0
            )
            .frame(width: 250)
        }
        .frame(width: 250, height: 200)
        .cornerRadius(12)
    }
}

#Preview {
    TrendingStoreCard(store: .init(
        storeID: "",
        category: "coffee",
        name: "냥냥냥",
        close: "19:00",
        storeImageUrls: [""],
        isPicchelin: true,
        isPick: true,
        pickCount: 1900,
        hashTags: ["오이시이", "슥고이"],
        totalRating: 2.9,
        totalOrderCount: 100,
        totalReviewCount: 100,
        geolocation: .init(longitude: 1343.342, latitude: 3423.343),
        distance: 129,
        createdAt: "2020-01-01T01:01:01Z",
        updatedAt: "2020-01-01T01:01:01Z"
    ), onLikeTapped: {_ in })
}
