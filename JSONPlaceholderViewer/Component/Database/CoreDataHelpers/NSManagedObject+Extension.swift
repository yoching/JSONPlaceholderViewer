//
//  NSManagedObject+Extension.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/20/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import CoreData
import Result

extension NSManagedObjectContext {
    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return object
    }

    func saveOrRollback() -> Result<Void, ManagedObjectContextError> {
        do {
            try save()
            return .success(())
        } catch {
            rollback()
            return .failure(.general(error))
        }
    }
}
