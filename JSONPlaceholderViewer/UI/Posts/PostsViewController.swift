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

final class PostsViewController: UIViewController {

    // MARK: - View Elements
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    private var viewModel: PostsViewModeling!

    // MARK: - Lifecycle Methods
    func configure(with viewModel: PostsViewModeling) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
}

// MARK: - Private Methods
private extension PostsViewController {
    func configureTableView() {
        tableView.registerNibForCellWithType(PostCell.self)
        tableView.dataSource = self
        tableView.delegate = self
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
