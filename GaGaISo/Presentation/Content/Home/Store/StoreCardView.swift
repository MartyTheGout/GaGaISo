////
////  StoreCard.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////
import SwiftUI

struct StoreCard: View {
    var store : StoreDTO
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: ExternalDatasource.pickup.baseURLString + "v1/\(store.storeImageUrls[0])")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 200, height: 150)
                    .cornerRadius(12)
                    
                    Button(action: {
                        print("action")
                    }) {
                        Image(systemName: "heart")
                            .foregroundColor( .white)
                            .padding(8)
                            .padding(8)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // 픽슐랭 액션
                            }) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("픽슐랭")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blackSprout)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(8)
                        }
                        .frame(width: 200)
                    }
                }
                
                VStack(spacing: 8) {
                    AsyncImage(url: URL(string: ExternalDatasource.pickup.baseURLString + "v1/\(store.storeImageUrls[0])")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    
                    .frame(width: 80, height: 70)
                    .cornerRadius(8)
                    AsyncImage(url: URL(string: ExternalDatasource.pickup.baseURLString + "v1/\(store.storeImageUrls[0])")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    
                    .frame(width: 80, height: 70)
                    .cornerRadius(8)
                }
            }
            
            HStack {
                Text(store.name)
                    .foregroundStyle(.gray90)
                    .pretendardFont(size: .body1, weight: .bold)
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.brightForsythia)
                        .pretendardFont(size: .body1, weight: .bold)
                    
                    Text("\(store.totalReviewCount)개")
                        .foregroundStyle(.gray90)
                        .pretendardFont(size: .body1, weight: .bold)
                    
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.brightForsythia)
                        .pretendardFont(size: .body1, weight: .bold)
                    
                    Text(String(format: "%.1f", store.totalRating))
                        .pretendardFont(size: .body1, weight: .bold)
                        .foregroundStyle(.gray90)
                    
                    Text("(\(store.pickCount))")
                        .pretendardFont(size: .body1)
                        .foregroundStyle(.gray60)
                }
            }
            .padding(.vertical, 4)
            
            HStack(spacing: 12) {
                Label("\(String(format: "%.1f", store.distance ?? "---"))km", systemImage: "location.fill")
                    .pretendardFont(size: .body2)
                    .foregroundStyle(.blackSprout)
                
                Label(store.close, systemImage: "clock.fill")
                    .pretendardFont(size: .body2)
                    .foregroundStyle(.blackSprout)
                
                Label("\(store.pickCount)회", systemImage: "person.fill")
                    .pretendardFont(size: .body2)
                    .foregroundStyle(.blackSprout)
            }
            
            HStack {
                ForEach(store.hashTags, id: \.self) { tag in
                    Text(tag)
                        .pretendardFont(size: .caption1, weight: .bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.deepSprout)
                        .cornerRadius(5)
                        .foregroundColor(.gray0)
                }
            }
        }
        .padding(.vertical, 12)
        .background(.gray0)
        .cornerRadius(12)
    }
}
