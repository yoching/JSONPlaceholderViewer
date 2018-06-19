//
//  CommentSpec.swift
//  JSONPlaceholderViewerApiTests
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import JSONPlaceholderViewerApi

class CommentSpec: QuickSpec {
    override func spec() {

        it("parses json") {

            // arrange
            let json = """
            {
                "postId": 1,
                "id": 1,
                "name": "name",
                "email": "email",
                "body": "body"
            }
            """.data(using: .utf8)!

            // act
            var comment: Comment!
            do {
                comment = try JSONDecoder().decode(Comment.self, from: json)
            } catch {
                fail(error.localizedDescription)
                return
            }

            // assert
            expect(comment.postIdentifier) == 1
            expect(comment.identifier) == 1
            expect(comment.name) == "name"
            expect(comment.email) == "email"
            expect(comment.body) == "body"
        }
    }

}
