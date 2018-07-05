//
//  UserMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

@testable import JSONPlaceholderViewer

final class UserMock: UserProtocol, Equatable {
    static func == (lhs: UserMock, rhs: UserMock) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    var identifier: Int64
    var name: String?

    init(identifier: Int64, name: String? = nil) {
        self.identifier = identifier
        self.name = name
    }
}
