//
//  PostDetailViewController.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/25/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

final class PostDetailViewController: UIViewController {

    // MARK: - View Elements

    // MARK: - Properties
    private var viewModel: PostDetailViewModeling!

    // MARK: - Lifecycle Methods
    func configure(with viewModel: PostDetailViewModeling) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - Private Methods
private extension PostDetailViewController {
}
