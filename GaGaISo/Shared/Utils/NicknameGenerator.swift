//
//  NicknameGenerator.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

struct NicknameGenerator {
    
    private static let adjectives = [
        "멋진", "귀여운", "용감한", "차분한", "활발한",
        "푸른", "붉은", "행복한", "신비한", "똑똑한"
    ]

    private static let nouns = [
        "여우", "호랑이", "돌고래", "달팽이", "다람쥐",
        "펭귄", "부엉이", "코끼리", "고양이", "강아지"
    ]
    
    static func generate() -> String {
        let adjective = adjectives.randomElement() ?? "행복한"
        let noun = nouns.randomElement() ?? "고양이"
        let number = generateUniqueNumber()
        return "\(adjective)\(noun)\(number)"
    }
    
    private static func generateUniqueNumber() -> Int {
        let now = Date().timeIntervalSince1970
        let hash = "\(now)".hashValue
        return abs(hash % 1000000)
    }
}
