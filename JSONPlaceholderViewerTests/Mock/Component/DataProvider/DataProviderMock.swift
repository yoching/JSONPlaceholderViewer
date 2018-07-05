//
//  DataProviderMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift

@testable import JSONPlaceholderViewer

final class DataProviderMock: DataProviding {
    var timesFetchPostsStarted: Int = 0
    var timesPopulatePostStarted: Int = 0

    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts)
    }
    let mutablePosts = MutableProperty<[PostProtocol]?>(nil)

    func fetchPosts() -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError>(value: ())
            .on(started: {
                self.timesFetchPostsStarted += 1
            })
    }

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DataProviderError> {
        return .init(value: nil)
    }

    var populatePost: ((PostProtocol) -> Void)?
    func populate(_ post: PostProtocol) -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError>(value: ())
            .on(started: {
                self.timesPopulatePostStarted += 1
            })
            .on(value: {
                self.populatePost?(post)
            })
    }
}
