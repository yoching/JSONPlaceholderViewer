//
//  GeoLocation.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public struct GeoLocation: Decodable, Equatable {
    let lat: String
    let lng: String
}
