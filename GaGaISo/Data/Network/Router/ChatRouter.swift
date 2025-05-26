//
//  Router.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum ChatRouter: RouterProtocol {
    case v1CreateChat(opponent: String)
    case v1ListChat
    case v1SendMessage(roomId: String, message: String, fileURL: [String]?)
    case v1GetChatRecord(roomId: String, since: String)
    case v1UploadFilesOnChat(roomId: String, file: Array<String> )
    
    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1CreateChat: return "v1/chats"
        case .v1ListChat: return "v1/chats"
        case .v1SendMessage(let roomId, _, _) : return "v1/chats/\(roomId)"
        case .v1GetChatRecord(let roomId, _): return "v1/chats/\(roomId)"
        case .v1UploadFilesOnChat(let roomId, _): return "v1/chats/\(roomId)/files"
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        case .v1GetChatRecord(let roomId, let since):
            return [
                .init(name: "room_id", value: roomId),
                .init(name: "next", value: since)
            ]
        default: return []
        }
    }
    
    var body: Data? {
        switch self {
        case .v1CreateChat(let opponent):
            let dict = [
                "opponent_id": opponent
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .v1ListChat:
            return nil
            
        case .v1SendMessage(_, let message, let fileURL):
            let dict = [
                "content": message,
                "files": [
                    fileURL
                ]
            ] as [String : Any]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .v1UploadFilesOnChat(_, let file):
            let dict = [
                "files": file,
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        default : return nil
        }
    }
    
    var method: String {
        switch self {
        case .v1CreateChat: return "POST"
        case .v1ListChat: return "GET"
        case .v1SendMessage: return "POST"
        case .v1GetChatRecord: return "GET"
        case .v1UploadFilesOnChat: return "POST"
        }
    }
}

