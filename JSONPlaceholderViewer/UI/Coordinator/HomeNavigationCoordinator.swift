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
                case .postDetail(let postIdentifier):
                    self?.presentPostDetail(postIdentifier: postIdentifier)
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
    func presentPostDetail(postIdentifier: Int64) {
        print("😆, \(postIdentifier)")
    }
}
