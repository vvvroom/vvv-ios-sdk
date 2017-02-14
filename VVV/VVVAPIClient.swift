//
//  VVVAPIClient.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2016 James Swiney. All rights reserved.
//

import Foundation

public class VVVAPI {
    
    public class func setupWith(key:String) {
        VVVConfig.sharedInstance.authToken = "Basic \(key)"
        VVVAPIClient.sharedInstance.setup()
    }
    
}

public class VVVAPIClient : VVVAPIRequestPerformer {
    
    public static let sharedInstance = VVVAPIClient()
    let urlSession : URLSession

    public init() {

        let sessionConfig = URLSessionConfiguration.default
        
        if let token = VVVConfig.sharedInstance.authToken {
            sessionConfig.httpAdditionalHeaders = ["Authorization":token]
        } else {
            print("*** VVV authtoken not set, please call VVVAPI.setupWith to set authtoken ***")
        }
        
        urlSession = URLSession(configuration: sessionConfig)
    }
    
    func setup() {
        //ConfigManager init
    }
    
    public func findDepots() {
        
        let request = VVVAPIDepotRequest()
        self.perform(urlSession: urlSession, apiRequest: request)
        
    }
}
