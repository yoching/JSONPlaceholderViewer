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
                    networkMock.entitiesToReturn = { request -> Any? in
                        if request is PostsRequest {
                            return [
                                JSONPlaceholderApi.Post.makeSample(identifier: 1)
                            ]
                        }
                        return nil
                    }
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

            it("fetches user & comments from network") {
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
                expect(networkMock.executedRequests.count).toEventually(equal(2))
                expect(networkMock.executedRequests.compactMap { $0 as? UserRequest }.count)
                    .toEventually(equal(1))
                expect(networkMock.executedRequests.compactMap { $0 as? CommentsRequest }.count)
                    .toEventually(equal(1))
            }

            context("network success") {

                var userToReturn: UserFromApi!
                var commentsToReturn: [CommentFromApi]!

                beforeEach {
                    userToReturn = JSONPlaceholderApi.User.makeSample(identifier: 1)
                    commentsToReturn = [JSONPlaceholderApi.Comment.makeSample(postIdentifier: 1, identifier: 1)]

                    networkMock.isReturningError = false
                    networkMock.entitiesToReturn = { request -> Any? in
                        if request is UserRequest {
                            return userToReturn
                        }

                        if request is CommentsRequest {
                            return commentsToReturn
                        }

                        return nil
                    }
                }

                it("passes fetched data to database") {
                    // arrange
                    databaseMock.parametersPassedToPopulatePost = []
                    let postMock = PostMock(
                        identifier: 1,
                        title: "title",
                        userProtocol: UserMock(identifier: 1)
                    )

                    // act
                    dataProvider.populate(postMock).start()

                    // assert
                    expect(databaseMock.parametersPassedToPopulatePost.count) == 1
                    expect(databaseMock.parametersPassedToPopulatePost.first?.post as? PostMock) == postMock
                    expect(databaseMock.parametersPassedToPopulatePost.first?.dataFromApi.user) == userToReturn
                    expect(databaseMock.parametersPassedToPopulatePost.first?.dataFromApi.comments) == commentsToReturn
                }
            }

            context("network fails") {

                beforeEach {
                    networkMock.isReturningError = true
                }

                it("doesn't populate post in database") {
                    // arrange
                    databaseMock.parametersPassedToPopulatePost = []
                    let postMock = PostMock(
                        identifier: 1,
                        title: "title",
                        userProtocol: UserMock(identifier: 1)
                    )

                    // act
                    dataProvider.populate(postMock).start()

                    // assert
                    expect(databaseMock.parametersPassedToPopulatePost.count).toEventually(equal(0))
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
    let comments: Set<JSONPlaceholderViewer.Comment> = Set<JSONPlaceholderViewer.Comment>()

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

extension JSONPlaceholderApi.User: Equatable {
    public static func == (lhs: JSONPlaceholderApi.User, rhs: JSONPlaceholderApi.User) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension JSONPlaceholderApi.Comment: Equatable {
    public static func == (lhs: JSONPlaceholderApi.Comment, rhs: JSONPlaceholderApi.Comment) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
class UserMock: UserProtocol, Equatable {
    static func == (lhs: UserMock, rhs: UserMock) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    let identifier: Int64
    let name: String?

    init(identifier: Int64, name: String? = nil) {
        self.identifier = identifier
        self.name = name
    }
}

class NetworkMock: Networking {
    var isReturningError: Bool = false
    var timesGetResponseCalled = 0
    var lastRequest: Any?
    var executedRequests = [Any]() // TODO: decide which to use with lastRequest

    var entitiesToReturn: (Any) -> Any? = { _ in return nil }

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
                    if let entityToReturn = self.entitiesToReturn(request) {
                        // swiftlint:disable:next force_cast
                        observer.send(value: entityToReturn as! RequestType.Response)
                    }
                    observer.sendCompleted()
                }
            }
    }
}

import APIKit
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

final class DatabaseMock: DatabaseManaging {
    var timesSavePostsCalled: Int = 0
    var timesFetchPostsCalled: Int = 0
    var timesFetchUserCalled: Int = 0

    var parametersPassedToPopulatePost: [(post: PostProtocol, dataFromApi: DataToPopulatePost)] = []

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

    func populatePost(_ post: PostProtocol, with dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError> {
        return SignalProducer<Void, DatabaseError>(value: ())
            .on(started: {
                self.parametersPassedToPopulatePost.append((post: post, dataFromApi: dataFromApi))
            })
    }
}
