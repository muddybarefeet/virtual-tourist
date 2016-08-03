//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/25/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//import Foundation
import UIKit
import MapKit
import CoreData
import MapKit

class PhotoAlbumViewController: CoreDataTravelLocationViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewButton: UIBarButtonItem!
    @IBOutlet weak var mapDetailView: MKMapView!
    
    let Flickr = FlickrClient.sharedInstance
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var currentIndexPath: NSIndexPath?

    var currentPin: Pin?
    
    var photoData: [NSData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load placeholder images into the data array
        var i = 0
        while i < 18 {
            let photoPlaceholder = UIImage(named: "placeholder")
            let imageData: NSData = UIImagePNGRepresentation(photoPlaceholder!)!
            photoData.append(imageData)
            i+=1
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(self.done))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        //on load the page we want to get the coords from the photo pin that was passed and add annotation on mapDetailView and zoom in
        addPinLocationToMap()
        viewButton.title = "New Album"
        
        if currentPin?.photos?.count == 0 {
            print("no pics currently")
            //then we need some pics from Flickr to display
            Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: false) { (success, error) in
                if (success != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //call function to process the urls to NSData
                        self.processUrls()
                    }
                } else {
                    self.displayError("There was an error getting the image data for this location: \(error!)")
                }
            }
        } else {
            //display the images already saved
            print("already have images")
            //just incase other data is in the photoData array empty it
            photoData.removeAll()
            //don't bother with placeholders here as pretty fast
            //extract all the photos from the current pin (NSData)
            let allCurrentPhotos = currentPin?.photos?.allObjects
            //extract photos
            for photo in allCurrentPhotos! {
                if let nsDataImage = (photo as! Photo).image {
                    photoData.append(nsDataImage)
                }
            }
            collectionView.reloadData()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        adjustFlowLayout(view.frame.size)
    }
    
    //read dowdloaded urls and add to NSData array to show to the user
    func processUrls () {
        //when first called need to make sure that the photos array is empty
        photoData.removeAll()
        //then make the array full of 18 placeholders
        var i = 0
        while i < 18 {
            let photoPlaceholder = UIImage(named: "placeholder")
            let imageData: NSData = UIImagePNGRepresentation(photoPlaceholder!)!
            photoData.append(imageData)
            i+=1
        }
        collectionView.reloadData()
        var counter = 0
        Flickr.processUrls() { (data, error) in
            //save the data to URL array and reload
            if data != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //want to add to the front of the array of photos and then remove the last one
                    self.photoData.insert(data!, atIndex: counter)
                    self.photoData.removeLast()
                    //self.photoData.append(data!)
                    self.collectionView.reloadData()
                    counter+=1
                }
            } else {
                self.displayError("There was a problem converting the image URLs to images")
            }
        }
    }
    
    func addPinLocationToMap () {
        let coordinate = CLLocationCoordinate2D(latitude: Double(currentPin!.latitude!), longitude: Double(currentPin!.longitude!))
        let latDelta:CLLocationDegrees = 1.0
        let longDelta:CLLocationDegrees = 1.0
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        mapDetailView.setRegion(region, animated: true)
        //now add the annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapDetailView.addAnnotation(annotation)
    }
    
    @IBAction func clickedButton(sender: AnyObject) {
        if viewButton.title! == "New Album" {
            getNewAlbum()
        } else if viewButton.title! == "Delete Photo" {
            if let indexPath = currentIndexPath {
                photoData.removeAtIndex(indexPath.row)
            }
            //clear the indexPath variable and reset the button name
            currentIndexPath = nil
            viewButton.title = "New Album"
            collectionView.reloadData()
        }
    }
    
    func getNewAlbum() {
        //logic to get new selection of photos
        Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: true) { (success, error) in
            if (success != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //trigger function to populate array of NSData to display to client
                    self.processUrls()
                }
            } else {
                self.displayError("There was an error getting the image data for this location: \(error!)")
            }
        }
    }
    
    func done(sender: AnyObject) {
        let context = currentPin?.managedObjectContext
        //if there are already pins saved then want to delete and then resave the core data models
        if currentPin?.photos?.count > 0 {
            let context = currentPin?.managedObjectContext
            for photo in (currentPin?.photos)! {
                context!.deleteObject(photo as! NSManagedObject)
            }
            //save the deletion to the db
            do {
                try context?.save()
            } catch {
                self.displayError("There was a problem saving the current album to the database")
            }
        }
        
        //now resave the latest photos to core data
        for blob in photoData {
            //make new photo obj and add to pin
            let dataToAdd = Photo(image: blob, pin: self.currentPin!, context: context!)
            self.currentPin?.photos?.setByAddingObject(dataToAdd)
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    private func displayError (message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alertController, animated: true, completion:nil)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustFlowLayout(size)
    }
    
    func adjustFlowLayout(size: CGSize) {
        let space: CGFloat = 1.0
        let dimension:CGFloat = size.width >= size.height ? (size.width - (5 * space)) / 6.0 :  (size.width - (2 * space)) / 3.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if Flickr has images then return thrier count else return other number
        if photoData.count > 0 {
            return photoData.count
        } else {
            return 18
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
        cell.photo.image = UIImage(named: "placeholder")
        if photoData.count > 0 {
            let photo = photoData[indexPath.row]
            cell.photo.image = UIImage(data: photo)
            cell.alpha = 1.0
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //if we select an image then we want to delete it
        //make the selected image semi-opaque
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell?.alpha == 1 {
            cell!.alpha = 0.2
            //trigger fn to change the text on the bottom button
            viewButton.title = "Delete Photo"
            currentIndexPath = indexPath
        } else {
            cell?.alpha = 1
            viewButton.title = "New Album"
        }
        
    }
    
}