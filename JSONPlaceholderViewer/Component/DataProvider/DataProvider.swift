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
    var posts: Property<[PostProtocol]?> { get }

    func fetchPosts()
}

final class DataProvider {

    let posts: Property<[PostProtocol]?>

    private let network: Networking
    private let database: DatabaseManaging

    private let fetchPostsPipe = Signal<Void, NoError>.pipe()

    init(network: Networking, database: DatabaseManaging) {
        self.network = network
        self.database = database
        self.posts = database.posts

        database.posts
            .producer
            .sample(on: fetchPostsPipe.output.producer)
            .flatMap(.latest) { [unowned self] posts -> SignalProducer<Void, NoError> in
                if posts == nil {
                    return self.database
                        .fetchPosts()
                        .flatMapError { _ -> SignalProducer<Void, NoError> in
                            return .init(value: ()) // TODO: handle error
                    }
                }
                return .init(value: ())
            }
            .flatMap(.latest) { [unowned self] _ -> SignalProducer<PostsFetchResult, NoError> in
                return self.network
                    .getResponse(of: PostsRequest())
                    .resultWrapped()
            }
            .flatMap(.latest) { [unowned self] result -> SignalProducer<Result<Void, DatabaseError>, NoError> in
                switch result {
                case .success(let posts):
                    return self.database.savePosts(posts)
                        .resultWrapped()
                case .failure:
                    return .init(value: .success(()))
                    // TODO: handle error
                }
            }
            .start()

    }
}

extension DataProvider: DataProviding {
    func fetchPosts() {
        fetchPostsPipe.input.send(value: ())
    }
}
