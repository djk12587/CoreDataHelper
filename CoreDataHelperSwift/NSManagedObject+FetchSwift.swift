//
//  NSManagedObject+FetchSwift.swift
//  Swift&ObjC
//
//  Created by Daniel Koza on 8/15/14.
//  Copyright (c) 2014 Allstate R&D. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    public class func core_findAllWithPredicate(predicate:NSPredicate?, context:NSManagedObjectContext) -> NSArray? {
        return self.find(nil, ascending: true, predicate: predicate, context: context, fetchLimit: 0)
    }
    
    public class func core_findAllSortedBy(sortTerm:NSString?, ascending:Bool, predicate:NSPredicate?, context:NSManagedObjectContext) -> NSArray? {
        return self.find(sortTerm, ascending: ascending, predicate: predicate, context: context, fetchLimit: 0)
    }
    
    class func find(sortTerm:NSString?, ascending:Bool, predicate:NSPredicate?, context:NSManagedObjectContext, fetchLimit:Int) -> NSArray? {
        
        var fetchRequest = NSFetchRequest(entityName: self.entityName())
        fetchRequest.predicate = predicate
        
        if sortTerm == nil {
            fetchRequest.sortDescriptors = nil
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortTerm!, ascending: ascending)]
        }
        
        if fetchLimit > 0 {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        var results = CoreDataHelperSwift.core_executeFetchRequest(fetchRequest, context: context)
        
        return results
    }
}