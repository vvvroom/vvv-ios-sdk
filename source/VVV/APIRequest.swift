//
//  VVVAPIRequest.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** A standard network response block that is used by the APIRequest performer to provide the response */
typealias NetworkReponseHandler = (Any?,String?) -> ()

/** The base class for API requests, this class must be subclassed to be used, and is passed into the api request performer. */
class APIRequest {
    
    /** A copy of the rawresponse data from the request */
    var rawResponse : Any?
    
    /** empty init method that can be overriddent */
    public init() {}
    
    /**
     
     Returns the Endpoint for the request.
     
     - Return :
     - NetworkEndpoint: The endpoint to contact for the request
     
     */
    func endPoint() -> NetworkEndpoint {
        fatalError("must override endpoint")
    }
    
    /**
     
     Returns the API Method for the request.
     
     - Return :
        - APIMethod: eg. get,post.
     
     */
    func method() -> APIMethod {
        return .post
    }
    
    /**
     
     Returns a dictionary object that is a representation of the parameters to be encoded and sent with the request.
     
     - Return :
     - [String:Any]: key value param dictionary.
     
     */
    func params() -> [String:Any] {
        return [:]
    }
    
    /**
     
     Returns the encoding type for the parameters dictionary
     
     - Return :
        - APIParameter: the ecoding type either json or url.  Typically it is url for get method and json for post.
     
     */
    func encoding() -> APIParameter {
        return .json
    }
    
    /**
     
     Returns the completion block for the request, this is where any mapping would be performed and also where a callback would be trigger to give the mapped information to the required view/object.
     
     - Return :
        - NetworkReponseHandler: the completion block.
     
     */
    func responseHandler() -> NetworkReponseHandler {
        return {(response,error) -> Void in }
    }
    
    /**
     
     Certain requests require information to be appended to the url befor url encoded items.  This appends the returned string to the url
     
     - Return :
        - String: string to be appended to the url.
     
     */
    func appendToUrl() -> String {
        return ""
    }
    
    /**
     
     When overriden must call super to include the app Auth Token.
     
     - Return :
     - [String:String] Header String Dictionary (defaults with the API authtoken)
     
     */
    func headers() -> [String:String] {
        guard let token = Config.shared.authToken else { return [:] }
        return ["Authorization":token]
    }
}
