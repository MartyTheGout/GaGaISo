//
//  OrderItemRowView.swift
//  GaGaISo
//
//  Created by marty.academy on 6/7/25.
//

import SwiftUI

struct OrderItemRowView: View {
    let item: OrderItem
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.menuName)
                    .pretendardFont(size: .body2, weight: .medium)
                    .foregroundColor(.gray90)
                
                Text("\(item.menuPrice)원")
                    .pretendardFont(size: .body3)
                    .foregroundColor(.gray60)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onDecrease) {
                    Image(systemName: item.quantity > 1 ? "minus" : "trash")
                        .foregroundColor(item.quantity > 1 ? .gray60 : .red)
                        .frame(width: 20, height: 20)
                }
                
                Text("\(item.quantity)")
                    .pretendardFont(size: .body2, weight: .bold)
                    .frame(minWidth: 30, alignment: .center)
                
                Button(action: onIncrease) {
                    Image(systemName: "plus")
                        .foregroundColor(.blackSprout)
                        .frame(width: 20, height: 20)
                }
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.totalPrice)원")
                    .pretendardFont(size: .body2, weight: .bold)
                    .foregroundColor(.gray90)
                
                Button(action: onRemove) {
                    Text("삭제")
                        .pretendardFont(size: .caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
