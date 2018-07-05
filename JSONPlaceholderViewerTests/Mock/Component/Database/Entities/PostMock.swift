//
//  PostMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

@testable import JSONPlaceholderViewer

final class PostMock: PostProtocol, Equatable {
    static func == (lhs: PostMock, rhs: PostMock) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    let identifier: Int64
    let body: String
    let title: String
    let userProtocol: UserProtocol
    var commentArray: [CommentProtocol]

    init(
        identifier: Int64,
        body: String = "",
        title: String = "",
        userProtocol: UserProtocol,
        commentArray: [CommentProtocol] = []
        ) {
        self.identifier = identifier
        self.body = body
        self.title = title
        self.userProtocol = userProtocol
        self.commentArray = commentArray
    }
}
