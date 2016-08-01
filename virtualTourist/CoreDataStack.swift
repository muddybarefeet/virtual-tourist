//
//  CoreDataStack.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/26/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//


import CoreData

struct CoreDataStack {
    
    //Core Data Stacks Properties
    private let model : NSManagedObjectModel
    private let coordinator : NSPersistentStoreCoordinator
    private let modelURL : NSURL
    private let dbURL : NSURL
    private let persistingContext : NSManagedObjectContext
    private let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model

        // 1. Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // 2. Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        //3. make the Main Queue (UI changing queue)
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = persistingContext
        
        // 4. Create a background context child of main context to do all network requests/get things form DB
        backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.parentContext = context
        
        // Add a SQLite store located in the documents folder
        let fm = NSFileManager.defaultManager()
        
        guard let docUrl = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.URLByAppendingPathComponent("model.sqlite")
        
        //options for migration: want to migrate and want to get it to find out how to migrate
        let options = [
            NSInferMappingModelAutomaticallyOption: true,
            NSMigratePersistentStoresAutomaticallyOption: true
        ]
        
        //use the migrations when we add a store coordinator
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options)
        }catch{
            print("unable to add store at \(dbURL)")
        }
    }
    
    func addStoreCoordinator(storeType: String,
                             configuration: String?,
                             storeURL: NSURL,
                             options : [NSObject : AnyObject]?) throws{
        
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        
    }

}

// MARK:  - Removing data
//extension CoreDataStack  {
//    
//    func dropAllData() throws{
//        // delete all the objects in the db. This won't delete the files, it will
//        // just leave empty tables.
//        try coordinator.destroyPersistentStoreAtURL(dbURL, withType:NSSQLiteStoreType , options: nil)
//        
//        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
//    }
//}

extension CoreDataStack {
    
    func save() {
        print("save called")
        context.performBlockAndWait(){
            if self.context.hasChanges{
                do{
                    try self.context.save()
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
                // now we save in the background
                self.persistingContext.performBlock(){
                    do{
                        try self.persistingContext.save()
                    }catch{
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
//    func autoSave(delayInSeconds : Int){
//        if delayInSeconds > 0 {
//            print("Autosaving")
//            save()
//            
//            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
//            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
//            
//            dispatch_after(time, dispatch_get_main_queue(), {
//                self.autoSave(delayInSeconds)
//            })
//        }
//    }
    
}

