//
//  UserRequest.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public struct UserRequest: JSONPlaceholderRequest {

    public typealias Response = User

    public let method: HTTPMethod = .get
    public let path: String

    public init(userIdentifier: Int) {
        path = "/users/\(userIdentifier)"
    }
}
