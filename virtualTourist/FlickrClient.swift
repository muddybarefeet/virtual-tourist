//
//  FlickrClient.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/27/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class FlickrClient {
    
    static let sharedInstance = FlickrClient()
    private init() {}
    
    func getImagesForLocation (lat: Double, long: Double, completionHandlerForImages: (data: [String]?, error: String?) -> Void) {
        
        let baseUrl = "https://api.flickr.com/services/rest"
        
        let parameters: [String: String!] = [
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.SafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.Extras,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(lat, longitude: long),
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.Method,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.Format,
            Constants.FlickrParameterKeys.NoJsonCallback: Constants.FlickrParameterValues.NoJsonCallback
        ]
        
        let request = makeRequest(baseUrl, parameters: parameters)
        
        sendRequest(request) { (data, response, error) in
            if (error != nil) {
                print("error", error)
                completionHandlerForImages(data: nil, error: error)
            } else {
                completionHandlerForImages(data: data!, error: nil)
            }
        }
        
    }
    
    //call the API a second time, now with a random page number
    func displayRgetNewCollectionOfImages (request: NSMutableURLRequest, withPageNumber: Int) {
        
       //TODO
        
    }
    
    func getImageData (image: String, completionHandlerForImageData: (data: UIImage?, error: String?) -> Void) {
        print("extract Image data")
        
        let imageURL = NSURL(string: image)!
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            print("task finished")
            if error == nil {
                completionHandlerForImageData(data: UIImage(data: data!), error: nil)
            } else {
                completionHandlerForImageData(data: nil, error: "No image data returned")
            }
            
        }
        
        task.resume()

    }
    
    private func bboxString (latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    
    private func makeRequest (baseURL: String, parameters: [String:String!]) -> NSMutableURLRequest {
        //-----TODO: sent a random page number to got-----
        var newURL = baseURL + "?"
        var first = true;
        for (key, value) in parameters {
            let newParam = key + "=" + value
            if first == true {
                first = false
                newURL += newParam
            } else {
                newURL += "&" + newParam
            }
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: newURL)!)
        return request
    }
    
    //return random page if call came from new collection button
    private func sendRequest (request: NSMutableURLRequest, completionHandlerForRequest: (data: [String]?, response: NSHTTPURLResponse?, error: String?) -> Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There was an error in the request response")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "The status code returned was not a OK")
                return
            }
            guard let data = data else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "No data returned from the API")
                return
            }
            
            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "Could not parse the response to a readable format")
                return
            }
            
            //extract the key for images array
            guard let photos = parsedResult!["photos"] as? NSDictionary else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There were no photo key in the response")
                return
            }
            guard let collectionArray = photos["photo"] as? NSArray else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There were no photos key in the response")
                return
            }
            
            if collectionArray.count == 0 {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There were no photos returned in the response")
            }
            
            var photoArray: [String] = []
            
            //take the array of data and make a new array of just the images
            for obj in collectionArray {
                if let imageURL = obj["url_m"] as? String {
                   photoArray.append(imageURL)
                }
            }
        
//            if let totalPages = parsedResult!["pages"] as? Int {
//                
//                let pageLimit = min(totalPages, 40)
//                let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//                self.displayRandomImageCall(request, withPageNumber: randomPageNumber)
//            }
            
            completionHandlerForRequest(data: photoArray, response: (response as! NSHTTPURLResponse), error: nil)
        }
        
        task.resume()
        
    }
    
}
    

    
    
    

