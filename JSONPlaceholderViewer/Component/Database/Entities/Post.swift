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
    var userProtocol: UserProtocol { get } // TODO: think about name
    var commentArray: [CommentProtocol] { get }
}

final class Post: NSManagedObject, PostProtocol {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var body: String
    @NSManaged private(set) var title: String

    @NSManaged private(set) var comments: Set<Comment>
    @NSManaged private(set) var user: User

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

    func configure(postFromApi: JSONPlaceholderApi.Post, user: User) {
        self.identifier = Int64(postFromApi.identifier)
        self.body = postFromApi.body
        self.title = postFromApi.title
        self.comments = Set<Comment>()
        self.user = user
    }

    var userProtocol: UserProtocol {
        return user as UserProtocol
    }

    func add(_ comment: Comment) {
        comments.insert(comment)
    }

    func comment(identifiers: [Int]) -> [Int64: Comment] {
        let filteredComments = comments.filter { identifiers.contains(Int($0.identifier)) }

        var dictionary = [Int64: Comment]()
        for comment in filteredComments {
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
}
