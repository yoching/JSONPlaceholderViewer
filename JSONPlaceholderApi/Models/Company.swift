//
//  Company.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct Company: Decodable, Equatable {
    public let name: String
    public let catchPhrase: String
    public let business: String

    enum CodingKeys: String, CodingKey {
        case name
        case catchPhrase
        case business = "bs"

    }
}
