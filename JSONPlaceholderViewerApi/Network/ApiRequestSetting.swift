//
//  ApiRequestSetting.swift
//  JSONPlaceholderViewerApi
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

public protocol ApiRequestSetting {
    static var hostname: String { get }
    static var basePath: String { get }
}
