//
//  NSManagedObject+CreationSwift.swift
//  Swift&ObjC
//
//  Created by Daniel Koza on 8/15/14.
//  Copyright (c) 2014 Allstate R&D. All rights reserved.
//

import Foundation
import CoreData

protocol NamedManagedObject {
    
    static func entityName() -> String;
    
}

//extension ExampleEntitySwift : NamedManagedObject {
//    override class func entityName() -> String {
//        return NSStringFromClass(self)
//    }
//}

extension NSManagedObject : NamedManagedObject {
    
    class func entityName() -> String {
        return NSStringFromClass(self)
    }
    
    public class func core_createInContext(context:NSManagedObjectContext) -> AnyObject {
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: context)
    }
}
