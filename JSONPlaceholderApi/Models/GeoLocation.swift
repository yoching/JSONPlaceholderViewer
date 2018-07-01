//
//  GeoLocation.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct GeoLocation: Decodable, Equatable {
    public let lat: String
    public let lng: String

    public init(
        lat: String,
        lng: String
        ) {
        self.lat = lat
        self.lng = lng
    }
}
