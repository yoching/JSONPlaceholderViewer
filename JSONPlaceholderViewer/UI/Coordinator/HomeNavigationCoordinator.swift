//
//  HomeNavigationCoordinator.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit
import ReactiveSwift

final class HomeNavigationCoordinator: NavigationCoordinator {
    let viewFactory: ViewFactory
    let navigationController: UINavigationController

    init(viewFactory: ViewFactory) {
        self.viewFactory = viewFactory
        navigationController = UINavigationController()
        navigationController.title = "Home"
    }

    func start() {
        let (postsViewController, postsViewRouting) = viewFactory.posts()
        postsViewRouting.routeSelected
            .observeValues { [weak self] route in
                switch route {
                case .postDetail(let post):
                    self?.presentPostDetail(of: post)
                }
        }

        navigationController.pushViewController(
            postsViewController,
            animated: false
        )
    }
}

// MARK: - Private Methods
private extension HomeNavigationCoordinator {
    func presentPostDetail(of post: PostProtocol) {
        let (viewController, routing) = viewFactory.postDetail(of: post)
        routing.routeSelected
            .observeValues { [weak self] route in
                switch route {
                case .pop:
                    self?.navigationController.popViewController(animated: true)
                }
        }

        navigationController.pushViewController(
            viewController,
            animated: true
        )
    }
}
