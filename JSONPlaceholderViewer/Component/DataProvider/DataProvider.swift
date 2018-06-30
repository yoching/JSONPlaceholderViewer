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

protocol DataProviding {
    var posts: Property<[PostProtocol]?> { get }

    func fetchPosts() -> SignalProducer<Void, DataProviderError>

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DataProviderError>

    func populate(_ post: PostProtocol) -> SignalProducer<Void, DataProviderError>
}

enum DataProviderError: Error {
    case network(NetworkError)
    case database(DatabaseError)
}

final class DataProvider {

    let posts: Property<[PostProtocol]?>

    private let network: Networking
    private let database: DatabaseManaging

    init(network: Networking, database: DatabaseManaging) {
        self.network = network
        self.database = database
        self.posts = database.posts
    }
}

extension DataProvider: DataProviding {
    func fetchPosts() -> SignalProducer<Void, DataProviderError> {
        return database.posts
            .producer
            .flatMap(.latest) { [unowned self] posts -> SignalProducer<Void, DataProviderError> in
                if posts == nil {
                    return self.database
                        .fetchPosts()
                        .mapError(DataProviderError.database)
                }
                return .init(value: ())
            }
            .flatMap(.latest) { [unowned self] _ -> SignalProducer<PostsRequest.Response, DataProviderError> in
                return self.network
                    .getResponse(of: PostsRequest())
                    .mapError(DataProviderError.network)
            }
            .flatMap(.latest) { [unowned self] posts -> SignalProducer<Void, DataProviderError> in
                return self.database
                    .savePosts(posts)
                    .mapError(DataProviderError.database)
        }
    }

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DataProviderError> {
        return database.fetchUser(identifier: identifier)
            .mapError(DataProviderError.database)
    }

    func populate(_ post: PostProtocol) -> SignalProducer<Void, DataProviderError> {
        return network
            .getResponse(of: UserRequest(userIdentifier: Int(post.userProtocol.identifier)))
            .mapError(DataProviderError.network)
            .flatMap(.latest) { [unowned self] userFromApi -> SignalProducer<Void, DataProviderError> in
                return self.database.populatePost(post, with: userFromApi)
                    .mapError(DataProviderError.database)
        }
    }
}
