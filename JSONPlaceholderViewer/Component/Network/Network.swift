//
//  Network.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import JSONPlaceholderApi

protocol Networking {
    func getResponse<RequestType: JSONPlaceholderRequest>(of request: RequestType)
        -> SignalProducer<RequestType.Response, NetworkError>
}

final class Network: Networking {

    private let client: ApiClientProtocol

    init(apiClient: ApiClientProtocol) {
        self.client = apiClient
    }

    func getResponse<RequestType: JSONPlaceholderRequest>(
        of request: RequestType)
        -> SignalProducer<RequestType.Response, NetworkError> {

            return SignalProducer { [unowned self] observer, lifetime in

                let task = self.client.send(request) { result in
                    switch result {
                    case let .success(response):
                        observer.send(value: response)
                        observer.sendCompleted()
                    case let .failure(error):
                        observer.send(error: NetworkError(sessionTaskError: error))
                    }
                }

                lifetime.observeEnded {
                    task?.cancel()
                }
            }
    }

}
