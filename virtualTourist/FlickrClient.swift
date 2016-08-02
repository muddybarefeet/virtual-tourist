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
    
    var totalPages: Int = 0
    var photos: [String] = []
    
    func getImagesForLocation (lat: Double, long: Double, recall: Bool, completionHandlerForImages: (success: Bool?, error: String?) -> Void) {
        
        let baseUrl = "https://api.flickr.com/services/rest"
        
        var parameters: [String: String!] = [
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.SafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.Extras,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(lat, longitude: long),
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.Method,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.Format,
            Constants.FlickrParameterKeys.NoJsonCallback: Constants.FlickrParameterValues.NoJsonCallback
        ]
        
        //need to add in the random page number request
        if recall == true {
            //make random number and then add with
            let pageLimit = min(totalPages, 40)
            let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            print("random page", randomPageNumber)
            parameters[Constants.FlickrParameterKeys.Page] = String(randomPageNumber)
        }

        let request = makeRequest(baseUrl, parameters: parameters)
        
        sendRequest(request) { (data, response, error) in
            if (error != nil) {
                print("error", error)
                completionHandlerForImages(success: nil, error: error)
            } else {
                //save data to the photos array
                if self.photos.count > 0 {
                    //delete the array of pics first(if reloading photos then do not want old ones in there too)
                    self.photos.removeAll()
                }
                for url in data! {
                    self.photos.append(url)
                }
                completionHandlerForImages(success: true, error: nil)
            }
        }
        
    }
    
    func processUrls (completionHandlerForProcessingUrls: (data: NSData?, error: String?) -> Void) {
        //loop through the photo URLS and return
        //each url returns a completion handler
        for url in photos {
            getImageData(url) { (data, error) in
                if data != nil {
                    completionHandlerForProcessingUrls(data: data, error: nil)
                } else {
                    completionHandlerForProcessingUrls(data: nil, error: error)
                }
            }
        }
    }
    
    func getImageData (image: String, completionHandlerForImageData: (data: NSData?, error: String?) -> Void) {
        let imageURL = NSURL(string: image)!
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            if error == nil {
                completionHandlerForImageData(data: data, error: nil)
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
                completionHandlerForRequest(data: nil, response: nil, error: "There was an error in the request response")
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
            guard let totalPages = photos["pages"] as? Int else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There is not a key for the number of pages returned")
                return
            }
            guard let collectionArray = photos["photo"] as? NSArray else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There were no photos key in the response")
                return
            }
            
            if collectionArray.count == 0 {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "There were no photos returned in the response")
                return
            }
            
            var photoArray: [String] = []
            
            //only use the first 18 images
            var i = 0
            while i < 18 {
                if let imageURL = collectionArray[i]["url_m"] as? String {
                   photoArray.append(imageURL)
                }
                i+=1
            }
            
            //set the toal pages count for the user to use if hit the see new album button
            self.totalPages = totalPages
            
            completionHandlerForRequest(data: photoArray, response: (response as! NSHTTPURLResponse), error: nil)
        }
        
        task.resume()
        
    }
    
}
    

    
    
    

