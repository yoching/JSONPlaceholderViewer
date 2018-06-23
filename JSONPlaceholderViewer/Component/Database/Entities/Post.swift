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

protocol PostProtocol {
}

final class Post: NSManagedObject, PostProtocol {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var body: String
    @NSManaged private(set) var title: String

    @NSManaged private(set) var comments: Set<Comment>
    @NSManaged private(set) var user: User?

    func configure(
        identifier: Int64,
        body: String,
        title: String,
        comments: Set<Comment>,
        user: User?
        ) {
        self.identifier = identifier
        self.body = body
        self.title = title
        self.comments = comments
        self.user = user
    }

    func configure(_ postFromApi: JSONPlaceholderApi.Post) {
        self.identifier = Int64(postFromApi.identifier)
        self.body = postFromApi.body
        self.title = postFromApi.title
        self.comments = Set<Comment>()
        self.user = nil
    }
}

extension Post: Managed {
    static let entityName: String = "Post"
}
