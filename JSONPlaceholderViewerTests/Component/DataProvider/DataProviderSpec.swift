//
//  DataProviderSpec.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift
import JSONPlaceholderApi

@testable import JSONPlaceholderViewer

class DataProviderSpec: QuickSpec {
    override func spec() {

        var networkMock: NetworkMock!
        var databaseMock: DatabaseMock!

        var dataProvider: DataProvider!

        beforeEach {
            networkMock = NetworkMock()
            databaseMock = DatabaseMock()

            dataProvider = DataProvider(
                network: networkMock,
                database: databaseMock
            )
        }

        describe("fetch posts") {
            it("sends network request") {
                // arrange
                networkMock.executedRequests = []

                // act
                dataProvider.fetchPosts()

                // assert
                expect(networkMock.executedRequests.count) == 1
                let request = networkMock.executedRequests[0] as? PostsRequest
                expect(request).toNot(beNil())
            }
        }

        describe("posts") {
            it("provides posts in database") {
                // arrange
                let samplePosts = [PostMock(), PostMock(), PostMock()]
                databaseMock.mutablePosts.value = samplePosts

                // act & assert
                expect(dataProvider.posts.value as? [PostMock]) == samplePosts
            }
        }
    }
}

struct PostMock: PostProtocol, Equatable {

}

class NetworkMock: Networking {
    var isReturningError: Bool = false
    var timesGetResponseCalled = 0
    var lastRequest: Any?
    var executedRequests = [Any]()
    var entityToReturn: Any?

    func getResponse<RequestType: JSONPlaceholderRequest>(of request: RequestType) -> SignalProducer<RequestType.Response, NetworkError> {
        timesGetResponseCalled += 1
        lastRequest = request
        executedRequests.append(request)
        return SignalProducer { observer, _ in
            if self.isReturningError {
                let error = NSError(domain: "domain", code: 100, userInfo: nil)
                observer.send(error: NetworkError(sessionTaskError: .responseError(error)))
            } else {
                if let entityToReturn = self.entityToReturn {
                    // swiftlint:disable:next force_cast
                    observer.send(value: entityToReturn as! RequestType.Response)
                }
                observer.sendCompleted()
            }
        }
    }
}

final class DatabaseMock: DatabaseManaging {
    var mutablePosts = MutableProperty<[PostProtocol]>([])
    var posts: Property<[PostProtocol]> {
        return Property(mutablePosts)
    }

    func fetchPosts() {

    }
}
