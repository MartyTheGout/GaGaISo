////
////  StoreCard.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//struct StoreCard: View {
//    let store: StoreOf<StoreItemFeature>
//    
//    var body: some View {
//        WithViewStore(store, observe: { $0 }) { viewStore in
//            VStack(alignment: .leading) {
//                HStack(spacing: 12) {
//                    ZStack(alignment: .topLeading) {
//                        Image(viewStore.imageName)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 200, height: 150)
//                            .cornerRadius(12)
//                        
//                        Button(action: {
//                            viewStore.send(.favoriteButtonTapped)
//                        }) {
//                            Image(systemName: viewStore.isFavorite ? "heart.fill" : "heart")
//                                .foregroundColor(viewStore.isFavorite ? .red : .white)
//                                .padding(8)
//                                .padding(8)
//                        }
//                        
//                        VStack {
//                            HStack {
//                                Spacer()
//                                Button(action: {
//                                    
//                                }) {
//                                    HStack {
//                                        Image(systemName: "paperplane.fill")
//                                        Text("픽슐랭")
//                                            .font(.caption)
//                                    }
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.green.opacity(0.8))
//                                    .foregroundColor(.white)
//                                    .cornerRadius(12)
//                                }
//                                .padding(8)
//                            }
//                            .frame(width: 200)
//                        }
//                    }
//                    
//                    VStack(spacing: 8) {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.2))
//                            .frame(width: 80, height: 70)
//                            .cornerRadius(8)
//                        
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.2))
//                            .frame(width: 80, height: 70)
//                            .cornerRadius(8)
//                    }
//                }
//                
//                HStack {
//                    Text(viewStore.name)
//                        .foregroundStyle(.gray90)
//                        .pretendardFont(size: .body1, weight: .bold)
//                    
//                    HStack(spacing: 4) {
//                        Image(systemName: "heart.fill")
//                            .foregroundColor(.brightForsythia)
//                            .pretendardFont(size: .body1, weight: .bold)
//                        
//                        Text("\(viewStore.likes)개")
//                            .foregroundStyle(.gray90)
//                            .pretendardFont(size: .body1, weight: .bold)
//                            
//                    }
//                    
//                    HStack(spacing: 2) {
//                        Image(systemName: "star.fill")
//                            .foregroundColor(.brightForsythia)
//                            .pretendardFont(size: .body1, weight: .bold)
//                        
//                        Text(String(format: "%.1f", viewStore.rating))
//                            .pretendardFont(size: .body1, weight: .bold)
//                            .foregroundStyle(.gray90)
//                        
//                        Text("(\(viewStore.reviewCount))")
//                            .pretendardFont(size: .body1)
//                            .foregroundStyle(.gray60)
//                    }
//                }
//                .padding(.vertical, 4)
//                
//                HStack(spacing: 12) {
//                    Label("\(String(format: "%.1f", viewStore.distance))km", systemImage: "location.fill")
//                        .pretendardFont(size: .body2)
//                        .foregroundStyle(.blackSprout)
//                    
//                    Label(viewStore.closeTime, systemImage: "clock.fill")
//                        .pretendardFont(size: .body2)
//                        .foregroundStyle(.blackSprout)
//                    
//                    Label("\(viewStore.visitCount)회", systemImage: "person.fill")
//                        .pretendardFont(size: .body2)
//                        .foregroundStyle(.blackSprout)
//                }
//                
//                HStack {
//                    ForEach(viewStore.tags, id: \.self) { tag in
//                        Text(tag)
//                            .pretendardFont(size: .caption1, weight: .bold)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(.deepSprout)
//                            .cornerRadius(5)
//                            .foregroundColor(.gray0)
//                    }
//                }
//            }
//            .padding(.vertical, 12)
//            .background(.gray0)
//            .cornerRadius(12)
//        }
//    }
//}
//
//#Preview {
//    StoreCard(
//        store: Store(
//            initialState: StoreItemFeature.State(
//                id: UUID(),
//                name: "새싹 마카롱 영등포직영점",
//                imageName: "desert",
//                rating: 4.9,
//                reviewCount: 145,
//                likes: 155,
//                distance: 1.3,
//                closeTime: "7PM",
//                visitCount: 288,
//                tags: ["#동카롱", "#티라미수"],
//                isFavorite: false
//            ),
//            reducer: {
//                StoreItemFeature()
//            }
//        )
//    )
//    .padding()
//}
