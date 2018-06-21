//
//  AppDependencies.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

protocol AppDependencies {
    var components: Components { get }

    var viewFactory: ViewFactory { get }
}

final class AppDependenciesImpl: AppDependencies {
    let components: Components

    let viewFactory: ViewFactory

    init() {
        components = ComponentsImpl()
        viewFactory = ViewFactoryImpl()
    }
}
