//
//  RouterProtocol.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

protocol RouterProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var parameter: [URLQueryItem] { get }
    var urlRequest: URLRequest { get }
}
