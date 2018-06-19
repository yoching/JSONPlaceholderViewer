//
//  Request+Decodable.swift
//  JSONPlaceholderApi
//
//  Created by Yoshikuni Kato on 6/18/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import APIKit

final class DecodableDataParser: DataParser {
    var contentType: String? {
        return "application/json"
    }

    func parse(data: Data) throws -> Any {
        return data
    }
}

extension Request where Response: Decodable {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let data = object as! Data // swiftlint:disable:this force_cast
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
