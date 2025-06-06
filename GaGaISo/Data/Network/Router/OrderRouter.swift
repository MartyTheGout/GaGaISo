//
//  OrderRouter.swift
//  GaGaISo
//
//  Created by marty.academy on 6/6/25.
//

import Foundation

//Server-side Referecne:
//PENDING_APPROVAL(승인대기, 결제 영수증 검증 완료 시 기본값), APPROVED(주문승인), IN_PROGRESS(조리 중), READY_FOR_PICKUP(픽업대기), PICKED_UP(픽업완료)
enum OrderStatus: String {
    case pendingApproval = "PENDING_APPROVAL"
    case approved = "APPROVED"
    case inProgress = "IN_PROGRESS"
    case readyForPickup = "READY_FOR_PICKUP"
    case pickedUp = "PICKED_UP"
}

enum OrderRouter: RouterProtocol {
    case v1GetOrder(resourcePath: String)
    case v1PostOrder(orderDetail: PostOrderRequestDTO)
    case v1PutOrderStatus(orderCode: String, status: OrderStatus)
    case v1PostPayment(importId: String)
    case v1GetPayment(orderCode: String)

    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1GetOrder : return "v1/orders"
        case .v1PostOrder : return "v1/orders"
        case .v1PutOrderStatus(let orderCode, _): return "v1/orders/\(orderCode)"
        case .v1GetPayment(let orderCode): return "v1/payments/\(orderCode)"
        case .v1PostPayment: return "v1/payments"
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        default: return []
        }
    }
    
    var body: Data? {
        switch self {
        case .v1PostOrder(let orderDetail) :
            return try! JSONEncoder().encode(orderDetail)
        case .v1PutOrderStatus(_, let status):
            let dict = ["nextStatus": status.rawValue]
            return try! JSONSerialization.data(withJSONObject: dict)
        case .v1PostPayment(let importId):
            let dict = ["imp_uid": importId]
            return try! JSONSerialization.data(withJSONObject: dict)
        default: return nil
        }
    }
    
    var method: String {
        switch self {
        case .v1PostPayment: return "POST"
        case .v1PostOrder: return "POST"
        case .v1PutOrderStatus: return "PUT"
        default: return "GET"
        }
    }
}
