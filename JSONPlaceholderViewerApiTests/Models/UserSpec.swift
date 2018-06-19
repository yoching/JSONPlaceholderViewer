//
//  UserSpec.swift
//  JSONPlaceholderViewerApiTests
//
//  Created by Yoshikuni Kato on 6/19/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreLocation

@testable import JSONPlaceholderViewerApi

class UserSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        it("parses json") {
            // arrange
            let json = """
            {
                "id": 1,
                "name": "Leanne Graham",
                "username": "Bret",
                "email": "Sincere@april.biz",
                "address": {
                    "street": "Kulas Light",
                    "suite": "Apt. 556",
                    "city": "Gwenborough",
                    "zipcode": "92998-3874",
                "geo": {
                    "lat": "-37.3159",
                    "lng": "81.1496"
                }
            },
                "phone": "1-770-736-8031 x56442",
                "website": "hildegard.org",
                "company": {
                    "name": "Romaguera-Crona",
                    "catchPhrase": "Multi-layered client-server neural-net",
                    "bs": "harness real-time e-markets"
                }
            }
            """.data(using: .utf8)!

            // act
            var user: User!
            do {
                user = try JSONDecoder().decode(User.self, from: json)
            } catch {
                fail(error.localizedDescription)
                return
            }

            // assert
            expect(user.identifier) == 1
            expect(user.name) == "Leanne Graham"
            expect(user.userName) == "Bret"
            expect(user.email) == "Sincere@april.biz"
            let expectedAddress = Address(
                street: "Kulas Light",
                suite: "Apt. 556",
                city: "Gwenborough",
                zipcode: "92998-3874",
                geo: GeoLocation(lat: "-37.3159", lng: "81.1496")
            )
            expect(user.address) == expectedAddress
            expect(user.phone) == "1-770-736-8031 x56442"
            expect(user.website) == "hildegard.org"
            let expectedCompany = Company(
                name: "Romaguera-Crona",
                catchPhrase: "Multi-layered client-server neural-net",
                business: "harness real-time e-markets"
            )
            expect(user.company) == expectedCompany
        }
    }
}
