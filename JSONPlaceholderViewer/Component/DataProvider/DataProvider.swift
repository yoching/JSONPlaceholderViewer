//
//  DataProvider.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import JSONPlaceholderApi
import ReactiveSwift
import Result

private typealias PostsFetchResult = Result<[JSONPlaceholderApi.Post], NetworkError>

protocol DataProviding {
    var posts: Property<[PostProtocol]> { get }
    func fetchPosts()
}

final class DataProvider {

    let posts: Property<[PostProtocol]>

    private let network: Networking

    private let fetchPostsPipe = Signal<Void, NoError>.pipe()

    init(network: Networking, database: DatabaseManaging) {
        self.network = network
        self.posts = database.posts

        fetchPostsPipe.output
            .flatMap(.latest) { [weak self] _ -> SignalProducer<PostsFetchResult, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }
                return strongSelf.network.getResponse(of: PostsRequest()).resultWrapped()
            }
            .observeValues { _ in
                // do something
        }
    }
}

extension DataProvider: DataProviding {
    func fetchPosts() {
        fetchPostsPipe.input.send(value: ())
    }
}
