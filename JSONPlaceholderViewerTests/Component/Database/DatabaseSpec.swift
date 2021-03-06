//
//  DatabaseSpec.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import JSONPlaceholderApi
import Result
import ReactiveSwift

@testable import JSONPlaceholderViewer

class DatabaseSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {

        var coreDataStackMock: CoreDataStackMock!
        var database: Database!

        beforeEach {
            coreDataStackMock = CoreDataStackMock()
            coreDataStackMock.setupStack().start()
            database = Database(
                coreDataStack: coreDataStackMock
            )
        }

        describe("fetchPosts") {
            it("fetch posts from CoreData") {
                // arrange
                let user1 = coreDataStackMock.addUser(identifier: 1)
                let user2 = coreDataStackMock.addUser(identifier: 2)
                let user3 = coreDataStackMock.addUser(identifier: 3)
                coreDataStackMock.addPost(identifier: 1, user: user1)
                coreDataStackMock.addPost(identifier: 2, user: user2)
                coreDataStackMock.addPost(identifier: 3, user: user3)

                var fetchedPosts: [[PostProtocol]?] = []
                database.posts.producer
                    .startWithValues { value in
                        fetchedPosts.append(value)
                }

                // act
                database.fetchPosts().start()

                // assert
                expect(fetchedPosts[0]).toEventually(beNil())
                expect(fetchedPosts[1]?.count).toEventually(equal(3))
            }
        }

        describe("savePosts") {
            let posts = [
                JSONPlaceholderApi.Post.makeSample(identifier: 1),
                JSONPlaceholderApi.Post.makeSample(identifier: 2),
                JSONPlaceholderApi.Post.makeSample(identifier: 3)
            ]
            context("initial fetch has been already executed") {
                it("save posts to CoreData") {
                    // arrange
                    database.fetchPosts().start()

                    // act
                    database.savePosts(posts).start()

                    // assert
                    expect((try? coreDataStackMock.viewContext.fetch(Post.sortedFetchRequest))?.count)
                        .toEventually(equal(3))
                }
            }
            context("initial fetch has not been executed") {
                it("returns error") {
                    // act
                    var fetchedResult: Result<Void, DatabaseError>?
                    database.savePosts(posts)
                        .startWithResult { result in
                            fetchedResult = result
                    }

                    // assert
                    expect(fetchedResult?.error?.isNotFetchedInitiallyError).toEventually(beTrue())
                }
            }

        }

        describe("populatePost") {
            it("saves user and comments") {
                // arrange
                let usersBeforeAct = coreDataStackMock.fetchUsers()
                expect(usersBeforeAct.count).to(equal(0))
                let commentsBeforeAct = coreDataStackMock.fetchComments()
                expect(commentsBeforeAct.count).to(equal(0))

                let userEntityFromApi = User.makeSample(identifier: 1)
                let commentsFromApi = [
                    CommentFromApi.makeSample(postIdentifier: 1, identifier: 1),
                    CommentFromApi.makeSample(postIdentifier: 1, identifier: 2),
                    CommentFromApi.makeSample(postIdentifier: 1, identifier: 3)
                ]

                let originalUser = coreDataStackMock.addUser(identifier: 1)
                let post = coreDataStackMock.addPost(identifier: 1, user: originalUser)

                // act
                database.populatePost(post, with: (user: userEntityFromApi, comments: commentsFromApi)).start()

                // assert
                // user
                expect(coreDataStackMock.fetchUsers().count).toEventually(equal(1))
                expect(post.user).toEventuallyNot(beNil())
                expect(post.user.identifier)
                    .toEventually(equal(coreDataStackMock.fetchUsers().first?.identifier))

                // comments
                expect(coreDataStackMock.fetchComments().count).toEventually(equal(3))
                expect(post.comments.count).toEventually(equal(3))
            }
        }
    }
}

extension DatabaseError {
    var isNotFetchedInitiallyError: Bool {
        switch self {
        case .notFetchedInitially:
            return true
        case .context, .invalidUserDataPassed, .invalidCommentsDataPassed:
            return false
        }
    }
}
