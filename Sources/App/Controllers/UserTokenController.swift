//
//  UserTokenController.swift
//  
//
//  Created by Travis Brigman on 3/25/21.
//

import Vapor
import Fluent

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user

    var isValid: Bool {
        true
    }
}
