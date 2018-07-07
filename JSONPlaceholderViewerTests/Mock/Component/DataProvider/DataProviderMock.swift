//
//  DataProviderMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@testable import JSONPlaceholderViewer

final class DataProviderMock: DataProviding {
    var timesFetchPostsStarted: Int = 0
    var timesPopulatePostStarted: Int = 0

    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts)
    }
    let mutablePosts = MutableProperty<[PostProtocol]?>(nil)

    var fetchPostsShouldSucceed: Bool = true
    func fetchPosts() -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError> { observer, _ in
            self.timesFetchPostsStarted += 1

            if self.fetchPostsShouldSucceed {
                observer.send(value: ())
                observer.sendCompleted()
            } else {
                observer.send(error: .unknown)
            }
        }
    }

    var populatePost: ((PostProtocol) -> Void)?
    var populateShouldSucceed: Bool = true
    func populate(_ post: PostProtocol) -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError> { observer, _ in
            self.timesPopulatePostStarted += 1

            if self.populateShouldSucceed {
                self.populatePost?(post)
                observer.send(value: ())
                observer.sendCompleted()
            } else {
                observer.send(error: .database(.invalidUserDataPassed))
            }
        }
    }
}
