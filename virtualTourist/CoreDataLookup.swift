//
//  CoreDataLookup.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/30/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.


import Foundation
import CoreData
import MapKit

struct CoreDataLookup {
    
    static func retrieveClickedPin(coordinates: CLLocationCoordinate2D, context: NSManagedObjectContext) -> Pin {
        //get all entities
        let fetchRequest = CoreDataLookup.setupFetchRequest("Pin", context: context)
        //filter on the predicates (both the lat and long)
        let latitude = coordinates.latitude as Double
        let longitude = coordinates.longitude as Double
        let latPredicate = NSPredicate(format: "latitude == %@", latitude)
        let longPredicate = NSPredicate(format: "longitude == %@", longitude)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [latPredicate, longPredicate])
        fetchRequest.predicate = predicate
        
        let pinObject = CoreDataLookup.executeFetchRequest(context, fetchRequest: fetchRequest)
        print("PIN OBJECT", pinObject)
        //return the first relevant pin for the predicate
        return pinObject![0] as! Pin
    }
    
    //fetch all entities of the input type
    static func setupFetchRequest(entityString: String, context: NSManagedObjectContext) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName(entityString, inManagedObjectContext: context)
        fetchRequest.entity = entityDescription
        return fetchRequest
    }
    
    //take the context and fetch request and return the object filtered for in the predicate
    static func executeFetchRequest(context: NSManagedObjectContext, fetchRequest: NSFetchRequest) -> AnyObject? {
        var object: AnyObject? = nil
        do {
            object = try context.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
        return object
    }
    
}
