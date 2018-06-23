//
//  Database.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol DatabaseManaging {
    var posts: Property<[PostProtocol]> { get }
}

final class Database {
    private let mutablePosts = MutableProperty<[PostProtocol]>([])
}

extension Database: DatabaseManaging {
    var posts: Property<[PostProtocol]> {
        return Property(mutablePosts)
    }
}
