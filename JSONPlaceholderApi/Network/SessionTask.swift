//
//  JSONPlaceholderSessionTask.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public class SessionTask {

    let sessionTask: APIKit.SessionTask
    public init(sessionTask: APIKit.SessionTask) {
        self.sessionTask = sessionTask
    }

    public func resume() {
        sessionTask.resume()
    }

    public func cancel() {
        sessionTask.cancel()
    }
}
