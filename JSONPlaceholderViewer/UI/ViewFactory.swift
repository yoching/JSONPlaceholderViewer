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
    func postDetail(of post: PostProtocol) -> (UIViewController, PostDetailViewRouting)
}

final class ViewFactoryImpl: ViewFactory {

    private let components: Components

    init(components: Components) {
        self.components = components
    }

    func posts() -> (UIViewController, PostsViewRouting) {
        let emptyDataViewModel = EmptyDataViewModel(
            image: nil,
            message: "Posts are empty",
            isImageHidden: true,
            isRetryButtonHidden: false
        )
        let loadingErrorViewModel = LoadingErrorViewModel(errorMessage: "error")
        let loadingIndicatorViewModel = LoadingIndicatorViewModel(loadingMessage: "loading")
        let viewModel = PostsViewModel(
            dataProvider: components.dataProvider,
            emptyDataViewModel: emptyDataViewModel,
            loadingErrorViewModel: loadingErrorViewModel,
            loadingIndicatorViewModel: loadingIndicatorViewModel
        )

        let viewController = StoryboardScene.PostsViewController.initialScene.instantiate()
        viewController.configure(with: viewModel)
        return (viewController, viewModel)
    }

    func postDetail(of post: PostProtocol) -> (UIViewController, PostDetailViewRouting) {
        let viewModel = PostDetailViewModel(
            of: post,
            dataProvider: components.dataProvider,
            loadingIndicatorViewModel: LoadingIndicatorViewModel(loadingMessage: "loading"),
            loadingErrorViewModel: LoadingErrorViewModel(errorMessage: "error")
        )

        let viewController = StoryboardScene.PostDetailViewController.initialScene.instantiate()
        viewController.configure(with: viewModel)
        return (viewController, viewModel)
    }
}
