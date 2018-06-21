//
//  CoordinatorFactory.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

protocol CoordinatorFactory {
    func window() -> WindowCoordinator
    func home() -> HomeNavigationCoordinator
}

final class CoordinatorFactoryImpl {
    private let viewFactory: ViewFactory

    init(viewFactory: ViewFactory) {
        self.viewFactory = viewFactory
    }
}

// MARK: - CoordinatorFactory
extension CoordinatorFactoryImpl: CoordinatorFactory {
    func window() -> WindowCoordinator {
        return WindowCoordinator(rootCoordinator: home())
    }

    func home() -> HomeNavigationCoordinator {
        return HomeNavigationCoordinator(viewFactory: viewFactory)
    }
}
