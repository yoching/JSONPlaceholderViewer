//
//  User.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct User: Decodable {
    public let identifier: Int
    public let name: String
    public let userName: String
    public let email: String
    public let address: Address
    public let phone: String
    public let website: String
    public let company: Company

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case userName = "username"
        case email
        case address
        case phone
        case website
        case company
    }
}
