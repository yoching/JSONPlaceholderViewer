//
//  Components.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

protocol Components {
    var coreDataStack: CoreDataStack { get }
}

final class ComponentsImpl: Components {
    let coreDataStack: CoreDataStack

    init() {
        coreDataStack = CoreDataStackImpl()
    }
}
