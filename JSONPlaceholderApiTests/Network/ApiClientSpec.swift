//
//  ApiClientSpec.swift
//  JSONPlaceholderApiTests
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import OHHTTPStubs
import APIKit

@testable import JSONPlaceholderApi

class ApiClientSpec: QuickSpec {
    override func spec() {

        let stubConfigurator = StubConfigurator(setting: JSONPlaceholderRequestSetting.self)

        var client: ApiClient!
        beforeEach {
            StubConfigurator.removeAllStubs()
            client = ApiClient()
        }

        describe("sending request") {

            it("returns SessionTask") {
                // arrange
                stubConfigurator.setStub(
                    endPoint: "/test",
                    jsonObject: ["key": "value"],
                    statusCode: 200
                )

                // act
                let task = client.send(TestRequest()) { _ in }

                // assert
                expect(String(describing: task)) == "Optional(JSONPlaceholderApi.SessionTask)"
            }

            context("network error") {
                it("returns ApiError") {
                    // arrange
                    stubConfigurator.setStubForError(
                        endPoint: "/test",
                        error: NSError(
                            domain: NSURLErrorDomain,
                            code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                            userInfo: nil
                        )
                    )

                    // act
                    var error: JSONPlaceholderApi.SessionTaskError?
                    _ = client.send(TestRequest()) { response in
                        error = response.error
                    }

                    // assert
                    expect(error).toEventuallyNot(beNil())
                }
            }

        }

    }
}

// MARK: - dummy
private struct TestRequest: JSONPlaceholderRequest {
    typealias Response = String
    let method: HTTPMethod = .get
    let path: String = "/test"
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> String {
        return "test"
    }
}
