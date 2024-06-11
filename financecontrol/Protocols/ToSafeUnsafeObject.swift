//
//  ToSafeUnsafeObject.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/07.
//

import CoreData

protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}

protocol ToUnsafeObject {
    associatedtype UnsafeType: NSManagedObject
    func unsafeObject(in context: NSManagedObjectContext) throws -> UnsafeType
}
