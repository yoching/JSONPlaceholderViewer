//
//  CoreDataStack.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/21/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import CoreData
import ReactiveSwift

protocol CoreDataStack {
    func setupStack() -> SignalProducer<Void, CoreDataStackError>
}

enum CoreDataStackError: Error {
    case load(Error)
}

final class CoreDataStackImpl {

    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "JSONPlaceholderViewer")
    }
}

// MARK: - CoreDataStack
extension CoreDataStackImpl: CoreDataStack {
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
}
