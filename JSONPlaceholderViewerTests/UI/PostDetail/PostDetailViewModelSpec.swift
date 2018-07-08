//
//  PostDetailViewModelSpec.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/1/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift

@testable import JSONPlaceholderViewer

class PostDetailViewModelSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {

        var dataProviderMock: DataProviderMock!
        var postMock: PostMock!
        var loadingErrorViewModelMock: LoadingErrorViewModelMock!

        var viewModel: PostDetailViewModel!

        beforeEach {
            dataProviderMock = DataProviderMock()
            postMock = PostMock(identifier: 1, userProtocol: UserMock(identifier: 1))
            loadingErrorViewModelMock = LoadingErrorViewModelMock()

            viewModel = PostDetailViewModel(
                of: postMock,
                dataProvider: dataProviderMock,
                loadingErrorViewModel: loadingErrorViewModelMock,
                loadingIndicatorViewModel: LoadingIndicatorViewModel(loadingMessage: "loading")
            )
        }

        describe("viewWillAppear") {
            it("populate post at DataProvider") {
                // arrange
                dataProviderMock.timesPopulatePostStarted = 0

                // act
                viewModel.viewWillAppear()

                // assert
                expect(dataProviderMock.timesPopulatePostStarted).toEventually(equal(1))
            }

            describe("loading indicator") {
                context("cache doesn't exist") {
                    it("shows loading indicator") {
                        // arrange
                        var isLoadingIndicatorHiddenChanges: [Bool] = []
                        viewModel.isLoadingIndicatorHidden.producer
                            .startWithValues { isHidden in
                                isLoadingIndicatorHiddenChanges.append(isHidden)
                        }

                        // act
                        viewModel.viewWillAppear()

                        // assert
                        expect(isLoadingIndicatorHiddenChanges).toEventually(equal([true, false, true]))
                    }
                }

                context("cache exist") {

                    beforeEach {
                        let user = UserMock(identifier: 1, name: "user name")
                        postMock = PostMock(identifier: 1, userProtocol: user, isPopulated: true)
                        viewModel = PostDetailViewModel(
                            of: postMock,
                            dataProvider: dataProviderMock,
                            loadingErrorViewModel: LoadingErrorViewModel(errorMessage: "error"),
                            loadingIndicatorViewModel: LoadingIndicatorViewModel(loadingMessage: "loading")
                        )
                    }

                    it("doesn't show loading indicator") {
                        // arrange
                        var isLoadingIndicatorHiddenChanges: [Bool] = []
                        viewModel.isLoadingIndicatorHidden.producer
                            .startWithValues { isHidden in
                                isLoadingIndicatorHiddenChanges.append(isHidden)
                        }

                        // act
                        viewModel.viewWillAppear()

                        // assert
                        expect(isLoadingIndicatorHiddenChanges).toEventually(equal([true]))
                    }
                }
            }

            context("populate succeed") {

                beforeEach {
                    dataProviderMock.populateShouldSucceed = true
                }

                it("updates userName") {
                    // arrange
                    dataProviderMock.populatePost = { post in
                        if let user = post.userProtocol as? UserMock {
                            user.name = "user name"
                        }
                    }

                    var userNameChanges: [String?] = []
                    viewModel.userName.producer
                        .logEvents()
                        .startWithValues { name in
                            userNameChanges.append(name)
                    }

                    // act
                    viewModel.viewWillAppear()

                    // assert
                    expect(userNameChanges.count).toEventually(equal(2))
                    expect(userNameChanges[0]).toEventually(beNil())
                    expect(userNameChanges[1]).toEventually(equal("user name"))
                }

                it("updates numberOfComments") {
                    // arrange
                    dataProviderMock.populatePost = { post in
                        guard let postMock = post as? PostMock else {
                            return
                        }
                        let comments: [CommentProtocol] = [
                            CommentMock(identifier: 1),
                            CommentMock(identifier: 2),
                            CommentMock(identifier: 3)
                        ]
                        postMock.commentArray = comments
                    }

                    var numberOfCommentsChanges: [String] = []
                    viewModel.numberOfComments.producer
                        .logEvents()
                        .startWithValues { numberOfComments in
                            numberOfCommentsChanges.append(numberOfComments)
                    }

                    // act
                    viewModel.viewWillAppear()

                    // assert
                    expect(numberOfCommentsChanges.count).toEventually(equal(2))
                    expect(numberOfCommentsChanges[0]).toEventually(equal("0"))
                    expect(numberOfCommentsChanges[1]).toEventually(equal("3"))
                }

            }

            context("populate failed") {

                beforeEach {
                    dataProviderMock.populateShouldSucceed = false
                }

                context("cache doesn't exit") {
                    it("shows error view") {
                        // arrange
                        var isLoadingErrorHiddenChanges: [Bool] = []
                        viewModel.isLoadingErrorHidden.producer
                            .startWithValues { isHidden in
                                isLoadingErrorHiddenChanges.append(isHidden)
                        }

                        // act
                        viewModel.viewWillAppear()

                        // assert
                        expect(isLoadingErrorHiddenChanges).toEventually(equal([true, false]))
                    }

                    it("update error message") {
                        // arrange
                        loadingErrorViewModelMock.timesUpdateErrorMessageCalled = 0

                        // act
                        viewModel.viewWillAppear()

                        // assert
                        expect(loadingErrorViewModelMock.timesUpdateErrorMessageCalled).toEventually(equal(1))
                    }

                }

                context("cache exist") {

                    beforeEach {
                        let user = UserMock(identifier: 1, name: "user name")
                        postMock = PostMock(identifier: 1, userProtocol: user, isPopulated: true)
                        viewModel = PostDetailViewModel(
                            of: postMock,
                            dataProvider: dataProviderMock,
                            loadingErrorViewModel: LoadingErrorViewModel(errorMessage: "error"),
                            loadingIndicatorViewModel: LoadingIndicatorViewModel(loadingMessage: "loading")
                        )
                    }

                    it("doesn't show error") {
                        // arrange
                        var isLoadingErrorHiddenChanges: [Bool] = []
                        viewModel.isLoadingErrorHidden.producer
                            .startWithValues { isHidden in
                                isLoadingErrorHiddenChanges.append(isHidden)
                        }

                        // act
                        viewModel.viewWillAppear()

                        // assert
                        expect(isLoadingErrorHiddenChanges).toEventually(equal([true]))
                    }
                }

            }
        }
    }
}
