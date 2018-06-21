//
//  WindowCoordinator.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

final class WindowCoordinator {
    let window: UIWindow
    private let rootCoordinator: ViewControllerCoordinator

    init(rootCoordinator: ViewControllerCoordinator) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.rootCoordinator = rootCoordinator
    }

    func start() {
        window.rootViewController = rootCoordinator.presenter
        window.makeKeyAndVisible()
        rootCoordinator.start()
    }
}
