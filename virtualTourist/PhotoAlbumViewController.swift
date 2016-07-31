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
    
    let Flickr = FlickrClient.sharedInstance

    var currentPin: Pin?
    var currentContext: NSManagedObjectContext?
    
    //var photos: [String] = FlickrClient.sharedInstance.photos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentPin?.photos?.count == 0 {
            print("no pics currently")
            //then we need some pics from Flickr to display
            Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: false) { (data, error) in
                if (data!.count > 0) {
                    //save data to store
                    if let data = data {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.Flickr.photos = data
                            //RELOAD DATA to show in collection
                            self.collectionView.reloadData()
                            print("photos saved", self.Flickr.photos.count)
                            print(self.currentPin)
                        }
                    } else {
                        //THROW ERROR THAT DATA NOT THERE
                    }
                } else {
                    print("error", error)
                }
            }
        } else {
            //display the images already saved
            print("already have images")
        }
        
        //else the false key is already set so nothing else needs doing add pin and segue
        collectionView.delegate = self
        collectionView.dataSource = self
        adjustFlowLayout(view.frame.size)
        
    }
    
    
    //delete photo
    //Add a README doc
    //throw WARNING if the total page count is ONE to let the user know that they will never see more than current images
    
    @IBAction func getNewAlbum(sender: AnyObject) {
        //logic to get new selection of photos
        Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: true) { (data, error) in
            if (data!.count > 0) {
                if let data = data {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.Flickr.photos = data
                        self.collectionView.reloadData()
                        print("photos saved", self.Flickr.photos.count)
                    }
                }
            } else {
                print("error", error)
            }
            
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        //add logic to save the photos to the pin for future!
        //if there is photos already saved then delete them and then save new ones
//        if currentPin?.photos?.count > 0 {
//            print("deleting old pins....?")
//            currentPin?.photos?.delete(currentPin?.photos)
//        }
        
        print("current pin deleted pics--------->", currentPin?.photos?.count)
        //loop through the photos and save each to a Photo View
        
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
        dismissViewControllerAnimated(true, completion: nil)
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
        return Flickr.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
        //download the image and get the data
        
        Flickr.getImageData(Flickr.photos[indexPath.row]) { (data, error) in
            if data != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let downloadedImage = UIImage(data: data!)
                    cell.photoView.image = downloadedImage
                }
            } else {
                print("bad data of image nothing returned")
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //if we select an image then we want to delete it
        _ = Flickr.photos[indexPath.row]
        //now get the object for this index path
        
        
    }
    
}