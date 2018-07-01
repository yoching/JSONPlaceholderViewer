//
//  PostsViewModelSpec.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift

@testable import JSONPlaceholderViewer

class PostsViewModelSpec: QuickSpec {
    override func spec() {

        var dataProviderMock: DataProviderMock!

        var postsViewModel: PostsViewModel!

        beforeEach {
            dataProviderMock = DataProviderMock()
            postsViewModel = PostsViewModel(
                dataProvider: dataProviderMock
            )
        }

        describe("cellModels") {
            it("reflects posts in DataProvider") {
                // arrange
                var cellModelChanges: [[PostCellModeling]] = []
                postsViewModel.cellModels
                    .producer
                    .startWithValues { cellModels in
                        cellModelChanges.append(cellModels)
                }

                // act
                dataProviderMock.mutablePosts.value = [
                    PostMock(identifier: 1, title: "1", userProtocol: UserMock(identifier: 1)),
                    PostMock(identifier: 2, title: "2", userProtocol: UserMock(identifier: 2)),
                    PostMock(identifier: 3, title: "3", userProtocol: UserMock(identifier: 3))
                ]

                // assert
                expect(cellModelChanges[0].count).toEventually(equal(0))
                expect(cellModelChanges[1].count).toEventually(equal(3))
            }
        }

        describe("viewWillAppear") {
            context("first fetch") {
                it("fetches data from DataProvider") {
                    // arrange
                    dataProviderMock.timesFetchPostsStarted = 0

                    // act
                    postsViewModel.viewWillAppear()

                    // assert
                    expect(dataProviderMock.timesFetchPostsStarted) == 1
                }
            }
            context("2nd fetch") {
                it("doesn't fetch data from DataProvider") {
                    // arrange
                    postsViewModel.viewWillAppear()
                    dataProviderMock.timesFetchPostsStarted = 0

                    // act
                    postsViewModel.viewWillAppear()

                    // assert
                    expect(dataProviderMock.timesFetchPostsStarted) == 0
                }
            }
        }

    }
}

final class DataProviderMock: DataProviding {
    var timesFetchPostsStarted: Int = 0
    var timesPopulatePostStarted: Int = 0

    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts)
    }
    let mutablePosts = MutableProperty<[PostProtocol]?>(nil)

    func fetchPosts() -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError>(value: ())
            .on(started: {
                self.timesFetchPostsStarted += 1
            })
    }

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DataProviderError> {
        return .init(value: nil)
    }

    func populate(_ post: PostProtocol) -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError>(value: ())
            .on(started: {
                self.timesPopulatePostStarted += 1
            })
    }
}
