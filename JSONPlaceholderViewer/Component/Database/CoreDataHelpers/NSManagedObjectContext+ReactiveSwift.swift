//
//  NSManagedObjectContext+ReactiveSwift.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift
import Result

enum ManagedObjectContextError: Error {
    case general(Error)
    case unknown
}

extension NSManagedObjectContext {
    func fetchProducer<Entity>(request: NSFetchRequest<Entity>) -> SignalProducer<[Entity], ManagedObjectContextError> {
        return .init { observer, _ in
            do {
                let entities = try self.fetch(request)
                observer.send(value: entities)
                observer.sendCompleted()
            } catch {
                observer.send(error: .general(error))
            }
        }
    }

    func fetchSingleProducer<Entity>(request: NSFetchRequest<Entity>) -> SignalProducer<Entity?, ManagedObjectContextError> {
        return .init { observer, _ in
            do {
                let entities = try self.fetch(request)
                guard entities.count <= 1 else {
                    observer.send(error: .unknown)
                    return
                }
                observer.send(value: entities.first)
                observer.sendCompleted()
            } catch {
                observer.send(error: .general(error))
            }
        }
    }

    func performProducer(block: @escaping (_ context: NSManagedObjectContext) -> Void)
        -> SignalProducer<Void, NoError> {
            return .init { observer, _ in
                self.perform {
                    block(self)
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
    }

    func saveOrRollbackProducer() -> SignalProducer<Void, ManagedObjectContextError> {
        return .init { observer, _ in
            let result = self.saveOrRollback()
            switch result {
            case .success:
                observer.send(value: ())
                observer.sendCompleted()
            case .failure(let error):
                observer.send(error: error)
            }
        }
    }

    func performChangesProducer(
        block: @escaping (_ context: NSManagedObjectContext) -> Void
        ) -> SignalProducer<Void, ManagedObjectContextError> {
        return performProducer(block: block)
            .flatMap(.latest) { _ -> SignalProducer<Void, ManagedObjectContextError> in
                return self.saveOrRollbackProducer()
        }
    }
}
