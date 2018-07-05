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

@testable import JSONPlaceholderViewer

class PostDetailViewModelSpec: QuickSpec {
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
        }
    }
}
