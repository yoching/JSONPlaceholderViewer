//
//  NetworkError.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import JSONPlaceholderApi

protocol NetworkErrorProtocol {
    init(sessionTaskError: SessionTaskError)
}

struct NetworkError: Error, NetworkErrorProtocol {
    let sessionTaskError: SessionTaskError
    init(sessionTaskError: SessionTaskError) {
        self.sessionTaskError = sessionTaskError
    }
}
