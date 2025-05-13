//
//  : Data:Protocol:TokenStore.swift  protocol TokenStore {     var accessToken- String? { get set }     var refreshToken- String? { get set }     func clear() } .swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/12/25.
//

import Foundation

protocol TokenStore {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    func clear()
}
