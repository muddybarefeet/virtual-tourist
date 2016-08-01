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
            print("annotation", annotation.id)
            mapView.addAnnotation(annotation)
        }
    }
    
    //on click of a pin go to the album
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("pin clicked", view.annotation?.coordinate)
        //check if meant to delete pin or to segue!
        if editButton.title == "Done" {
            //delete the pin from core data
            //let pin = fetchedResultsController!.managedObjectContext.objectWithID((view.annotation as! CustomPointAnnotation).id!) as? Pin
            //delete the pin
            if let pin = fetchedResultsController!.managedObjectContext.objectWithID((view.annotation as! CustomPointAnnotation).id!) as? Pin {
                fetchedResultsController!.managedObjectContext.deleteObject(pin as NSManagedObject)
                //save the update and then reload the view
                do {
                    try fetchedResultsController!.managedObjectContext.save()
                } catch {
                    print("not save")
                }
                //delete the pin
                mapView.removeAnnotation(view.annotation!)
            }
        } else {
            performSegueWithIdentifier("showPhotoAlbum", sender: nil)
        }
    }
    
    //coords passed to the new controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showPhotoAlbum" {
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
        print("button clicked", editButton.title)
        //if button says edit the go to delete mode
        let screenSize = UIScreen.mainScreen().bounds.size
        let label = UILabel(frame: CGRectMake(0, (view.frame.maxY), screenSize.width, 44))
        if (editButton.title == "Edit") {
            print("button clicked EDIT")
            editButton.title = "Done"
            //display view on bottom of the screen
            //label.center = CGPointMake(160, 284)
            label.textAlignment = NSTextAlignment.Center
            label.text = "Tap a pin to delete it"
            label.backgroundColor = UIColor.redColor()
            label.textColor = UIColor.whiteColor()
            view.frame.origin.y = 44 * (-1)
            view.addSubview(label)
        } else if (editButton.title == "Done") {
            print("done")
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

extension TravelLocationsMapView {
    func subscribeToKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TravelLocationsMapView.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TravelLocationsMapView.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
//        if bottomText.isFirstResponder() {
//            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
//        } else if topText.isFirstResponder(){
//            reset()
//        }
    }
    
    //  return the keyboard to the bottom position
    func reset() {
        self.view.frame.origin.y = 0
    }
    
    func keyboardWillHide(notification: NSNotification) {
        reset()
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

}
