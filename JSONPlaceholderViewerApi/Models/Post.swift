//
//  Post.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

struct Post: Decodable {
    let identifier: Int
    let userIdentifier: Int
    let title: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userIdentifier = "userId"
        case title
        case body
    }
}
