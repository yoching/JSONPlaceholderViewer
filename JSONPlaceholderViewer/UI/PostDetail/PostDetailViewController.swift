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

final class PostDetailViewController: UIViewController {

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
        userNameLabel.reactive.text <~ viewModel.userName
        bodyLabel.reactive.text <~ viewModel.body
        numberOfCommentsLabel.reactive.text <~ viewModel.numberOfComments

        loadingErrorView.configure(with: viewModel.loadingErrorViewModel)
        loadingErrorView.reactive.isHidden <~ viewModel.isLoadingErrorHidden

        loadingIndicatorView.configure(with: viewModel.loadingIndicatorViewModel)
        loadingIndicatorView.reactive.isHidden <~ viewModel.isLoadingIndicatorHidden
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

// MARK: - Private Methods
private extension PostDetailViewController {
}
