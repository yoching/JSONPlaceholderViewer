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

    var appDependencies: AppDependencies?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {

        appDependencies = AppDependenciesImpl()
        appDependencies?.components.coreDataStack.setupStack {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = self.appDependencies?.viewFactory.root()
            self.window?.makeKeyAndVisible()
        }

        return true
    }
}
