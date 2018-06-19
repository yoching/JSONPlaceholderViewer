//
//  SessionTaskError.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public enum SessionTaskError: Error {

    case connectionError(Error)
    case requestError(Error)
    case responseError(Error)

    init(apiKitError: APIKit.SessionTaskError) {
        switch apiKitError {
        case let .connectionError(error):
            self = .connectionError(error)
        case let .requestError(error):
            self = .requestError(error)
        case let .responseError(error):
            self = .responseError(error)
        }
    }
}
