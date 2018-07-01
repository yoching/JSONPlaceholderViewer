//
//  PostCellModelSpec.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import JSONPlaceholderViewer

class PostCellModelSpec: QuickSpec {
    override func spec() {
        describe("initializer") {
            it("is initialized with post") {
                // arrange
                let postToSet = PostMock(
                    identifier: 1,
                    title: "test title",
                    userProtocol: UserMock(identifier: 1)
                )

                // act
                let cellModel = PostCellModel(post: postToSet)

                // assert
                expect(cellModel.title) == "test title"
                expect(cellModel.postIdentifier) == 1
            }
        }
    }
}
