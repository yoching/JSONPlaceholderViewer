//
//  Address.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct Address: Decodable, Equatable {
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    public let geo: GeoLocation

    public init(
        street: String,
        suite: String,
        city: String,
        zipcode: String,
        geo: GeoLocation
        ) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zipcode = zipcode
        self.geo = geo
    }
}
