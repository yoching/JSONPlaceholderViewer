//
//  PostsViewController.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import ReactiveCocoa

final class PostsViewController: UIViewController, LoadingAndEmptyViewsContaining {

    // MARK: - View Elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataView: EmptyDataView!
    @IBOutlet weak var loadingErrorView: LoadingErrorView!
    @IBOutlet weak var loadingIndicatorView: LoadingIndicatorView!
    private var refreshControl = UIRefreshControl()

    // MARK: - Properties
    private var viewModel: PostsViewModeling!

    // MARK: - Lifecycle Methods
    func configure(with viewModel: PostsViewModeling) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()

        tableView.reactive.reloadData <~ viewModel.cellModels.signal.map { _ in () }
        viewModel
            .shouldStopRefreshControl
            .signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.refreshControl.endRefreshing()
        }

        configureLoadingAndEmptyViews(with: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

// MARK: - Private Methods
private extension PostsViewController {
    func configureTableView() {
        tableView.registerNibForCellWithType(PostCell.self)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(
            self,
            action: #selector(refresh(sender:)),
            for: .valueChanged
        )
    }

    @objc func refresh(sender: UIRefreshControl) {
        viewModel.pullToRefreshTriggered()
    }
}

// MARK: - UITableViewDataSource
extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellModels.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithType(PostCell.self, forIndexPath: indexPath)
        cell.configure(with: viewModel.cellModels.value[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(index: indexPath.row)
    }
}
