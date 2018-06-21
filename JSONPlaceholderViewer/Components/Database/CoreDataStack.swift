//
//  CoreDataStack.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import CoreData

final class CoreDataStack {

    private let persistentContainer: NSPersistentContainer

    init(completion: @escaping () -> Void) {
        persistentContainer = NSPersistentContainer(name: "JSONPlaceholderViewer")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
