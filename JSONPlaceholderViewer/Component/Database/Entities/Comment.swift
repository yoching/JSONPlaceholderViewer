//
//  Comment.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/20/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData

protocol CommentProtocol: class, Hashable {

}

final class Comment: NSManagedObject, CommentProtocol {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var body: String
    @NSManaged private(set) var name: String

    @NSManaged private(set) var post: Post?

    func configure(commentFromApi: CommentFromApi) {
        self.identifier = Int64(commentFromApi.identifier)
        self.body = commentFromApi.body
        self.name = commentFromApi.name
    }
}

extension Comment: Managed {
    static let entityName: String = "Comment"
}
