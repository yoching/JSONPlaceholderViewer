//
//  PostSpec.swift
//  JSONPlaceholderViewerApiTests
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import JSONPlaceholderViewerApi

class PostSpec: QuickSpec {
    override func spec() {

        it("parses json") {

            // arrange
            let json = """
            {
                "userId": 1,
                "id": 1,
                "title": "title",
                "body": "body"
            }
            """.data(using: .utf8)!

            // act
            var post: Post!
            do {
                post = try JSONDecoder().decode(Post.self, from: json)
            } catch {
                fail(error.localizedDescription)
                return
            }

            // assert
            expect(post.userIdentifier) == 1
            expect(post.identifier) == 1
            expect(post.title) == "title"
            expect(post.body) == "body"
        }
    }
}
