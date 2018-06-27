//
//  CoreDataStackMock.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

@testable import JSONPlaceholderViewer

final class CoreDataStackMock: CoreDataStack {

    let persistentContainer: NSPersistentContainer

    init() {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        persistentContainer = NSPersistentContainer(name: "JSONPlaceholderViewer")
        persistentContainer.persistentStoreDescriptions = [description]
    }

    func addPost(identifier: Int64) {
        let post: Post = viewContext.insertObject()

        post.configure(
            identifier: identifier,
            body: "",
            title: "",
            comments: Set<Comment>(),
            user: nil
        )

        try! viewContext.save() // swiftlint:disable:this force_try
    }
}
