//
//  TravelLocationsMapView.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/25/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: CoreDataTravelLocationViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //deal with user map interation -> modally present next controller on tap of a pin
    override func viewDidLoad() {
        super.viewDidLoad()
        let pins = app.pins
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pins.context, sectionNameKeyPath: nil, cacheName: nil)
        
        addCurrentPins(fetchedResultsController!)
        
        let longUIPress = UILongPressGestureRecognizer(target: self, action: #selector(self.addPin))
        longUIPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longUIPress)
    }
    
    //load the existing pins to the map
    func addCurrentPins (fetchedController: NSFetchedResultsController) {
        let entities = fetchedController.fetchedObjects as! [Pin]
        for item in entities{
            //            for key in item.entity.attributesByName.keys{
            //            }
            let lat = item.latitude as! Double
            let long = item.longitude as! Double
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

    
    func addPin(gestureRecognizer:UIGestureRecognizer){
        print("action to add annotation called")
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        //make a new pin model
        let newPin = Pin(lat: newCoordinates.latitude, long: newCoordinates.longitude, context: fetchedResultsController!.managedObjectContext)
    }
    
}
