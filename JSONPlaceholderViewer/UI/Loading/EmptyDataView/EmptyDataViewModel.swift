//
//  EmptyDataViewModel.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/09/30.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol EmptyDataViewModeling {
    // View States
    var image: UIImage? { get }
    var message: String { get }
    var isImageHidden: Bool { get }
    var isRetryButtonHidden: Bool { get }

    var retry: Action<Void, Void, NoError> { get }

    // Other Objects -> ViewModel
    func updateRetryButtonState(isEnabled: Bool)
}

final class EmptyDataViewModel {

    let image: UIImage?
    let message: String
    let isImageHidden: Bool
    let isRetryButtonHidden: Bool

    let retry: Action<Void, Void, NoError>

    private let mutableIsRetryButtonEnabled = MutableProperty<Bool>(true)

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

        retry = Action<Void, Void, NoError>(enabledIf: mutableIsRetryButtonEnabled) { _
            -> SignalProducer<Void, NoError> in
            return .init(value: ())
        }
    }
}

// MARK: - EmptyDataViewModeling
extension EmptyDataViewModel: EmptyDataViewModeling {
    func updateRetryButtonState(isEnabled: Bool) {
        mutableIsRetryButtonEnabled.value = isEnabled
    }
}
