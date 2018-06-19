//
//  JSONPlaceholderSessionTask.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public class JSONPlaceholderSessionTask {

    let sessionTask: SessionTask
    public init(sessionTask: SessionTask) {
        self.sessionTask = sessionTask
    }

    public func resume() {
        sessionTask.resume()
    }

    public func cancel() {
        sessionTask.cancel()
    }
}
