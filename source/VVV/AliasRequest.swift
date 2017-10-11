//
//  ConfigRequest.swift
//  VVV
//
//  Created by James Swiney on 14/3/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import UIKit

//Fetches the alias for the API Key, to identify requests.
class AliasRequest: APIRequest {

    /** completion block called after request with the site alias and an error message if failed */
    let completion : (String?,String?)->()
    
    /**
     
     Inits the request with completion block
     
     - Parameters:
     - completion: The block called after the request completes
     
     */
    init(completion:@escaping (String?,String?)->()) {
        self.completion = completion
    }

    override func endPoint() -> NetworkEndpoint {
        return .Details
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func encoding() -> APIParameter {
        return .url
    }
    
    override func responseHandler() -> NetworkReponseHandler {
        return {(response,error) -> Void in
            
            if let alias = self.map(json: response) {
                self.completion(alias,nil)
                return
            }
            
            if let error = self.error(json: response) {
                self.completion(nil,error)
                return
            }
            self.completion(nil,"An unknown error occured")
        }
    }
    
    func map(json:Any?) -> String? {
        guard let jsonDict = json as? [String:Any],
            let client = jsonDict["client"] as? [String:Any],
            let alias = client["alias"] as? String else { return nil }
        
        return alias
    }
    
    func error(json:Any?) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}
