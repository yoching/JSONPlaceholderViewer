//
//  AppDelegate.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/16/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var appDependencies: AppDependencies?

    private var windowCoordinator: WindowCoordinator?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {

        appDependencies = AppDependenciesImpl()

        windowCoordinator = appDependencies?.coordinatorFactory.window()
        window = windowCoordinator?.window

        appDependencies?.components.coreDataStack
            .setupStack()
            .observe(on: UIScheduler())
            .startWithResult { [unowned self] result in
                switch result {
                case .failure(let error):
                    fatalError("Failed to load Core Data stack: \(error)")
                case .success:
                    self.windowCoordinator?.start()
                }
        }

        return true
    }
}
