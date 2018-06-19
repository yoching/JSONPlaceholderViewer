//
//  Address.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

struct Address: Decodable, Equatable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: GeoLocation
}
