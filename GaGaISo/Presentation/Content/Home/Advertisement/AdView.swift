//
//  AdView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/23/25.
//

import SwiftUI

struct AdView: View {
    var imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: ExternalDatasource.pickup.baseURLString + "v1/\(imageURL)")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
    }
}
