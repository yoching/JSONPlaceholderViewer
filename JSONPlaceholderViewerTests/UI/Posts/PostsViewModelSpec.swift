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
        var loadingErrorViewModelMock: LoadingErrorViewModelMock!

        var postsViewModel: PostsViewModel!

        beforeEach {
            dataProviderMock = DataProviderMock()
            loadingErrorViewModelMock = LoadingErrorViewModelMock()

            postsViewModel = PostsViewModel(
                dataProvider: dataProviderMock,
                loadingIndicatorViewModel: LoadingIndicatorViewModel(loadingMessage: "loading"),
                loadingErrorViewModel: loadingErrorViewModelMock
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
                    PostMock(identifier: 1, userProtocol: UserMock(identifier: 1)),
                    PostMock(identifier: 2, userProtocol: UserMock(identifier: 2)),
                    PostMock(identifier: 3, userProtocol: UserMock(identifier: 3))
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
