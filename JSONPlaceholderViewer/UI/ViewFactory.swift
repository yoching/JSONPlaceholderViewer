//
//  ViewFactory.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

protocol ViewFactory {
    func root() -> UIViewController
    func posts() -> UIViewController
}

final class ViewFactoryImpl: ViewFactory {
    func root() -> UIViewController {
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .orange
        return rootViewController
    }

    func posts() -> UIViewController {
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .orange
        return rootViewController
    }
}
