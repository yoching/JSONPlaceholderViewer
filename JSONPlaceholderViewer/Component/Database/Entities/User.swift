//
//  User.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/20/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData

final class User: NSManagedObject {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var name: String
    @NSManaged private(set) var userName: String

    @NSManaged private(set) var posts: Set<Post>
}
