//
//  LoadingErrorViewModel.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/06/22.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol LoadingErrorViewModeling {
    // View States
    var errorMessage: Property<String> { get }

    var retry: Action<Void, Void, NoError> { get }

    // Other Objects -> ViewModel
    func updateErrorMessage(to message: String)
    func updateRetryButtonState(isEnabled: Bool)
}

final class LoadingErrorViewModel {
    private let _errorMessage = MutableProperty<String>("")
    private let retryTappedPipe = Signal<Void, NoError>.pipe()
    private let mutableIsRetryButtonEnabled = MutableProperty<Bool>(true)

    let retry: Action<Void, Void, NoError>

    init(errorMessage: String) {
        self._errorMessage.value = errorMessage

        retry = Action<Void, Void, NoError>(enabledIf: mutableIsRetryButtonEnabled) { _
            -> SignalProducer<Void, NoError> in
            return .init(value: ())
        }
    }
}

// MARK: - LoadingErrorViewModeling
extension LoadingErrorViewModel: LoadingErrorViewModeling {
    var errorMessage: Property<String> {
        return Property(_errorMessage)
    }
    func updateErrorMessage(to message: String) {
        _errorMessage.value = message
    }
    func updateRetryButtonState(isEnabled: Bool) {
        mutableIsRetryButtonEnabled.value = isEnabled
    }
}
