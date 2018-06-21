//
//  CoordinatorProtocols.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

// MARK: - ViewControllerCoordinator
protocol ViewControllerCoordinator {
    var viewFactory: ViewFactory { get }
    var presenter: UIViewController { get }
    func start()
}

// MARK: - NavigationCoordinator
protocol NavigationCoordinator: ViewControllerCoordinator {
    var navigationController: UINavigationController { get }
}

extension NavigationCoordinator {
    var presenter: UIViewController {
        return navigationController as UIViewController
    }
}

// MARK: - TabCoordinator
protocol TabCoordinator: ViewControllerCoordinator {
    var tabBarController: UITabBarController { get }
}

extension TabCoordinator {
    var presenter: UIViewController {
        return tabBarController as UIViewController
    }
}
