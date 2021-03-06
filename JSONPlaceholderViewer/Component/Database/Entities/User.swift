//
//  User.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/20/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData

protocol UserProtocol: class {
    var identifier: Int64 { get }
    var name: String? { get }
}

final class User: NSManagedObject, UserProtocol {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var name: String?
    @NSManaged private(set) var userName: String?

    @NSManaged private(set) var posts: Set<Post>

    func configure(
        identifier: Int64,
        name: String,
        userName: String,
        posts: Set<Post>
        ) {
        self.identifier = identifier
        self.name = name
        self.userName = userName
        self.posts = posts
    }

    func populate(with userFromApi: UserFromApi) {
        self.name = userFromApi.name
        self.userName = userFromApi.userName
    }

    func configureMinimumInfo(identifier: Int64) {
        self.identifier = identifier
        self.posts = Set<Post>()
    }
}

extension User: Managed {
    static let entityName: String = "User"
}
