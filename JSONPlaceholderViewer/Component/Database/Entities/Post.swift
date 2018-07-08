//
//  Post.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/20/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData
import JSONPlaceholderApi

protocol PostProtocol: class {
    var identifier: Int64 { get }
    var body: String { get }
    var title: String { get }
    var userProtocol: UserProtocol { get }
    var commentArray: [CommentProtocol] { get }
    var isPopulated: Bool { get }
}

final class Post: NSManagedObject, PostProtocol {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var body: String
    @NSManaged private(set) var title: String

    @NSManaged private(set) var comments: Set<Comment>
    @NSManaged private(set) var user: User
    @NSManaged var isPopulated: Bool

    func configure(
        identifier: Int64,
        body: String,
        title: String,
        comments: Set<Comment>,
        user: User
        ) {
        self.identifier = identifier
        self.body = body
        self.title = title
        self.comments = comments
        self.user = user
    }

    func configure(postFromApi: JSONPlaceholderApi.Post, user: User, isInitial: Bool) {
        self.identifier = Int64(postFromApi.identifier)
        self.body = postFromApi.body
        self.title = postFromApi.title
        self.user = user

        if isInitial {
            self.comments = Set<Comment>()
        }
    }

    var userProtocol: UserProtocol {
        return user as UserProtocol
    }

    func add(_ comment: Comment) {
        comments.insert(comment)
    }

    var commentsKeyedByIdentifier: [Int64: Comment] {
        var dictionary = [Int64: Comment]()
        for comment in comments {
            dictionary[comment.identifier] = comment
        }
        return dictionary
    }

    // converting to array because Set<CommentProtocol> cannot be created
    var commentArray: [CommentProtocol] {
        return Array(comments)
    }
}

extension Post: Managed {
    static let entityName: String = "Post"
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(identifier), ascending: true)]
    }
}
