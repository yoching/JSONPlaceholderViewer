//
//  Post.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct Post: Decodable {
    public let identifier: Int
    public let userIdentifier: Int
    public let title: String
    public let body: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userIdentifier = "userId"
        case title
        case body
    }
}
