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
    var currentContext: NSManagedObjectContext?
    
    //var photos: [String] = FlickrClient.sharedInstance.photos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewButton.title = "New Album"
        
        if currentPin?.photos?.count == 0 {
            print("no pics currently")
            //then we need some pics from Flickr to display
            Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: false) { (success, error) in
                if (success != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //RELOAD DATA to show in collection
                        self.collectionView.reloadData()
                    }
                } else {
                    print("error", error)
                }
            }
        } else {
            //display the images already saved
            print("already have images")
            //extract all the photos from the current pin (NSData)
            let allCurrentPhotos = currentPin?.photos?.allObjects
            //extract photos
            for photo in allCurrentPhotos! {
                //fill in the array of urls with strings of the NSData imgaes that were saved
                Flickr.photos.append(String(photo.image))
            }
            collectionView.reloadData()
            print("Flickr", Flickr.photos.count)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        adjustFlowLayout(view.frame.size)
    }
    
    @IBAction func clickedButton(sender: AnyObject) {
        
        if viewButton.title! == "New Album" {
            getNewAlbum()
        } else if viewButton.title! == "Delete Photo" {
            if let indexPath = currentIndexPath {
                Flickr.photos.removeAtIndex(indexPath.row)
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
                    self.collectionView.reloadData()
                    print("photos saved", self.Flickr.photos.count)
                }
            } else {
                print("error", error)
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {

        print("current pin pre-deleted pics--------->", currentPin?.photos?.count)
        
        //if there are already pins saved then want to delete and then resave the core data models
        if currentPin?.photos?.count > 0 {
            print("deleting old pins....?")
            
            //var items = currentPin?.photos?.allObjects
//            currentPin?.photos?
//            for item in items! {
//                if (currentContext != nil) {
////                        currentContext!.deleteObject(item as! NSManagedObject)
//                    delete(item)
//                } else {
//                    print("no context")
//                }
//                
//            }
        
            //print("current pin deleted pics--------->", items?.count)
            
            //then add all current ones back to core data
//                for url in Flickr.photos {
//                    Flickr.getImageData(url) { (data, error) in
//                        if data != nil {
//                            let dataToAdd = Photo(image: data!, pin: self.currentPin!, context: self.currentContext!)
//                            self.currentPin?.photos?.setByAddingObject(dataToAdd)
//                        } else {
//                            print("bad data of image nothing returned")
//                        }
//                        print("we have new pin core datas",self.currentPin!.photos?.count)
//                        
//                    }
//                }
            Flickr.photos.removeAll()
            dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            //need to save data to core data if not anything already there
            for url in Flickr.photos {
                Flickr.getImageData(url) { (data, error) in
                    if data != nil {
                        let dataToAdd = Photo(image: data!, pin: self.currentPin!, context: self.currentContext!)
                        self.currentPin?.photos?.setByAddingObject(dataToAdd)
                    } else {
                        print("bad data of image nothing returned")
                    }
                    
                }
            }
            Flickr.photos.removeAll()
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustFlowLayout(size)
    }
    
    func adjustFlowLayout(size: CGSize) {
        let space: CGFloat = 3.0
        let dimension:CGFloat = size.width >= size.height ? (size.width - (5 * space)) / 6.0 :  (size.width - (2 * space)) / 3.0
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //if Flickr has images then return thrier count else return other number
        if Flickr.photos.count > 0 {
            return Flickr.photos.count
        } else {
            //TODO decide on a less random number here!
            return 21
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        //get the cell to show
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
        
        let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        //show the placeholder image
        cell.photo.image = UIImage(named: "placeholder")
        //activitySpinner.center = cell.imageView.center
        cell.imageView.addSubview(activitySpinner)
        activitySpinner.startAnimating()

        //if there are images to lod from Flickr then load them
        if Flickr.photos.count > 0 {
            
            Flickr.getImageData(Flickr.photos[indexPath.row]) { (data, error) in
                if data != nil {
                    let downloadedImage = UIImage(data: data!)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        cell.photo.image = downloadedImage
                        //TODO SPINNERS NOT BEING REMOVED!!
                        self.activitySpinner.stopAnimating()
                        cell.imageView.willRemoveSubview(self.activitySpinner)
                    }
                } else {
                    print("bad data of image nothing returned")
                }
            }
        }
    
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //if we select an image then we want to delete it
        //make the selected image semi-opaque
        print("clicked cell")
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell!.alpha = 0.4
        //trigger fn to change the text on the bottom button
        viewButton.title = "Delete Photo"
        currentIndexPath = indexPath
    }
    
}