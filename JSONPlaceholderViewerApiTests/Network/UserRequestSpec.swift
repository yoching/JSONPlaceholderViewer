//
//  UserRequestSpec.swift
//  JSONPlaceholderViewerApiTests
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import APIKit
import Result

@testable import JSONPlaceholderViewerApi

class UserRequestSpec: QuickSpec {

    override func spec() {

        let stubConfigurator = StubConfigurator(setting: JSONPlaceholderRequestSetting.self)

        describe("initializer") {
            it("add user id to path") {
                // act
                let request = UserRequest(userIdentifier: 1)

                // assert
                expect(request.path) == "/users/1"
            }
        }

        it("gets user") {
            // arrange
            stubConfigurator.setStub(
                endPoint: "/users/1",
                fromFile: "user.json",
                statusCode: 200,
                caller: type(of: self)
            )

            // act
            var fetchedUser: User?
            let request = UserRequest(userIdentifier: 1)
            Session.send(request) { result in
                fetchedUser = result.value
            }

            // assert
            expect(fetchedUser).toEventuallyNot(beNil())
        }
    }
}
