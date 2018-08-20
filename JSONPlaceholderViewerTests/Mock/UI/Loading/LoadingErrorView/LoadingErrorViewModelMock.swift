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

    let mutableErrorMessage = MutableProperty<String>("")
    var errorMessage: Property<String> {
        return Property(mutableErrorMessage)
    }

    let retry = Action<Void, Void, NoError> { _ -> SignalProducer<Void, NoError> in
        return .init(value: ())
    }

    var timesUpdateErrorMessageCalled = 0
    func updateErrorMessage(to message: String) {
        timesUpdateErrorMessageCalled += 1
    }
    func updateRetryButtonState(isEnabled: Bool) {
    }
}
