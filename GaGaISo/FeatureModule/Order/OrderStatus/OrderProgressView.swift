//
//  OrderProgressView.swift
//  GaGaISo
//
//  Created by marty.academy on 6/9/25.
//

import SwiftUI

struct OrderProgressView: View {
    let currentStatus: String
    let timeline: [OrderStatusTimeline]
    
    private let statusOrder = [
        "PENDING_APPROVAL",
        "APPROVED",
        "IN_PROGRESS",
        "READY_FOR_PICKUP",
        "PICKED_UP"
    ]
    
    private let statusNames = [
        "PENDING_APPROVAL": "승인대기",
        "APPROVED": "주문승인",
        "IN_PROGRESS": "조리중",
        "READY_FOR_PICKUP": "픽업대기",
        "PICKED_UP": "픽업완료"
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(Array(statusOrder.enumerated()), id: \.offset) { index, status in
                    statusStepView(
                        status: status,
                        isCompleted: isStatusCompleted(status),
                        isCurrent: status == currentStatus,
                        isLast: index == statusOrder.count - 1
                    )
                    
                    if index < statusOrder.count - 1 {
                        connectionLine(isCompleted: isStatusCompleted(statusOrder[index + 1]))
                    }
                }
            }
            
            if let currentTimeline = timeline.first(where: { $0.status == currentStatus }) {
                Text("업데이트: \(formatTime(currentTimeline.changedAt ?? ""))")
                    .pretendardFont(size: .caption2)
                    .foregroundColor(.gray60)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Status Step View
    private func statusStepView(status: String, isCompleted: Bool, isCurrent: Bool, isLast: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(circleColor(isCompleted: isCompleted, isCurrent: isCurrent))
                    .frame(width: 20, height: 20)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else if isCurrent {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(statusNames[status] ?? status)
                .pretendardFont(size: .caption2, weight: isCurrent ? .bold : .regular)
                .foregroundColor(textColor(isCompleted: isCompleted, isCurrent: isCurrent))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Connection Line
    private func connectionLine(isCompleted: Bool) -> some View {
        Rectangle()
            .fill(isCompleted ? Color.brightForsythia : Color.gray30)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    private func isStatusCompleted(_ status: String) -> Bool {
        guard let currentIndex = statusOrder.firstIndex(of: currentStatus),
              let statusIndex = statusOrder.firstIndex(of: status) else {
            return false
        }
        return statusIndex <= currentIndex
    }
    
    private func circleColor(isCompleted: Bool, isCurrent: Bool) -> Color {
        if isCompleted {
            return .brightForsythia
        } else if isCurrent {
            return .blackSprout
        } else {
            return .gray30
        }
    }
    
    private func textColor(isCompleted: Bool, isCurrent: Bool) -> Color {
        if isCompleted || isCurrent {
            return .gray90
        } else {
            return .gray60
        }
    }
    
    private func formatTime(_ timeString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }
}
