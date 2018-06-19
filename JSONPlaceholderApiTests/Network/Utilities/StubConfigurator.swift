//
//  StubConfigurator.swift
//  JSONPlaceholderApiTests
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import OHHTTPStubs

@testable import JSONPlaceholderApi

final class StubConfigurator {

    // MARK: - Properties
    private let setting: ApiRequestSetting.Type

    // MARK: - Methods
    init(setting: ApiRequestSetting.Type) {
        self.setting = setting
    }

    func setStub(endPoint: String, jsonObject: [String: Any], statusCode: Int32) {
        stub(condition: isHost(setting.hostname)
            && isPath("\(setting.basePath)\(endPoint)")) { _ -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(
                    jsonObject: jsonObject,
                    statusCode: statusCode,
                    headers: nil
                )
        }
    }

    func setStub(endPoint: String, fromFile fileName: String, statusCode: Int32, caller: Swift.AnyClass) {
        stub(condition: isHost(setting.hostname)
            && isPath("\(setting.basePath)\(endPoint)")) { _ -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(
                    fileAtPath: OHPathForFile(fileName, caller)!,
                    statusCode: 200,
                    headers: nil
                )
        }
    }

    func setStubForError(endPoint: String, error: Error) {
        stub(condition: isHost(setting.hostname)
            && isPath("\(setting.basePath)\(endPoint)")) { _ -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(error: error)
        }
    }

    // MARK: - Static Methods
    static func removeAllStubs() {
        OHHTTPStubs.removeAllStubs()
    }
}
