//
//  DatabaseMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift

@testable import JSONPlaceholderViewer

final class DatabaseMock: DatabaseManaging {
    var timesSavePostsCalled: Int = 0
    var timesFetchPostsCalled: Int = 0
    var timesFetchUserCalled: Int = 0

    var parametersPassedToPopulatePost: [(post: PostProtocol, dataFromApi: DataToPopulatePost)] = []

    var mutablePosts = MutableProperty<[PostProtocol]?>(nil)
    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts)
    }

    func fetchPosts() -> SignalProducer<Void, DatabaseError> {
        return SignalProducer<Void, DatabaseError>(value: ())
            .on(started: {
                self.timesFetchPostsCalled += 1
            })
    }

    func savePosts(_ posts: [PostFromApi]) -> SignalProducer<Void, DatabaseError> {
        return SignalProducer<Void, DatabaseError>(value: ())
            .on(started: {
                self.timesSavePostsCalled += 1
            })
    }

    func populatePost(_ post: PostProtocol, with dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError> {
            return SignalProducer<Void, DatabaseError>(value: ())
                .on(started: {
                    self.parametersPassedToPopulatePost.append((post: post, dataFromApi: dataFromApi))
                })
    }
}
