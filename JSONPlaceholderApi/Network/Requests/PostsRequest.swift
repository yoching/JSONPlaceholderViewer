//
//  PostsRequest.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

struct PostsRequest: JSONPlaceholderRequest {

    typealias Response = [Post]

    let method: HTTPMethod = .get
    let path: String = "/posts"
}
