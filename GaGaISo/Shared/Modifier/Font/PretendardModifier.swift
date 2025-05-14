//
//  PretendardModifier.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import SwiftUI

enum PretendardFontStyle: CGFloat {
    case title1 = 20
    case body1 = 16
    case body2 = 14
    case body3 = 13
    case caption1 = 12
    case caption2 = 10
    case caption3 = 8
}

struct PretendardFont: ViewModifier {
    var size: PretendardFontStyle
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        content.font(.custom(weight == .bold ? "Pretendard-Bold": "Pretendard-Regular", size: size.rawValue))
    }
}

extension View {
    func pretendardFont(size: PretendardFontStyle, weight: Font.Weight = .regular) -> some View {
        modifier(PretendardFont(size: size, weight: weight))
    }
}
