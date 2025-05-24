//
//  Extension+Array.swift
//  GaGaISo
//
//  Created by marty.academy on 5/24/25.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
