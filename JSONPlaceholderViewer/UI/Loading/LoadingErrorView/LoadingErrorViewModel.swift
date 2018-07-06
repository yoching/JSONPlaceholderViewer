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
    var errorMessage: Property<String> { get }

    func retryTappedInput()

    var retryTappedOutput: Signal<Void, NoError> { get }

    func updateErrorMessage(to message: String)
}

final class LoadingErrorViewModel {
    private let _errorMessage = MutableProperty<String>("")
    private let retryTappedPipe = Signal<Void, NoError>.pipe()

    init(errorMessage: String) {
        self._errorMessage.value = errorMessage
    }
}

// MARK: - LoadingErrorViewModeling
extension LoadingErrorViewModel: LoadingErrorViewModeling {
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
}
