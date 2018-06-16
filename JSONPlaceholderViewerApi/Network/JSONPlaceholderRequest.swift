//
//  JSONPlaceholderRequest.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

public struct JSONPlaceholderRequestSetting: ApiRequestSetting {
    public static let hostname: String = "jsonplaceholder.typicode.com"
    public static let basePath: String = ""
}

public protocol JSONPlaceholderRequest: Request {
    
}

public extension JSONPlaceholderRequest {
    var baseURL: URL {
        return URL(string: "http://\(JSONPlaceholderRequestSetting.hostname)\(JSONPlaceholderRequestSetting.basePath)")!
    }
}
