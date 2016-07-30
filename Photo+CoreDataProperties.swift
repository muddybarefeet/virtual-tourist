//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/30/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var createdAt: NSDate?
    @NSManaged var url: String?
    @NSManaged var pin: Pin?

}
