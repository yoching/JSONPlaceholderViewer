//
//  CommentsRequest.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public struct CommentsRequest: JSONPlaceholderRequest {

    public typealias Response = [Comment]

    public let method: HTTPMethod = .get
    public let path: String = "/comments"
    public let parameters: Any?

    public init(postIdentifier: Int) {
        parameters = ["postId": postIdentifier]
    }
}
