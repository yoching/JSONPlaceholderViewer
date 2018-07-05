//
//  CommentMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

@testable import JSONPlaceholderViewer

class CommentMock: CommentProtocol {
    let identifier: Int64
    init(
        identifier: Int64
        ) {
        self.identifier = identifier
    }
}
