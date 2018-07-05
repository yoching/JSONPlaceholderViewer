//
//  ApiModelExtensions.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import JSONPlaceholderApi

@testable import JSONPlaceholderViewer

extension JSONPlaceholderApi.Post {
    static func makeSample(identifier: Int) -> JSONPlaceholderApi.Post {
        return Post(
            identifier: identifier,
            userIdentifier: 1,
            title: "",
            body: ""
        )
    }
}

extension JSONPlaceholderApi.User {
    static func makeSample(identifier: Int, name: String = "") -> JSONPlaceholderApi.User {
        return User(
            identifier: identifier,
            name: name,
            userName: "",
            email: "",
            address: Address.makeSample(),
            phone: "",
            website: "",
            company: Company.makeSample()
        )
    }
}

extension JSONPlaceholderApi.Company {
    static func makeSample() -> JSONPlaceholderApi.Company {
        return Company(
            name: "name",
            catchPhrase: "catchPhrase",
            business: "business"
        )
    }
}

extension JSONPlaceholderApi.Address {
    static func makeSample() -> JSONPlaceholderApi.Address {
        return Address(
            street: "",
            suite: "",
            city: "",
            zipcode: "",
            geo: GeoLocation.makeSample()
        )
    }
}

extension JSONPlaceholderApi.GeoLocation {
    static func makeSample() -> JSONPlaceholderApi.GeoLocation {
        return GeoLocation(
            lat: "0.0",
            lng: "0.0"
        )
    }
}

extension JSONPlaceholderApi.Comment {
    static func makeSample(postIdentifier: Int, identifier: Int) -> JSONPlaceholderApi.Comment {
        return Comment(
            postIdentifier: postIdentifier,
            identifier: identifier,
            name: "",
            email: "",
            body: ""
        )
    }
}

extension JSONPlaceholderApi.User: Equatable {
    public static func == (lhs: JSONPlaceholderApi.User, rhs: JSONPlaceholderApi.User) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension JSONPlaceholderApi.Comment: Equatable {
    public static func == (lhs: JSONPlaceholderApi.Comment, rhs: JSONPlaceholderApi.Comment) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
