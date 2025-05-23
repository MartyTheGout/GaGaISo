//
//  LikeStatusDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 5/23/25.
//

import Foundation


struct LikeStatusDTO: Decodable {
    let likeStatus : Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}

