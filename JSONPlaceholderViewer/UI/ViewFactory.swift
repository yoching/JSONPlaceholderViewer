//
//  ViewFactory.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

protocol ViewFactory {
    func posts() -> (UIViewController, PostsViewRouting)
    func postDetail() -> (UIViewController, PostDetailViewRouting)
}

final class ViewFactoryImpl: ViewFactory {

    private let components: Components

    init(components: Components) {
        self.components = components
    }

    func posts() -> (UIViewController, PostsViewRouting) {
        let viewController = StoryboardScene.PostsViewController.initialScene.instantiate()
        let viewModel = PostsViewModel(dataProvider: components.dataProvider)
        viewController.configure(with: viewModel)
        return (viewController, viewModel)
    }

    func postDetail() -> (UIViewController, PostDetailViewRouting) {
        let viewController = StoryboardScene.PostDetailViewController.initialScene.instantiate()
        let viewModel = PostDetailViewModel()
        viewController.configure(with: viewModel)
        return (viewController, viewModel)
    }
}
