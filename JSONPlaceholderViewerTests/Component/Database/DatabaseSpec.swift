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

@testable import JSONPlaceholderViewer

class DatabaseSpec: QuickSpec {

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
                coreDataStackMock.addPost(identifier: 1)
                coreDataStackMock.addPost(identifier: 2)
                coreDataStackMock.addPost(identifier: 3)

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
            let posts = [JSONPlaceholderApi.Post(), JSONPlaceholderApi.Post(), JSONPlaceholderApi.Post()]
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

                // TODO: add update, delete test
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
    }
}

extension DatabaseError {
    var isNotFetchedInitiallyError: Bool {
        switch self {
        case .notFetchedInitially:
            return true
        case .context:
            return false
        }
    }
}
