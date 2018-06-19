//
//  JSONPlaceholderApiClient.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit
import Result

public protocol JSONPlaceholderApiClientProtocol {
    func send<RequestType: JSONPlaceholderRequest>(
        _ request: RequestType,
        handler: @escaping (Result<RequestType.Response, JSONPlaceholderApiError>) -> Void
        ) -> JSONPlaceholderSessionTask?
}

public final class JSONPlaceholderApiClient: JSONPlaceholderApiClientProtocol {

    private let session = Session.shared

    public func send<RequestType: JSONPlaceholderRequest>(
        _ request: RequestType,
        handler: @escaping (Result<RequestType.Response, JSONPlaceholderApiError>) -> Void
        ) -> JSONPlaceholderSessionTask? {
        return session
            .send(request) { result in
                handler(result.mapError(JSONPlaceholderApiError.init))
            }
            .map(JSONPlaceholderSessionTask.init)
    }
}
