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
                    PostMock(identifier: 1, userProtocol: UserMock(identifier: 1)),
                    PostMock(identifier: 2, userProtocol: UserMock(identifier: 2)),
                    PostMock(identifier: 3, userProtocol: UserMock(identifier: 3))
                ]
                databaseMock.mutablePosts.value = samplePosts

                // act & assert
                expect(dataProvider.posts.value as? [PostMock]) == samplePosts
            }
        }

        describe("populate post") {

            it("fetches user & comments from network") {
                // arrange
                networkMock.executedRequests = []
                let postMock = PostMock(
                    identifier: 1,
                    body: "body",
                    title: "title",
                    userProtocol: UserMock(identifier: 1),
                    commentArray: []
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
                        body: "body",
                        title: "title",
                        userProtocol: UserMock(identifier: 1),
                        commentArray: []
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
                        body: "body",
                        title: "title",
                        userProtocol: UserMock(identifier: 1),
                        commentArray: []
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
