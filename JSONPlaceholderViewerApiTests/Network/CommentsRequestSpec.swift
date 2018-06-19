//
//  CommentsRequestSpec.swift
//  JSONPlaceholderViewerApiTests
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import APIKit

@testable import JSONPlaceholderViewerApi

class CommentsRequestSpec: QuickSpec {
    override func spec() {

        let stubConfigurator = StubConfigurator(setting: JSONPlaceholderRequestSetting.self)

        describe("initializer") {
            it("add post id to query") {
                // act
                let request = CommentsRequest(postIdentifier: 1)

                // assert
                expect(request.queryParameters?["postId"] as? Int) == 1
            }
        }

        it("gets user") {
            // arrange
            stubConfigurator.setStub(
                endPoint: "/comments?postId=1",
                fromFile: "comments.json",
                statusCode: 200,
                caller: type(of: self)
            )

            // act
            var fetchedComments: [Comment]?
            let request = CommentsRequest(postIdentifier: 1)
            Session.send(request) { result in
                fetchedComments = result.value
            }

            // assert
            expect(fetchedComments).toEventuallyNot(beNil())
        }
    }
}
