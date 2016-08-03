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
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //deal with user map interation -> modally present next controller on tap of a pin
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        editButton.title = "Edit"
        
        //if there is data already stored then get it and add to map
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
        for item in entities {
            let lat = item.latitude as! Double
            let long = item.longitude as! Double
            let id = item.objectID
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = CustomPointAnnotation(coreDataID: id)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    //on click of a pin go to the album
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //check if meant to delete pin or to segue!
        if editButton.title == "Done" {
            //delete the pin from core data
            if let pin = fetchedResultsController!.managedObjectContext.objectWithID((view.annotation as! CustomPointAnnotation).id!) as? Pin {
                fetchedResultsController!.managedObjectContext.deleteObject(pin)
                //save the update
                do {
                    try fetchedResultsController!.managedObjectContext.save()
                } catch {
                    let alertController = UIAlertController(title: "Error", message: "The latest changes were not saved", preferredStyle: UIAlertControllerStyle.Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    }
                    alertController.addAction(OKAction)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(alertController, animated: true, completion:nil)
                    }
                    
                }
                //delete the pin from the map
                mapView.removeAnnotation(view.annotation!)
            }
        } else {
            performSegueWithIdentifier("showAlbum", sender: nil)
        }
    }
    
    //coords passed to the new controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showAlbum" {
            let controller = segue.destinationViewController as! PhotoAlbumViewController
            let annotation = mapView.selectedAnnotations[0]
            mapView.deselectAnnotation(annotation, animated: true)
            //get the id property on the annotation
            controller.currentPin = fetchedResultsController!.managedObjectContext.objectWithID((annotation as! CustomPointAnnotation).id!) as? Pin
        }
    }
    
    //delegate method to trigger function on tap of a pin
    func addPin(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == .Ended {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            let newPin = Pin(lat: newCoordinates.latitude, long: newCoordinates.longitude, context: fetchedResultsController!.managedObjectContext)
            let id = newPin.objectID
            let annotation = CustomPointAnnotation(coreDataID: id)
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func editButton(sender: AnyObject) {
        let screenSize = UIScreen.mainScreen().bounds.size
        let label = UILabel(frame: CGRectMake(0, (view.frame.maxY), screenSize.width, 44))
        //if button says edit the go to delete mode
        if (editButton.title == "Edit") {
            editButton.title = "Done"
            //add message to the user
            label.textAlignment = NSTextAlignment.Center
            label.text = "Tap a pin to delete it"
            label.backgroundColor = UIColor.redColor()
            label.textColor = UIColor.whiteColor()
            view.frame.origin.y = 44 * (-1)
            view.addSubview(label)
        } else if (editButton.title == "Done") {
            //return to normal screen view
            view.frame.origin.y = 0
            editButton.title = "Edit"
        }
        
    }
    
}

//class to make it possible to pass the pin along to the next view controller
class CustomPointAnnotation: MKPointAnnotation {
    var id: NSManagedObjectID?
    init(coreDataID: NSManagedObjectID) {
        id = coreDataID
    }
}
