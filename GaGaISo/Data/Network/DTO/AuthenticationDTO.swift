//
//  NetworkResponse.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import Foundation


struct LoginResponseDTO: Decodable {
    var user_id : String
    var email : String
    var nick : String
    var profileImage: String?
    var accessToken: String
    var refreshToken: String
}

struct TokenRefresheResponseDTO: Decodable {
    let accessToken : String
    let refreshToken : String
}
