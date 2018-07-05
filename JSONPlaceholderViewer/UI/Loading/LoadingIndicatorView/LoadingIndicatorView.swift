//
//  LoadingIndicatorView.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/06/22.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit

final class LoadingIndicatorView: UIView, XibInstantiatable {
    private var viewModel: LoadingIndicatorViewModeling?
    @IBOutlet weak var loadingMessageLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }

    func configure(with viewModel: LoadingIndicatorViewModeling) {
        self.viewModel = viewModel
        bind(viewModel)
    }

    private func bind(_ viewModel: LoadingIndicatorViewModeling) {
        loadingMessageLabel.text = viewModel.loadingMessage
        loadingMessageLabel.isHidden = viewModel.loadingMessage.isEmpty
    }
}
