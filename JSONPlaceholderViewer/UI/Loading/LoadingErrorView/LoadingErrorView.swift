//
//  LoadingErrorView.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/06/22.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

final class LoadingErrorView: UIView, XibInstantiatable {

    private var viewModel: LoadingErrorViewModeling?

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }

    func configure(with viewModel: LoadingErrorViewModeling) {
        self.viewModel = viewModel
        bind(viewModel)
    }

    private func bind(_ viewModel: LoadingErrorViewModeling) {
        errorMessage.reactive.text <~ viewModel.errorMessage

        retryButton.reactive.pressed = CocoaAction(viewModel.retry)
    }
}
