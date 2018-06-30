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
typealias UserFromApi = JSONPlaceholderApi.User
private typealias ContextPerformResult = Result<Void, ManagedObjectContextError>

protocol DatabaseManaging {
    var posts: Property<[PostProtocol]?> { get }

    func fetchPosts() -> SignalProducer<Void, DatabaseError>

    func savePosts(_ posts: [PostFromApi]) -> SignalProducer<Void, DatabaseError>

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DatabaseError>

    func populatePost(_ post: PostProtocol, with userFromApi: UserFromApi) -> SignalProducer<Void, DatabaseError>
}

enum DatabaseError: Error {
    case context(ManagedObjectContextError)
    case notFetchedInitially
}

final class Database {
    private let mutablePosts = MutableProperty<[Post]?>(nil)

    private let stack: CoreDataStack

    private var viewContext: NSManagedObjectContext {
        return stack.viewContext
    }

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }
}

extension Database: DatabaseManaging {
    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts.map { $0 })
    }

    func fetchPosts() -> SignalProducer<Void, DatabaseError> {
        return viewContext
            .fetchProducer(request: Post.sortedFetchRequest)
            .on(value: { [weak self] posts in
                self?.mutablePosts.value = posts
            })
            .map { _ in () }
            .mapError(DatabaseError.context)
    }

    func savePosts(_ postsToSave: [PostFromApi]) -> SignalProducer<Void, DatabaseError> {
        return mutablePosts.producer
            .promoteError(DatabaseError.self)
            .attemptMap { posts -> Result<[Post], DatabaseError> in
                guard let posts = posts else {
                    return .failure(.notFetchedInitially)
                }
                return .success(posts)
            }
            .flatMap(.latest) { [weak self] currentPosts
                -> SignalProducer<Void, DatabaseError> in

                guard let strongSelf = self else {
                    return .empty
                }

                var currentPostsDictionary = Dictionary(
                    uniqueKeysWithValues: currentPosts.map { ($0.identifier, $0) }
                )

                let operation: (NSManagedObjectContext) -> Void = { context in
                    for post in postsToSave {
                        let removedValue = currentPostsDictionary.removeValue(forKey: Int64(post.identifier))
                        let postToSave = removedValue ?? context.insertObject()
                        postToSave.configure(post)
                    }

                    for (_, postToDelete) in currentPostsDictionary {
                        context.delete(postToDelete)
                    }
                }

                return strongSelf.viewContext
                    .performChangesProducer(block: operation)
                    .mapError(DatabaseError.context)
        }
    }

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DatabaseError> {
        let predicate = NSPredicate(format: "%K == %ld", #keyPath(User.identifier), Int64(identifier))
        return viewContext
            .fetchSingleProducer(request: User.sortedFetchRequest(with: predicate))
            .map { $0 }
            .mapError(DatabaseError.context)
    }

    func fetchUser2(identifier: Int) -> SignalProducer<User?, DatabaseError> {
        let predicate = NSPredicate(format: "%K == %ld", #keyPath(User.identifier), Int64(identifier))
        return viewContext
            .fetchSingleProducer(request: User.sortedFetchRequest(with: predicate))
            .mapError(DatabaseError.context)
    }

    func populatePost(_ post: PostProtocol, with userFromApi: UserFromApi) -> SignalProducer<Void, DatabaseError> {
        assert(post is Post)
        return fetchUser2(identifier: userFromApi.identifier)
            .flatMap(.latest) { [unowned self] user -> SignalProducer<Void, DatabaseError> in
                let operation: (NSManagedObjectContext) -> Void = { context in
                    let userToUpdate: User = user ?? context.insertObject()
                    userToUpdate.configure(userFromApi)
                    (post as! Post).addUser(userToUpdate) // swiftlint:disable:this force_cast (logic error)
                }
                return self.viewContext
                    .performChangesProducer(block: operation)
                    .mapError(DatabaseError.context)
        }
    }
}
