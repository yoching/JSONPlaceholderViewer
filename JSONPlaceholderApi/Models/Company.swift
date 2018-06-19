//
//  Company.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

struct Company: Decodable, Equatable {
    let name: String
    let catchPhrase: String
    let business: String

    enum CodingKeys: String, CodingKey {
        case name
        case catchPhrase
        case business = "bs"

    }
}
