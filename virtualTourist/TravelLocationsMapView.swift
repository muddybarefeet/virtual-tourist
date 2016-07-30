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
            let id = item.objectID
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = CustomPointAnnotation(coreDataID: id)
            annotation.coordinate = coordinate
            print("annotation", annotation.id)
            mapView.addAnnotation(annotation)
        }
    }
    
    //on click of a pin go to the album
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("pin clicked", view.annotation?.coordinate)
        //save coordinates and segue
        performSegueWithIdentifier("showPhotoAlbum", sender: nil)
    }
    
    //coords passed to the new controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showPhotoAlbum" {
        
            let controller = segue.destinationViewController as! PhotoAlbumViewController
            let annotation = mapView.selectedAnnotations[0]
            mapView.deselectAnnotation(annotation, animated: true)
            controller.currentPin = fetchedResultsController!.managedObjectContext.objectWithID((annotation as! CustomPointAnnotation).id!) as? Pin
        }
    }
    
    //delegate method to trigger function on tap of a pin
    func addPin(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == .Ended {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            //make a new pin model
            _ = Pin(lat: newCoordinates.latitude, long: newCoordinates.longitude, context: fetchedResultsController!.managedObjectContext)
        }
    }
    
}

class CustomPointAnnotation: MKPointAnnotation {
    
    var id: NSManagedObjectID?
    
    init(coreDataID: NSManagedObjectID) {
        id = coreDataID
    }
    
}
