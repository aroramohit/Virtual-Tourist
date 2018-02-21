//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Mohit Arora on 15/02/18.
//  Copyright © 2018 soprateria. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient:NSObject{
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    

    func getImagesFromFlickr(latitude:Double, longitude:Double,pageNumber:Int, completionHandler:@escaping (_ result: [UIImage],_ error: String?) -> Void){
        var methodParameters : [String: String]
        if(pageNumber > 1){
            // add the page to the method's parameters
            methodParameters = createMethodParametersForFlickr(latitude: latitude, longitude: longitude)
            methodParameters[FlickrConstants.FlickrParameterKeys.Page] = pageNumber as? String
        }else{
             methodParameters = createMethodParametersForFlickr(latitude: latitude, longitude: longitude)
        }
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                completionHandler([],error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error?.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrConstants.FlickrResponseKeys.Status] as? String, stat == FlickrConstants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrConstants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(FlickrConstants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[FlickrConstants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(FlickrConstants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                
                var imageArray:[UIImage] = []
                for _ in 1...21{
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary[FlickrConstants.FlickrResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(FlickrConstants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                        return
                    }
                    
                    let imageURL = URL(string: imageUrlString)
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        
                        imageArray.append(UIImage(data: imageData)!)

                    } else {
                        displayError("Image does not exist at \(imageURL)")
                    }

                }
                
                completionHandler(imageArray,nil)
            }
        
        }
        // start the task!
        task.resume()
        
    }
    private func bboxString(latitude:Double,longitude:Double) -> String {
        // ensure bbox is bounded by minimum and maximums
            let minimumLon = max(longitude - FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    func createMethodParametersForFlickr(latitude:Double,longitude:Double) -> [String:String]{
        if(isLatlongValid(latitude, longitude, forRange: FlickrConstants.Flickr.SearchLatRange)){
            let methodParameters = [
                FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.SearchMethod,
                FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
                FlickrConstants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
                FlickrConstants.FlickrParameterKeys.SafeSearch: FlickrConstants.FlickrParameterValues.UseSafeSearch,
                FlickrConstants.FlickrParameterKeys.Extras: FlickrConstants.FlickrParameterValues.MediumURL,
                FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
                FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
            ]
            return methodParameters;
        }
        else {
            return [:]
        }
    }
    
    
    func isLatlongValid(_ latitude:Double,_ longitude:Double, forRange: (Double, Double)) -> Bool {
        if( isValueInRange(latitude, min: forRange.0, max: forRange.1) && isValueInRange(longitude, min: forRange.0, max: forRange.1)){
            return true
        }else{
            return false
        }
    }
    
    func isValueInRange(_ value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:String]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.Flickr.APIScheme
        components.host = FlickrConstants.Flickr.APIHost
        components.path = FlickrConstants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
