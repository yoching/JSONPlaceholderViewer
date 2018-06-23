//
//  CoreDataStack.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import CoreData
import ReactiveSwift

protocol CoreDataStack: class {
    func setupStack() -> SignalProducer<Void, CoreDataStackError>
    var viewContext: NSManagedObjectContext { get }

    var persistentContainer: NSPersistentContainer { get }
}

extension CoreDataStack {
    func setupStack() -> SignalProducer<Void, CoreDataStackError> {
        return .init { [unowned self] (observer, _) in
            self.persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    observer.send(error: .load(error))
                    return
                }
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

enum CoreDataStackError: Error {
    case load(Error)
}

final class CoreDataStackImpl: CoreDataStack {
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "JSONPlaceholderViewer")
    }
}
