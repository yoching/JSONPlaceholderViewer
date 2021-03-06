//
//  PostsRequestSpec.swift
//  JSONPlaceholderApiTests
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import APIKit
import Result

@testable import JSONPlaceholderApi

class PostsRequestSpec: QuickSpec {

    override func spec() {

        let stubConfigurator = StubConfigurator(setting: JSONPlaceholderRequestSetting.self)

        beforeEach {
            StubConfigurator.removeAllStubs()
        }

        it("gets posts") {
            // arrange
            stubConfigurator.setStub(
                endPoint: "/posts",
                fromFile: "posts.json",
                statusCode: 200,
                caller: type(of: self)
            )

            // act
            var fetchedPosts: [Post]?
            let request = PostsRequest()
            Session.send(request) { result in
                fetchedPosts = result.value
            }

            // assert
            expect(fetchedPosts).toEventuallyNot(beNil())
        }
    }
}
