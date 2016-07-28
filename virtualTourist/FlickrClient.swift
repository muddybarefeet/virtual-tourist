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
    
    func getImagesForLocation (lat: Double, long: Double, completionHandlerForImages: (data: AnyObject?, error: String?) -> Void) {
        
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
            print("recieve request sent")
            if (error != nil) {
                print("error", error)
                completionHandlerForImages(data: nil, error: error)
            } else {
                print("good response from request", data)
                completionHandlerForImages(data: data, error: nil)
            }
        }
        
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
    private func sendRequest (request: NSMutableURLRequest, completionHandlerForRequest: (data: AnyObject?, response: NSHTTPURLResponse??, error: String?) -> Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                completionHandlerForRequest(data: nil, response: nil, error: "There was an error in the request response")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForRequest(data: nil, response: nil, error: "The status code returned was not a OK")
                return
            }
            guard let data = data else {
                completionHandlerForRequest(data: nil, response: nil, error: "No data returned from the API")
                return
            }
            
            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "Could not parse the response to a readable format")
                return
            }
            print("json", parsedResult)
            
//            if let totalPages = parsedResult!["pages"] as? Int {
//                
//                let pageLimit = min(totalPages, 40)
//                let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//                self.displayRandomImageCall(request, withPageNumber: randomPageNumber)
//            }
            
            //completionHandlerForRequest(data: parsedResult, response: (response as! NSHTTPURLResponse), error: nil)
        }
        
        task.resume()
        
    }
    
    //call the API a second time, now with a random page number
    private func displayRandomImageCall (request: NSMutableURLRequest, withPageNumber: Int) {
        
        
        
    }
        
}
    

    
    
    

