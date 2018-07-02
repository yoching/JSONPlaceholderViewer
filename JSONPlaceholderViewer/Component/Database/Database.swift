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
typealias CommentFromApi = JSONPlaceholderApi.Comment
private typealias ContextPerformResult = Result<Void, ManagedObjectContextError>

typealias DataToPopulatePost = (user: UserFromApi, comments: [CommentFromApi])

protocol DatabaseManaging {
    var posts: Property<[PostProtocol]?> { get }

    func fetchPosts() -> SignalProducer<Void, DatabaseError>

    func savePosts(_ posts: [PostFromApi]) -> SignalProducer<Void, DatabaseError>

    func fetchUser(identifier: Int) -> SignalProducer<UserProtocol?, DatabaseError>

    func populatePost(_ post: PostProtocol, with dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError>
}

enum DatabaseError: Error {
    case context(ManagedObjectContextError)
    case notFetchedInitially
    case invalidUserDataPassed
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

        let fetchRelatedUsers = fetchUsers(identifiers: postsToSave.map { $0.identifier })
            .map { $0.keyedByIdentifier }

        return mutablePosts.producer
            .take(first: 1)
            .promoteError(DatabaseError.self)
            .attemptMap { posts -> Result<[Post], DatabaseError> in
                guard let posts = posts else {
                    return .failure(.notFetchedInitially)
                }
                return .success(posts)
            }
            .map { currentPosts -> [Int64: Post] in
                return Dictionary(uniqueKeysWithValues: currentPosts.map { ($0.identifier, $0) })
            }
            .zip(with: fetchRelatedUsers)
            .flatMap(.latest) { [weak self] currentPosts, relatedUsers -> SignalProducer<Void, DatabaseError> in

                guard let strongSelf = self else {
                    return .empty
                }

                let operation: (NSManagedObjectContext) -> Void = { context in

                    var mutableCurrentPosts = currentPosts
                    var mutableRelatedUsers = relatedUsers

                    for postFromApi in postsToSave {

                        let postId = Int64(postFromApi.identifier)
                        let userId = Int64(postFromApi.userIdentifier)

                        let postToConfigure: Post = mutableCurrentPosts.removeValue(forKey: postId)
                            ?? context.insertObject()

                        // user
                        let relatedUser: User
                        if let user = mutableRelatedUsers[userId] {
                            relatedUser = user
                        } else {
                            let newUser: User = context.insertObject()
                            newUser.configureMinimumInfo(identifier: userId)
                            mutableRelatedUsers[userId] = newUser
                            relatedUser = newUser
                        }

                        postToConfigure.configure(postFromApi: postFromApi, user: relatedUser)
                    }

                    for (_, postToDelete) in mutableCurrentPosts {
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

    func fetchUsers(identifiers: [Int]) -> SignalProducer<[User], DatabaseError> {
        let predicate = NSPredicate(format: "%K in %@", #keyPath(User.identifier), identifiers)
        return viewContext
            .fetchProducer(request: User.sortedFetchRequest(with: predicate))
            .mapError(DatabaseError.context)
    }

    func populatePost(_ post: PostProtocol, with dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError> {
            return SignalProducer<Void, DatabaseError> { observer, _ in
                guard post.userProtocol.identifier == dataFromApi.user.identifier else {
                    observer.send(error: .invalidUserDataPassed)
                    return
                }
                observer.send(value: ())
                observer.sendCompleted()
                }
                .flatMap(.latest) { [unowned self] _ -> SignalProducer<Void, DatabaseError> in
                    assert(post is Post)
                    let postEntity = post as! Post // swiftlint:disable:this force_cast (This is a logic error.)

                    let operation: (NSManagedObjectContext) -> Void = { context in
                        postEntity.user.populate(with: dataFromApi.user)
                    }

                    return self.viewContext
                        .performChangesProducer(block: operation)
                        .mapError(DatabaseError.context)
            }
    }
}

private extension Array where Element == User {
    var keyedByIdentifier: [Int64: Element] {
        return Dictionary(uniqueKeysWithValues: zip(self.map { $0.identifier }, self))
    }
}
