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

    // swiftlint:disable:next function_body_length
    override func spec() {

        var dataProviderMock: DataProviderMock!
        var loadingErrorViewModelMock: LoadingErrorViewModelMock!

        var postsViewModel: PostsViewModel!

        beforeEach {
            dataProviderMock = DataProviderMock()
            loadingErrorViewModelMock = LoadingErrorViewModelMock()
            let emptyDataViewModel = EmptyDataViewModel(
                image: nil,
                message: "empty",
                isImageHidden: true,
                isRetryButtonHidden: false
            )

            postsViewModel = PostsViewModel(
                dataProvider: dataProviderMock,
                emptyDataViewModel: emptyDataViewModel,
                loadingErrorViewModel: loadingErrorViewModelMock,
                loadingIndicatorViewModel: LoadingIndicatorViewModel(loadingMessage: "loading")
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

        describe("isEmptyDataViewHidden") {
            context("no CellModels") {
                it("is false") {
                    // arrange
                    var isEmptyDataViewHiddenChanges: [Bool] = []
                    postsViewModel.isEmptyDataViewHidden.producer
                        .startWithValues { isHidden in
                            isEmptyDataViewHiddenChanges.append(isHidden)
                    }

                    // act
                    dataProviderMock.mutablePosts.value = []

                    // assert
                    expect(isEmptyDataViewHiddenChanges).toEventually(equal([false]))
                }
            }
            context("CellModels are not empty") {
                it("is true") {
                    // arrange
                    var isEmptyDataViewHiddenChanges: [Bool] = []
                    postsViewModel.isEmptyDataViewHidden.producer
                        .startWithValues { isHidden in
                            isEmptyDataViewHiddenChanges.append(isHidden)
                    }

                    // act
                    dataProviderMock.mutablePosts.value = [
                        PostMock(identifier: 1, userProtocol: UserMock(identifier: 1)),
                        PostMock(identifier: 2, userProtocol: UserMock(identifier: 2)),
                        PostMock(identifier: 3, userProtocol: UserMock(identifier: 3))
                    ]

                    // assert
                    expect(isEmptyDataViewHiddenChanges).toEventually(equal([false, true]))
                }
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

                context("cellModels are not empty") {
                    beforeEach {
                        dataProviderMock.mutablePosts.value = [
                            PostMock(identifier: 1, userProtocol: UserMock(identifier: 1)),
                            PostMock(identifier: 2, userProtocol: UserMock(identifier: 1)),
                            PostMock(identifier: 3, userProtocol: UserMock(identifier: 1)),
                            PostMock(identifier: 4, userProtocol: UserMock(identifier: 1)),
                            PostMock(identifier: 5, userProtocol: UserMock(identifier: 1))
                        ]
                    }
                    it("does not show loading view") {
                        // arrange
                        var isLoadingIndicatorHiddenChanges: [Bool] = []
                        postsViewModel.isLoadingIndicatorHidden.producer
                            .startWithValues { isHidden in
                                isLoadingIndicatorHiddenChanges.append(isHidden)
                        }

                        // act
                        postsViewModel.viewWillAppear()

                        // assert
                        expect(isLoadingIndicatorHiddenChanges).toEventually(equal([true]))
                    }
                    context("fetch fail") {
                        beforeEach {
                            dataProviderMock.fetchPostsShouldSucceed = false
                        }
                        it("does not show error view") {
                            // arrange
                            var isLoadingErrorHiddenChanges: [Bool] = []
                            postsViewModel.isLoadingErrorHidden.producer
                                .startWithValues { isHidden in
                                    isLoadingErrorHiddenChanges.append(isHidden)
                            }

                            // act
                            postsViewModel.viewWillAppear()

                            // assert
                            expect(isLoadingErrorHiddenChanges).toEventually(equal([true]))
                        }
                    }
                }

                context("cellModels are empty") {

                    it("shows loading indicator") {
                        // arrange
                        var isLoadingIndicatorHiddenChanges: [Bool] = []
                        postsViewModel.isLoadingIndicatorHidden.producer
                            .startWithValues { isHidden in
                                isLoadingIndicatorHiddenChanges.append(isHidden)
                        }

                        // act
                        postsViewModel.viewWillAppear()

                        // assert
                        expect(isLoadingIndicatorHiddenChanges).toEventually(equal([true, false, true]))
                    }

                    context("fetch succeed") {
                        beforeEach {
                            dataProviderMock.fetchPostsShouldSucceed = true
                        }
                        it("doesn't show loading error") {
                            // arrange
                            var isLoadingErrorHiddenChanges: [Bool] = []
                            postsViewModel.isLoadingErrorHidden.producer
                                .startWithValues { isHidden in
                                    isLoadingErrorHiddenChanges.append(isHidden)
                            }

                            // act
                            postsViewModel.viewWillAppear()

                            // assert
                            expect(isLoadingErrorHiddenChanges).toEventually(equal([true]))
                        }
                    }

                    context("fetch fail") {
                        beforeEach {
                            dataProviderMock.fetchPostsShouldSucceed = false
                        }
                        it("shows error view") {
                            // arrange
                            var isLoadingErrorHiddenChanges: [Bool] = []
                            postsViewModel.isLoadingErrorHidden.producer
                                .startWithValues { isHidden in
                                    isLoadingErrorHiddenChanges.append(isHidden)
                            }

                            // act
                            postsViewModel.viewWillAppear()

                            // assert
                            expect(isLoadingErrorHiddenChanges).toEventually(equal([true, false]))
                        }

                        it("update error message") {
                            // arrange
                            loadingErrorViewModelMock.timesUpdateErrorMessageCalled = 0

                            // act
                            postsViewModel.viewWillAppear()

                            // assert
                            expect(loadingErrorViewModelMock.timesUpdateErrorMessageCalled).toEventually(equal(1))
                        }
                    }
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
