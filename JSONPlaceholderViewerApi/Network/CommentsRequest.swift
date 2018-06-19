//
//  CommentsRequest.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

struct CommentsRequest: JSONPlaceholderRequest {
    typealias Response = [Comment]
    let method: HTTPMethod = .get
    let path: String = "/comments"
    let parameters: Any?
    init(postIdentifier: Int) {
        parameters = ["postId": postIdentifier]
    }
}
