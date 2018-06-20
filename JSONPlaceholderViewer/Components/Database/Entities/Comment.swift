//
//  Comment.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/20/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData

final class Comment: NSManagedObject {
    @NSManaged private(set) var identifier: Int64
    @NSManaged private(set) var body: String
    @NSManaged private(set) var name: String

    @NSManaged private(set) var post: Post?
}
