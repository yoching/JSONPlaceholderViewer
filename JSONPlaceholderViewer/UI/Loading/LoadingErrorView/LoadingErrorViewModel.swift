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
    var isRetryButtonEnabled: Property<Bool> { get }

    // View -> ViewModel
    func retryTappedInput()

    // ViewModel -> Other Objects
    var retryTappedOutput: Signal<Void, NoError> { get }

    // Other Objects -> ViewModel
    func updateErrorMessage(to message: String)
    func updateRetryButtonState(isEnabled: Bool)
}

final class LoadingErrorViewModel {
    private let _errorMessage = MutableProperty<String>("")
    private let retryTappedPipe = Signal<Void, NoError>.pipe()
    private let mutableIsRetryButtonEnabled = MutableProperty<Bool>(true)

    init(errorMessage: String) {
        self._errorMessage.value = errorMessage
    }
}

// MARK: - LoadingErrorViewModeling
extension LoadingErrorViewModel: LoadingErrorViewModeling {
    var isRetryButtonEnabled: Property<Bool> {
        return Property(mutableIsRetryButtonEnabled)
    }
    var errorMessage: Property<String> {
        return Property(_errorMessage)
    }
    func retryTappedInput() {
        retryTappedPipe.input.send(value: ())
    }
    var retryTappedOutput: Signal<Void, NoError> {
        return retryTappedPipe.output
    }
    func updateErrorMessage(to message: String) {
        _errorMessage.value = message
    }
    func updateRetryButtonState(isEnabled: Bool) {
        mutableIsRetryButtonEnabled.value = isEnabled
    }
}
