//
//  JSONPlaceholderApiClient.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit
import Result

public protocol ApiClientProtocol {
    func send<RequestType: JSONPlaceholderRequest>(
        _ request: RequestType,
        handler: @escaping (Result<RequestType.Response, SessionTaskError>) -> Void
        ) -> SessionTask?
}

public final class ApiClient: ApiClientProtocol {

    private let session: Session

    public init() {
        session = Session.shared
    }

    public func send<RequestType: JSONPlaceholderRequest>(
        _ request: RequestType,
        handler: @escaping (Result<RequestType.Response, SessionTaskError>) -> Void
        ) -> SessionTask? {
        return session
            .send(request) { result in
                handler(result.mapError(SessionTaskError.init))
            }
            .map(SessionTask.init)
    }
}
