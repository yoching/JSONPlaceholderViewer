//
//  UserRequest.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

struct UserRequest: JSONPlaceholderRequest {

    typealias Response = User

    let method: HTTPMethod = .get

    let path: String

    init(userIdentifier: Int) {
        path = "/users/\(userIdentifier)"
    }
}
