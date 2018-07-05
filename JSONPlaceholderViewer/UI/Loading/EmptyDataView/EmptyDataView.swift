//
//  EmptyDataView.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/06/22.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

final class EmptyDataView: UIView, XibInstantiatable {

    private var viewModel: EmptyDataViewModeling?

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    @IBAction func retryButtonTapped(_ sender: UIButton) {
        viewModel?.retryTappedInput()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }

    func configure(with viewModel: EmptyDataViewModeling) {
        self.viewModel = viewModel
        bind(viewModel)
    }

    private func bind(_ viewModel: EmptyDataViewModeling) {
        iconImageView.image = viewModel.image
        messageLabel.text = viewModel.message
        iconImageView.isHidden = viewModel.isImageHidden
        retryButton.isHidden = viewModel.isRetryButtonHidden
    }
}
