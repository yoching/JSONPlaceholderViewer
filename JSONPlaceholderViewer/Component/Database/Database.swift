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

protocol DatabaseManaging {
    var posts: Property<[PostProtocol]> { get }

    func fetchPosts()
}

final class Database {
    private let mutablePosts = MutableProperty<[PostProtocol]>([])

    private let fetchPostsPipe = Signal<Void, NoError>.pipe()

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
        fetchPostsPipe.output
            .flatMap(.latest) { [weak self] _ -> SignalProducer<Result<[Post], AnyError>, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }
                return strongSelf.stack.viewContext
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
    }
}

extension Database: DatabaseManaging {
    var posts: Property<[PostProtocol]> {
        return Property(mutablePosts)
    }

    func fetchPosts() {
        fetchPostsPipe.input.send(value: ())
    }
}
