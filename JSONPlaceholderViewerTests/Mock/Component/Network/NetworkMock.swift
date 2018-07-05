//
//  NetworkMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import JSONPlaceholderApi
import APIKit

@testable import JSONPlaceholderViewer

final class NetworkMock: Networking {
    var isReturningError: Bool = false
    var timesGetResponseCalled = 0
    var executedRequests = [Any]()

    var entitiesToReturn: (Any) -> Any? = { _ in return nil }

    func getResponse<RequestType: JSONPlaceholderRequest>(of request: RequestType)
        -> SignalProducer<RequestType.Response, NetworkError> {
            timesGetResponseCalled += 1
            executedRequests.append(request)
            return SignalProducer { observer, _ in
                if self.isReturningError {
                    let error = NSError(domain: "domain", code: 100, userInfo: nil)
                    observer.send(error: NetworkError(sessionTaskError: .responseError(error)))
                } else {
                    if let entityToReturn = self.entitiesToReturn(request) {
                        // swiftlint:disable:next force_cast
                        observer.send(value: entityToReturn as! RequestType.Response)
                    }
                    observer.sendCompleted()
                }
            }
    }
}

final class AnyRequest<Request: JSONPlaceholderRequest>: JSONPlaceholderRequest {

    var method: HTTPMethod {
        return request.method
    }

    var path: String {
        return request.path
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Request.Response {
        return try request.response(from: object, urlResponse: urlResponse)
    }
    typealias Response = Request.Response

    private let request: Request
    init(request: Request) {
        self.request = request
    }
}
