//
//  CoreDataStack.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import CoreData

protocol CoreDataStack {
    func setupStack(completion: @escaping () -> Void)
}

final class CoreDataStackImpl {

    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "JSONPlaceholderViewer")
    }
}

// MARK: - CoreDataStack
extension CoreDataStackImpl: CoreDataStack {
    func setupStack(completion: @escaping () -> Void) {
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
