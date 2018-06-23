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

extension NSManagedObjectContext {
    func fetchProducer<Entity>(request: NSFetchRequest<Entity>) -> SignalProducer<[Entity], AnyError> { // TODO: change error type
        return .init { observer, _ in
            do {
                let entities = try self.fetch(request)
                observer.send(value: entities)
                observer.sendCompleted()
            } catch {
                observer.send(error: AnyError(error))
            }
        }
    }
}
