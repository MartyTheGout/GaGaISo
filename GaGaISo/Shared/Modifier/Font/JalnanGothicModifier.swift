//
//  JalnanGothicModifier.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import SwiftUI

enum JalnanFontStyle: CGFloat {
    case title1 = 24
    case body1 = 20
    case caption1 = 14
}

struct JalnanFont: ViewModifier {
    var size: JalnanFontStyle
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        content.font(.custom("JalnanGothic", size: size.rawValue))
    }
}

extension View {
    func jalnanFont(size: JalnanFontStyle, weight: Font.Weight = .regular) -> some View {
        modifier(JalnanFont(size: size, weight: weight))
    }
}
