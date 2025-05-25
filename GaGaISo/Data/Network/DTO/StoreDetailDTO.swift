//
//  StoreDetailDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 5/25/25.
//

import Foundation

struct StoreDetailDTO: Decodable {
    let storeID, category, name, description: String
    let hashTags: [String]
    let welcomeOpen, close, address: String
    let estimatedPickupTime: Int
    let parkingGuide: String
    let storeImageUrls: [String]
    let isPicchelin: Bool
    var isPick: Bool
    let pickCount, totalReviewCount, totalOrderCount: Int
    let totalRating: Double
    let creator: Creator
    let geolocation: Geolocation
    let menuList: [MenuList]
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case storeID = "store_id"
        case category, name, description, hashTags
        case welcomeOpen = "open"
        case close, address
        case estimatedPickupTime = "estimated_pickup_time"
        case parkingGuide = "parking_guide"
        case storeImageUrls = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case totalReviewCount = "total_review_count"
        case totalOrderCount = "total_order_count"
        case totalRating = "total_rating"
        case creator, geolocation
        case menuList = "menu_list"
        case createdAt, updatedAt
    }
}

struct Creator: Codable {
    let userID, nick: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
    }
}

struct MenuList: Decodable {
    let menuID, storeID, category, name: String
    let description, originInformation: String
    let price: Int
    let isSoldOut: Bool
    let tags: [String]
    let menuImageURL, createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case menuID = "menu_id"
        case storeID = "store_id"
        case category, name, description
        case originInformation = "origin_information"
        case price
        case isSoldOut = "is_sold_out"
        case tags
        case menuImageURL = "menu_image_url"
        case createdAt, updatedAt
    }
}


extension StoreDetailDTO {
    static var mockData: StoreDetailDTO {
        StoreDetailDTO(
            storeID: "store_001",
            category: "디저트",
            name: "새싹 도넛 가게",
            description: "신선하고 맛있는 수제 도넛을 판매하는 가게입니다.",
            hashTags: ["#도넛", "#디저트", "#수제", "#신선함"],
            welcomeOpen: "10:00 AM",
            close: "7:00 PM",
            address: "서울 영등포구 선유로 30 106호",
            estimatedPickupTime: 15,
            parkingGuide: "매장 앞 평일 주차 가능",
            storeImageUrls: [
                "https://example.com/store1.jpg",
                "https://example.com/store2.jpg",
                "https://example.com/store3.jpg"
            ],
            isPicchelin: true,
            isPick: false,
            pickCount: 202,
            totalReviewCount: 211,
            totalOrderCount: 156,
            totalRating: 4.8,
            creator: Creator.mockData,
            geolocation: Geolocation.mockData,
            menuList: MenuList.mockDataList,
            createdAt: "2024-05-21T10:00:00Z",
            updatedAt: "2024-05-25T15:30:00Z"
        )
    }
}

extension Creator {
    static var mockData: Creator {
        Creator(
            userID: "user_001",
            nick: "도넛마스터"
        )
    }
}

extension Geolocation {
    static var mockData: Geolocation {
        Geolocation(
            longitude: 126.9780,
            latitude: 37.5665
        )
    }
}

extension MenuList {
    static var mockDataList: [MenuList] {
        [
            MenuList(
                menuID: "menu_001",
                storeID: "store_001",
                category: "인기메뉴",
                name: "올리브 그린 새싹 도넛",
                description: "부드러운 매실과고 촉촉하며, 올 올리브와 새싹의 풍미가 입안 가득 퍼집니다.",
                originInformation: "국산 밀가루, 유기농 올리브",
                price: 3200,
                isSoldOut: false,
                tags: ["베스트", "시그니처"],
                menuImageURL: "https://example.com/menu1.jpg",
                createdAt: "2024-05-21T10:00:00Z",
                updatedAt: "2024-05-25T15:30:00Z"
            ),
            MenuList(
                menuID: "menu_002",
                storeID: "store_001",
                category: "인기메뉴",
                name: "올리브 휘스티 도넛",
                description: "올리브 오일과 휘핑크림이 만나 부드럽고 고소한 맛이 일품인 도넛입니다.",
                originInformation: "이탈리아산 올리브오일, 프랑스산 버터",
                price: 3700,
                isSoldOut: true,
                tags: ["프리미엄", "품절"],
                menuImageURL: "https://example.com/menu2.jpg",
                createdAt: "2024-05-21T10:00:00Z",
                updatedAt: "2024-05-25T15:30:00Z"
            ),
            MenuList(
                menuID: "menu_003",
                storeID: "store_001",
                category: "인기메뉴",
                name: "레몬 민트 새싹 도넛",
                description: "상큼한 레몬과 새콤한 민트가 조화를 이루는 시원한 도넛입니다.",
                originInformation: "국산 레몬, 유기농 민트",
                price: 3600,
                isSoldOut: false,
                tags: ["시원함", "상큼함"],
                menuImageURL: "https://example.com/menu3.jpg",
                createdAt: "2024-05-21T10:00:00Z",
                updatedAt: "2024-05-25T15:30:00Z"
            ),
            MenuList(
                menuID: "menu_004",
                storeID: "store_001",
                category: "음료",
                name: "팥빙 새싹 도넛",
                description: "전통 팥빙수를 모티브로 한 여름 한정 메뉴입니다.",
                originInformation: "국산 팥, 유기농 우유",
                price: 21000,
                isSoldOut: false,
                tags: ["한정판", "여름메뉴"],
                menuImageURL: "https://example.com/menu4.jpg",
                createdAt: "2024-05-21T10:00:00Z",
                updatedAt: "2024-05-25T15:30:00Z"
            )
        ]
    }
}
