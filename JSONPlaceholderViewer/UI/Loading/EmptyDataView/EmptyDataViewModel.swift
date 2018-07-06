//
//  EmptyDataViewModel.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/09/30.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

protocol EmptyDataViewModeling {

    var image: UIImage? { get }
    var message: String { get }
    var isImageHidden: Bool { get }
    var isRetryButtonHidden: Bool { get }

    func retryTappedInput()

    var retryTappedOutput: Signal<Void, NoError> { get }
}

final class EmptyDataViewModel {

    let image: UIImage?
    let message: String
    let isImageHidden: Bool
    let isRetryButtonHidden: Bool

    private let retryTappedPipe = Signal<Void, NoError>.pipe()

    init(
        image: UIImage?,
        message: String,
        isImageHidden: Bool,
        isRetryButtonHidden: Bool = true
        ) {
        self.image = image
        self.message = message
        self.isImageHidden = isImageHidden
        self.isRetryButtonHidden = isRetryButtonHidden
    }
}

// MARK: - EmptyDataViewModeling
extension EmptyDataViewModel: EmptyDataViewModeling {
    func retryTappedInput() {
        retryTappedPipe.input.send(value: ())
    }
    var retryTappedOutput: Signal<Void, NoError> {
        return retryTappedPipe.output
    }
}
