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

    func populatePost(_ post: PostProtocol, with dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError>
}

enum DatabaseError: Error {
    case context(ManagedObjectContextError)
    case notFetchedInitially
    case invalidUserDataPassed
    case invalidCommentsDataPassed
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
            .on(value: { [unowned self] posts in
                self.mutablePosts.value = posts
            })
            .map { _ in () }
            .mapError(DatabaseError.context)
    }

    func savePosts(_ postsToSave: [PostFromApi]) -> SignalProducer<Void, DatabaseError> {

        let fetchCachedPosts = mutablePosts.producer
            .take(first: 1)
            .promoteError(DatabaseError.self)
            .attemptMap { posts -> Result<[Post], DatabaseError> in
                guard let posts = posts else {
                    return .failure(.notFetchedInitially)
                }
                return .success(posts)
        }

        let fetchRelatedUsers = fetchUsers(identifiers: postsToSave.map { $0.identifier })

        return SignalProducer.zip(fetchCachedPosts, fetchRelatedUsers)
            .flatMap(.latest) { [unowned self] cachedPosts, cachedRelatedUsers -> SignalProducer<Void, DatabaseError> in
                return self.performChangesToPosts(
                    postsToSave: postsToSave,
                    cachedPosts: cachedPosts,
                    cachedRelatedUsers: cachedRelatedUsers
                )
            }
            .flatMap(.latest) { [unowned self] _ -> SignalProducer<Void, DatabaseError> in
                return self.fetchPosts()
        }
    }

    private func fetchUsers(identifiers: [Int]) -> SignalProducer<[User], DatabaseError> {
        let predicate = NSPredicate(format: "%K in %@", #keyPath(User.identifier), identifiers)
        return viewContext
            .fetchProducer(request: User.sortedFetchRequest(with: predicate))
            .mapError(DatabaseError.context)
    }

    private func performChangesToPosts(postsToSave: [PostFromApi], cachedPosts: [Post], cachedRelatedUsers: [User])
        -> SignalProducer<Void, DatabaseError> {

            func getPostToConfigure(
                identifier: Int64,
                cachedPosts: inout [Int64: Post],
                context: NSManagedObjectContext
                ) -> (postToConfigure: Post, isFromCache: Bool) {
                if let post = cachedPosts.removeValue(forKey: identifier) {
                    return (postToConfigure: post, isFromCache: true)
                } else {
                    return (postToConfigure: context.insertObject(), isFromCache: false)
                }
            }

            func getUser(
                identifier: Int64,
                cachedUsers: inout [Int64: User],
                context: NSManagedObjectContext
                ) -> User {
                if let user = cachedUsers[identifier] {
                    return user
                } else {
                    let newUser: User = context.insertObject()
                    newUser.configureMinimumInfo(identifier: identifier)
                    cachedUsers[identifier] = newUser
                    return newUser
                }
            }

            let operation: (NSManagedObjectContext) -> Void = { context in

                var mutableCachedPosts = cachedPosts.keyedByIdentifier
                var mutableCachedRelatedUsers = cachedRelatedUsers.keyedByIdentifier

                for postFromApi in postsToSave {

                    let relatedUser: User = getUser(
                        identifier: Int64(postFromApi.userIdentifier),
                        cachedUsers: &mutableCachedRelatedUsers,
                        context: context
                    )

                    let (postToConfigure, isFromCache) = getPostToConfigure(
                        identifier: Int64(postFromApi.identifier),
                        cachedPosts: &mutableCachedPosts,
                        context: context
                    )

                    postToConfigure.configure(
                        postFromApi: postFromApi,
                        user: relatedUser,
                        isInitial: !isFromCache
                    )
                }

                mutableCachedPosts.values.forEach(context.delete)
            }

            return viewContext.performChangesProducer(block: operation).mapError(DatabaseError.context)
    }

    func populatePost(_ post: PostProtocol, with dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError> {
            return validateIdentity(post: post, dataFromApi: dataFromApi)
                .flatMap(.latest) { [unowned self] _ -> SignalProducer<Void, DatabaseError> in
                    assert(post is Post)
                    let postEntity = post as! Post // swiftlint:disable:this force_cast (This is a logic error.)

                    let operation: (NSManagedObjectContext) -> Void = { context in

                        // user
                        postEntity.user.populate(with: dataFromApi.user)

                        // comments
                        var alreadyRelatedComments = postEntity.commentsKeyedByIdentifier

                        for commentFromApi in dataFromApi.comments {
                            let commentId = Int64(commentFromApi.identifier)
                            if let comment = alreadyRelatedComments.removeValue(forKey: commentId) {
                                comment.configure(commentFromApi: commentFromApi)
                            } else {
                                let comment: Comment = context.insertObject()
                                comment.configure(commentFromApi: commentFromApi)
                                postEntity.add(comment)
                            }
                        }

                        alreadyRelatedComments.values.forEach(context.delete)

                        // post
                        postEntity.isPopulated = true
                    }

                    return self.viewContext
                        .performChangesProducer(block: operation)
                        .mapError(DatabaseError.context)
            }
    }

    private func validateIdentity(post: PostProtocol, dataFromApi: DataToPopulatePost)
        -> SignalProducer<Void, DatabaseError> {
            return SignalProducer<Void, DatabaseError> { observer, _ in
                guard post.userProtocol.identifier == dataFromApi.user.identifier else {
                    observer.send(error: .invalidUserDataPassed)
                    return
                }

                let postIdentifiersInComments = Set<Int>(dataFromApi.comments.map { $0.postIdentifier })
                guard postIdentifiersInComments.count == 1,
                    postIdentifiersInComments.first! == Int(post.identifier) else {
                        observer.send(error: .invalidCommentsDataPassed)
                        return
                }

                observer.send(value: ())
                observer.sendCompleted()
            }
    }
}

private extension Array where Element == User {
    var keyedByIdentifier: [Int64: Element] {
        return Dictionary(uniqueKeysWithValues: zip(self.map { $0.identifier }, self))
    }
}

private extension Array where Element == Post {
    var keyedByIdentifier: [Int64: Element] {
        return Dictionary(uniqueKeysWithValues: zip(self.map { $0.identifier }, self))
    }
}
