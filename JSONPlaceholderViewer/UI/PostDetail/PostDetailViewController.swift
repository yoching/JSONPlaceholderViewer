//
//  PostDetailViewController.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/25/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

final class PostDetailViewController: UIViewController, LoadingViewsContaining {

    // MARK: - View Elements
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!

    @IBOutlet weak var loadingErrorView: LoadingErrorView!
    @IBOutlet weak var loadingIndicatorView: LoadingIndicatorView!

    // MARK: - Properties
    private var viewModel: PostDetailViewModeling!

    // MARK: - Lifecycle Methods
    func configure(with viewModel: PostDetailViewModeling) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = viewModel.title
        bodyLabel.text = viewModel.body

        userNameLabel.reactive.text <~ viewModel.userName
        numberOfCommentsLabel.reactive.text <~ viewModel.numberOfComments

        configureLoadingViews(with: viewModel)

        self.reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:)))
            .observeValues { [weak self] _ in
                self?.viewModel.viewWillAppear()
        }
    }
}

// MARK: - Private Methods
private extension PostDetailViewController {
}
