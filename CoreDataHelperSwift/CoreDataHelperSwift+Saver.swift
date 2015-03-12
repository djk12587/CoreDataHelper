//
//  CoreDataHelperSwift+Saver.swift
//  Swift&ObjC
//
//  Created by Daniel Koza on 8/15/14.
//  Copyright (c) 2014 Allstate R&D. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataHelperSwift {

    public typealias CoreSimpleBlock = () -> ()
    public typealias CoreErrorBlock = (error:NSError?) -> ()
    
    public class func core_saveInMainContext(changes:CoreSimpleBlock) {
        var context = self.defaultStore.mainQueueContext
        
        context.performBlock { () -> Void in
            changes()
            
            var error:NSError?
            context.save(&error)
            
            if error != nil {
                println("Error saving main context: \(error)")
            }
        }
    }
    
    public class func core_saveInPrivateQueue(changes:CoreSimpleBlock) {
        self.core_saveInPrivateQueue(changes, completion:nil)
    }
    
    public class func core_saveInPrivateQueue(changes:CoreSimpleBlock, completion:CoreErrorBlock?) {
        var privateContext = self.defaultStore.privateQueueContext
        
        privateContext.performBlock { () -> Void in
            changes()
            
            var error:NSError?
            privateContext.save(&error)
            
            if error != nil {
                println("Error saving private context: \(error)")
            }
            
            if completion != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    completion!(error:error)
                })
            }
        }
    }
}
