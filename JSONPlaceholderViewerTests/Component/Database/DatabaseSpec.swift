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

                var fetchedPosts: [[PostProtocol]] = []
                database.posts.producer
                    .startWithValues { value in
                        fetchedPosts.append(value)
                }

                // act
                database.fetchPosts()

                // assert
                expect(fetchedPosts[0].count).toEventually(equal(0))
                expect(fetchedPosts[1].count).toEventually(equal(3))
            }
        }

        describe("savePosts") {
            it("save posts to CoreData") {
                // act
                let posts = [JSONPlaceholderApi.Post(), JSONPlaceholderApi.Post(), JSONPlaceholderApi.Post()]
                database.savePosts(posts)

                // assert
                let fetchedPosts = try? coreDataStackMock.viewContext.fetch(Post.sortedFetchRequest)
                expect(fetchedPosts?.count) == 3
            }
        }
    }
}
