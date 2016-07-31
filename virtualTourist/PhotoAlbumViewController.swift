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

class PhotoAlbumViewController: CoreDataTravelLocationViewController, UICollectionViewDataSource {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewButton: UIBarButtonItem!

    
    let Flickr = FlickrClient.sharedInstance
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var currentIndexPath: NSIndexPath?

    var currentPin: Pin?
    
    var photoData: [NSData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    print("error", error)
                }
            }
        } else {
            //display the images already saved
            print("already have images")
            //just incase other data is in the photoData array empty it
            photoData.removeAll()
            
            //extract all the photos from the current pin (NSData)
            let allCurrentPhotos = currentPin?.photos?.allObjects
            //extract photos
            for photo in allCurrentPhotos! {
                if let nsDataImage = (photo as! Photo).image {
                    photoData.append(nsDataImage)
                }
            }
            
            collectionView.reloadData()
            print("CORE DATA LOADED", photoData.count)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        adjustFlowLayout(view.frame.size)
    }
    
    //read dowdloaded urls and add to NSData array to show to the user
    func processUrls () {
        //when first called need to make sure that the photos array is empty
        photoData.removeAll()
        Flickr.processUrls() { (data, error) in
            //save the data to URL array and reload
            if data != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.photoData.append(data!)
                    self.collectionView.reloadData()
                }
            } else {
                //error
                print("error making nsdata from urls")
            }
        }
    }
    
    @IBAction func clickedButton(sender: AnyObject) {
        print("button clicked")
        if viewButton.title! == "New Album" {
            getNewAlbum()
        } else if viewButton.title! == "Delete Photo" {
            print("to delete", currentIndexPath)
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
                print("error", error)
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        
        let context = currentPin?.managedObjectContext
        //if there are already pins saved then want to delete and then resave the core data models
        if currentPin?.photos?.count > 0 {
            let context = currentPin?.managedObjectContext
            for photo in (currentPin?.photos)! {
                //photo.removeAllObjects()
                //NSManagedObjectContext.deleteObject(photo)
                context!.deleteObject(photo as! NSManagedObject)
            }
            //save the deletion to the db
            do {
                try context?.save()
            } catch {
                print("not save")
            }
            print("pin new post delete------>", currentPin?.photos?.count)
        }
        
        //now resave the latest photos to core data
        for blob in photoData {
            //make new photo obj and add to pin
            let dataToAdd = Photo(image: blob, pin: self.currentPin!, context: context!)
            self.currentPin?.photos?.setByAddingObject(dataToAdd)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        
        //get the cell to show
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
        
        //let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        //activitySpinner.stopAnimating()
        //cell.imageView.willRemoveSubview(activitySpinner)
        
        //show the placeholder image
        cell.photo.image = UIImage(named: "placeholder")
        
        //if there are images to lod from Flickr then load them
        if photoData.count > 0 {
            cell.imageView.addSubview(activitySpinner)
            //activitySpinner.startAnimating()
            //activitySpinner.center = cell.imageView.center
            let photo = photoData[indexPath.row]
            cell.photo.image = UIImage(data: photo)
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
        }
        
    }
    
}