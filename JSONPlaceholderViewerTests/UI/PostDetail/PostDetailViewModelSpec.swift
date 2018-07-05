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

        var viewModel: PostDetailViewModel!

        beforeEach {
            dataProviderMock = DataProviderMock()
            postMock = PostMock(identifier: 1, userProtocol: UserMock(identifier: 1))

            viewModel = PostDetailViewModel(of: postMock, dataProvider: dataProviderMock)
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

            context("populate succeed") {
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
        }
    }
}
