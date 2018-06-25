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
    // MARK: - Infrastructure
    var network: Networking { get }
    var coreDataStack: CoreDataStack { get }
    var database: DatabaseManaging { get }

    // MARK: - Service
    var dataProvider: DataProviding { get }
}

final class ComponentsImpl: Components {
    // MARK: - Infrastructure
    let network: Networking
    let coreDataStack: CoreDataStack
    let database: DatabaseManaging

    // MARK: - Service
    let dataProvider: DataProviding

    init() {
        network = Network(apiClient: ApiClient())
        coreDataStack = CoreDataStackImpl()
        database = Database(coreDataStack: coreDataStack)

        dataProvider = DataProvider(network: network, database: database)
    }
}
