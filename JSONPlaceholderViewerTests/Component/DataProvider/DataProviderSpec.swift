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

    // swiftlint:disable function_body_length
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

            context("data hasn't been fetched from database") {
                beforeEach {
                    databaseMock.mutablePosts.value = nil
                }
                it("fetch data from database") {
                    // arrange
                    databaseMock.timesFetchPostsCalled = 0

                    // act
                    dataProvider.fetchPosts().start()

                    // assert
                    expect(databaseMock.timesFetchPostsCalled).toEventually(equal(1))
                }
            }

            it("sends network request") {
                // arrange
                networkMock.executedRequests = []

                // act
                dataProvider.fetchPosts().start()

                // assert
                expect(networkMock.executedRequests.count).toEventually(equal(1))
                expect(networkMock.executedRequests.first as? PostsRequest).toEventuallyNot(beNil())
            }

            context("network request success") {

                beforeEach {
                    networkMock.isReturningError = false
                    networkMock.entityToReturn = [
                        JSONPlaceholderApi.Post.makeSample(identifier: 1)
                    ]
                }

                it("saves posts in database") {
                    // arrange
                    databaseMock.timesSavePostsCalled = 0

                    // act
                    dataProvider.fetchPosts().start()

                    // assert
                    expect(databaseMock.timesSavePostsCalled) == 1
                }
            }

            context("network request failure") {

                beforeEach {
                    networkMock.isReturningError = true
                }

                it("doesn't save posts in database") {
                    // arrange
                    databaseMock.timesSavePostsCalled = 0

                    // act
                    dataProvider.fetchPosts().start()

                    // assert
                    expect(databaseMock.timesSavePostsCalled) == 0
                }
            }
        }

        describe("posts") {
            it("provides posts in database") {
                // arrange
                let samplePosts = [
                    PostMock(identifier: 1, title: "1", userProtocol: UserMock(identifier: 1)),
                    PostMock(identifier: 2, title: "2", userProtocol: UserMock(identifier: 2)),
                    PostMock(identifier: 3, title: "3", userProtocol: UserMock(identifier: 3))
                ]
                databaseMock.mutablePosts.value = samplePosts

                // act & assert
                expect(dataProvider.posts.value as? [PostMock]) == samplePosts
            }
        }

        describe("fetchUser") {
            it("fetch data from database") {
                // arrange
                databaseMock.timesFetchUserCalled = 0

                // act
                dataProvider.fetchUser(identifier: 1).start()

                // assert
                expect(databaseMock.timesFetchUserCalled).toEventually(equal(1))
            }
        }

        describe("populate post") {

            it("fetches user data from api") {
                // arrange
                networkMock.executedRequests = []
                let postMock = PostMock(
                    identifier: 1,
                    title: "title",
                    userProtocol: UserMock(identifier: 1)
                )

                // act
                dataProvider.populate(postMock).start()

                // assert
                expect(networkMock.executedRequests.count).toEventually(equal(1))
                expect(networkMock.executedRequests.last as? UserRequest).toEventuallyNot(beNil())
            }

            context("network success") {

                beforeEach {
                    networkMock.isReturningError = false
                    networkMock.entityToReturn = JSONPlaceholderApi.User.makeSample(identifier: 1)
                }

                it("populate post in database") {
                    // arrange
                    databaseMock.timesPopulatePostCalled = 0
                    let postMock = PostMock(
                        identifier: 1,
                        title: "title",
                        userProtocol: UserMock(identifier: 1)
                    )

                    // act
                    dataProvider.populate(postMock).start()

                    // assert
                    expect(databaseMock.timesPopulatePostCalled).toEventually(equal(1))
                }
            }

            context("network fails") {

                beforeEach {
                    networkMock.isReturningError = true
                }

                it("doesn't populate post in database") {
                    // arrange
                    databaseMock.timesPopulatePostCalled = 0
                    let postMock = PostMock(
                        identifier: 1,
                        title: "title",
                        userProtocol: UserMock(identifier: 1)
                    )

                    // act
                    dataProvider.populate(postMock).start()

                    // assert
                    expect(databaseMock.timesPopulatePostCalled).toEventually(equal(0))
                }
            }
        }
    }
}

class PostMock: PostProtocol, Equatable {
    static func == (lhs: PostMock, rhs: PostMock) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    let identifier: Int64
    let title: String
    let userProtocol: UserProtocol

    init(
        identifier: Int64,
        title: String,
        userProtocol: UserProtocol
        ) {
        self.identifier = identifier
        self.title = title
        self.userProtocol = userProtocol
    }
}

class UserMock: UserProtocol, Equatable {
    static func == (lhs: UserMock, rhs: UserMock) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    let identifier: Int64

    init(identifier: Int64) {
        self.identifier = identifier
    }
}

class NetworkMock: Networking {
    var isReturningError: Bool = false
    var timesGetResponseCalled = 0
    var lastRequest: Any?
    var executedRequests = [Any]() // TODO: decide which to use with lastRequest
    var entityToReturn: Any?

    func getResponse<RequestType: JSONPlaceholderRequest>(of request: RequestType)
        -> SignalProducer<RequestType.Response, NetworkError> {
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
    var timesSavePostsCalled: Int = 0
    var timesFetchPostsCalled: Int = 0
    var timesFetchUserCalled: Int = 0
    var timesPopulatePostCalled: Int = 0

    var mutablePosts = MutableProperty<[PostProtocol]?>(nil)
    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts)
    }

    func fetchPosts() -> SignalProducer<Void, DatabaseError> {
        return SignalProducer<Void, DatabaseError>(value: ())
            .on(started: {
                self.timesFetchPostsCalled += 1
            })
    }

    func savePosts(_ posts: [PostFromApi]) -> SignalProducer<Void, DatabaseError> {
        return SignalProducer<Void, DatabaseError>(value: ())
            .on(started: {
                self.timesSavePostsCalled += 1
            })
    }

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DatabaseError> {
        return SignalProducer<UserProtocol?, DatabaseError>(value: nil)
            .on(started: {
                self.timesFetchUserCalled += 1
            })
    }

    func populatePost(_ post: PostProtocol, with userFromApi: UserFromApi) -> SignalProducer<Void, DatabaseError> {
        return SignalProducer<Void, DatabaseError>(value: ())
            .on(started: {
                self.timesPopulatePostCalled += 1
            })
    }
}
