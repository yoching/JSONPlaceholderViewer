//
//  AppDelegate.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dataController: CoreDataStack!
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {

        dataController = CoreDataStack {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let viewController = UIViewController()
            viewController.view.backgroundColor = .orange
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        }

        return true
    }
}
