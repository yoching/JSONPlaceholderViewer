//
//  Components.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import JSONPlaceholderApi

protocol Components {
    var network: Networking { get }
    var coreDataStack: CoreDataStack { get }
}

final class ComponentsImpl: Components {
    let network: Networking
    let coreDataStack: CoreDataStack

    init() {
        network = Network(apiClient: ApiClient())
        coreDataStack = CoreDataStackImpl()
    }
}
