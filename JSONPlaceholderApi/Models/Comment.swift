//
//  Comment.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct Comment: Decodable {
    public let postIdentifier: Int
    public let identifier: Int
    public let name: String
    public let email: String
    public let body: String

    enum CodingKeys: String, CodingKey {
        case postIdentifier = "postId"
        case identifier = "id"
        case name
        case email
        case body
    }

    public init(
        postIdentifier: Int,
        identifier: Int,
        name: String,
        email: String,
        body: String
        ) {
        self.postIdentifier = postIdentifier
        self.identifier = identifier
        self.name = name
        self.email = email
        self.body = body
    }
}
