//
//  PostsRequest.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public struct PostsRequest: JSONPlaceholderRequest {

    public typealias Response = [Post]

    public let method: HTTPMethod = .get
    public let path: String = "/posts"

    public init() {

    }
}
