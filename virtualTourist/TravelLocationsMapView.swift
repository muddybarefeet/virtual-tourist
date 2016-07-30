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

class TravelLocationsMapView: CoreDataTravelLocationViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedCoords: CLLocationCoordinate2D!
    
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //deal with user map interation -> modally present next controller on tap of a pin
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
            let lat = item.latitude as! Double
            let long = item.longitude as! Double
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    //on click of a pin go to the album
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("pin clicked", view.annotation?.coordinate)
        //save coordinates and segue
        selectedCoords = view.annotation?.coordinate
        performSegueWithIdentifier("showPhotoAlbum", sender: nil)
    }
    
    //coords passed to the new controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showPhotoAlbum" {
            if segue.destinationViewController is PhotoAlbumViewController {
                let annotation = mapView.selectedAnnotations[0]
                mapView.deselectAnnotation(annotation, animated: true)
                //let pin = CoreDataLookup.retrieveClickedPin(selectedCoords, context: fetchedResultsController!.managedObjectContext)
                //now we have the pin it can be passed to the new view!
                //print("pin recieved", pin)
                //photosVC.currentPin = pin
                
                
                let fetchRequest = NSFetchRequest()
                let entityDescription = NSEntityDescription.entityForName("Pin", inManagedObjectContext: fetchedResultsController!.managedObjectContext)
                fetchRequest.entity = entityDescription
                
                let predicate = NSPredicate(format: "latitude = %@", selectedCoords.latitude)
                //let longPredicate = NSPredicate(format: "longitude = %@", selectedCoords.longitude)
                
                //let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [latPredicate, longPredicate])
                //fetchRequest.predicate = predicate
                
                var fetchedObjects: [AnyObject] = try! fetchedResultsController!.managedObjectContext.executeFetchRequest(fetchRequest)
                
                print("data", fetchedObjects)
                //fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
            }
        }
    }
    
    //delegate method to trigger function on tap of a pin
    func addPin(gestureRecognizer:UIGestureRecognizer){
        print("action to add annotation called")
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        //make a new pin model
        _ = Pin(lat: newCoordinates.latitude, long: newCoordinates.longitude, context: fetchedResultsController!.managedObjectContext)
    }
    
}
