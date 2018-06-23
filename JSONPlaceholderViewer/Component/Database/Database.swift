//
//  Database.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import CoreData
import JSONPlaceholderApi

typealias PostFromApi = JSONPlaceholderApi.Post

protocol DatabaseManaging {
    var posts: Property<[PostProtocol]> { get }

    func fetchPosts()

    func savePosts(_ posts: [PostFromApi])
}

final class Database {
    private let mutablePosts = MutableProperty<[PostProtocol]>([])

    private let fetchPostsPipe = Signal<Void, NoError>.pipe()
    private let savePostsPipe = Signal<[PostFromApi], NoError>.pipe()

    private let stack: CoreDataStack

    private var viewContext: NSManagedObjectContext {
        return stack.viewContext
    }

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
        fetchPostsPipe.output
            .flatMap(.latest) { [weak self] _ -> SignalProducer<Result<[Post], ManagedObjectContextError>, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }
                return strongSelf.viewContext
                    .fetchProducer(request: Post.sortedFetchRequest)
                    .resultWrapped()
            }
            .observeValues { [weak self] result in
                switch result {
                case .success(let posts):
                    self?.mutablePosts.value = posts
                case .failure:
                    break // TODO: do something
                }
        }

        savePostsPipe.output
            .flatMap(.latest) { [weak self] posts -> SignalProducer<Result<Void, ManagedObjectContextError>, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }

                let insertOperation: (NSManagedObjectContext) -> Void = { context in
                    for postFromApi in posts {
                        let post: Post = context.insertObject()
                        post.configure(postFromApi)
                    }
                }

                return strongSelf.viewContext
                    .performChangesProducer(block: insertOperation)
                    .resultWrapped()
            }
            .observeValues { [weak self] _ in
                // TODO: do something?
        }

    }
}

extension Database: DatabaseManaging {
    var posts: Property<[PostProtocol]> {
        return Property(mutablePosts)
    }

    func fetchPosts() {
        fetchPostsPipe.input.send(value: ())
    }

    func savePosts(_ posts: [PostFromApi]) {
        savePostsPipe.input.send(value: posts)
    }
}
