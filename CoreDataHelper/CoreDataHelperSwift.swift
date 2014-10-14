//
//  CoreDataHelperSwift.swift
//  Swift&ObjC
//
//  Created by Daniel Koza on 8/14/14.
//  Copyright (c) 2014 Allstate R&D. All rights reserved.
//

import UIKit
import CoreData

private let _defaultStore = CoreDataHelperSwift()

class CoreDataHelperSwift: NSObject {
    
    #error set this to the name of your model file without the fileExtension
    let coreDataModelFileName = "SwiftModel"
    
    //MARK: - Getters
    lazy var managedObjectModel:NSManagedObjectModel = {
        var modelURL = NSBundle.mainBundle().URLForResource(self.coreDataModelFileName, withExtension: "momd")
        var objectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        return objectModel
    }()
    
    lazy var mainQueueContext:NSManagedObjectContext = {

        var mainContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return mainContext

    }()
    
    lazy var privateQueueContext:NSManagedObjectContext = {

        var privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return privateContext

    }()
    
    lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator = {
        var error:NSError?
        
        var persistentCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        if persistentCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.persistentStoreURL(), options: self.persistentStoreOptions(), error: &error) == nil {
            println("Error adding persistent Store \(error)")
        }
        return persistentCoordinator
    }()

    //MARK: - Stack set up helper methods

    func persistentStoreURL() -> NSURL {
        var appName:NSString? = NSBundle.mainBundle().infoDictionary["CFBundleName"] as? NSString
        appName = appName?.stringByAppendingString(".sqlite")
        return CoreDataHelperSwift.applicationDocumentsDirectory().URLByAppendingPathComponent(appName!)
    }

    class func applicationDocumentsDirectory() -> NSURL {
        
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as NSURL
    }
    
    func persistentStoreOptions() -> NSDictionary {
        return NSDictionary(objectsAndKeys: NSInferMappingModelAutomaticallyOption,"YES", NSMigratePersistentStoresAutomaticallyOption, "YES", NSSQLitePragmasOption, ["synchronous":"OFF"])
    }
    
    //MARK: - Lifecycle
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSavePrivateQueueContext:", name: NSManagedObjectContextDidSaveNotification, object: self.privateQueueContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveMainQueueContext:", name: NSManagedObjectContextDidSaveNotification, object: self.mainQueueContext)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - Notification Handlers
    
    func contextDidSavePrivateQueueContext(notification:NSNotification) {
        objc_sync_enter(self)
        self.privateQueueContext.performBlock { () -> Void in
            self.privateQueueContext.mergeChangesFromContextDidSaveNotification(notification)
        }
        objc_sync_exit(self)
    }
    
    func contextDidSaveMainQueueContext(notification:NSNotification) {
        objc_sync_enter(self)
        self.mainQueueContext.performBlock { () -> Void in
            self.mainQueueContext.mergeChangesFromContextDidSaveNotification(notification)
        }
        objc_sync_exit(self)
    }

    //MARK: - Singleton Access

    class var defaultStore: CoreDataHelperSwift {
        return _defaultStore
    }
    
    class func getPrivateQueueContext() -> NSManagedObjectContext {
        return _defaultStore.privateQueueContext
    }

    class func getMainQueueContext() -> NSManagedObjectContext {
        return _defaultStore.mainQueueContext
    }
    
    //MARK: - Fetch Helper
    
    class func core_executeFetchRequest(request:NSFetchRequest, context:NSManagedObjectContext) -> NSArray? {
        var results:NSArray?
        var error:NSError? = nil
        context.performBlockAndWait { () -> Void in
            results = context.executeFetchRequest(request, error: &error)
        }
        
        if error != nil {
            let errorMessage = NSString(string: "Error in fetch request:\(request) Error: \(error)")
            println(errorMessage)
            error = NSError(domain: NSSQLiteErrorDomain, code: 1, userInfo: ["error" : errorMessage])
        }
     
        return results
    }

}
