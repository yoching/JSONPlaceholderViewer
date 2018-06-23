//
//  ResultWrappedObservable.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

extension SignalProducer {
    func resultWrapped() -> SignalProducer<Result<Value, Error>, NoError> {
        return self
            .map { value -> Result<Value, Error> in
                return .success(value)
            }
            .flatMapError { error -> SignalProducer<Result<Value, Error>, NoError> in
                return .init(value: .failure(error))
        }
    }
}
