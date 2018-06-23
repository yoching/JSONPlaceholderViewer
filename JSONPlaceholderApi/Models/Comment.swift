//
//  Comment.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct Comment: Decodable {
    let postIdentifier: Int
    let identifier: Int
    let name: String
    let email: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case postIdentifier = "postId"
        case identifier = "id"
        case name
        case email
        case body
    }
}
