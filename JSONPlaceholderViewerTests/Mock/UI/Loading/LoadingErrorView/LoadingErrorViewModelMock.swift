//
//  LoadingErrorViewModelMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@testable import JSONPlaceholderViewer

final class LoadingErrorViewModelMock: LoadingErrorViewModeling {

    var errorMessage: Property<String> {
        return Property(mutableErrorMessage)
    }
    var isRetryButtonEnabled: Property<Bool> {
        return Property(mutableIsRetryButtonEnabled)
    }

    let mutableErrorMessage = MutableProperty<String>("")
    let mutableIsRetryButtonEnabled = MutableProperty<Bool>(true)

    func retryTappedInput() {

    }

    var retryTappedOutput: Signal<Void, NoError> {
        return retryTappedPipe.output
    }

    var retryTappedPipe = Signal<Void, NoError>.pipe()

    var timesUpdateErrorMessageCalled = 0
    func updateErrorMessage(to message: String) {
        timesUpdateErrorMessageCalled += 1
    }
    func updateRetryButtonState(isEnabled: Bool) {
    }
}
