//
//  HomeNavigationCoordinator.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

final class HomeNavigationCoordinator: NavigationCoordinator {
    let viewFactory: ViewFactory
    let navigationController: UINavigationController

    init(viewFactory: ViewFactory) {
        self.viewFactory = viewFactory
        navigationController = UINavigationController()
        navigationController.title = "Home"
    }

    func start() {
        let postsViewController = viewFactory.posts()
        navigationController.pushViewController(
            postsViewController,
            animated: false
        )
    }
}
