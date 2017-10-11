//
//  VVVAPIClient.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

public let VVVAPIClientStatusReadyNotification = "VVVAPIClientStatusReadyNotification"
public let VVVAPIClientStatusFailedNotification = "VVVAPIClientStatusFailedNotification"

/** A singleton object which holds the core Url Session for all api requests, and is responsable for setting up all other singletons. Used mainly to setup the SDK*/
@objc(VVVAPICLient) public class APIClient : NSObject,APIRequestPerformer {
    
    /**
     
     The primary setup function for the SDK, this is called to provide the API key to the APIClient which identifies and authorises all requests sent through the SDK, can take a small amout of time to be ready.  Call this when launching your app and it should be initialised by the time you need to send any requests.
     
     - Parameters:
        - key: Your API Key for the VVV SDK provide by VVV.
        - domain: Your domain link provided by VVV.
     
     */
    public class func setupWith(key:String,domain:String) {
        Config.shared.authToken = "Basic \(key)"
        Config.shared.domain = domain
        
        //Init client Singleton
        let client = APIClient.shared
        client.status = .pending
        
        //Setup the SDK Alias
        Config.shared.fetchAlias { (success) in
            
            if success {
                client.status = .ready
                NotificationCenter.default.post(name: NSNotification.Name(VVVAPIClientStatusReadyNotification), object: nil)
            } else {
                client.status = .failed
                NotificationCenter.default.post(name: NSNotification.Name(VVVAPIClientStatusFailedNotification), object: nil)
            }
            
            //Init location manager
            _ = LocationManager.shared
            
            //Init supplier manager
            _ = SupplierManager.shared
        }
    }
    
    /** The current Status of the APIClient*/
    public private(set) var status = APIClientStatus.notready
    
    
    /** The accessor for the API client singleton */
    static let shared = APIClient()
    
    /** The primary url session used for all API Requests */
    let urlSession : URLSession
    

    /** Init creates session with auth header token from Config (this should not be called only call setupWith(key:) */
    override init() {

        let sessionConfig = URLSessionConfiguration.default
        
        if Config.shared.authToken == nil {
            print("*** VVV authtoken not set, please call APIClient.setupWith to set authtoken ***")
        }
        
        urlSession = URLSession(configuration: sessionConfig)
        super.init()
    }
    
}

/**
 The status's the APIClient can be during setup.
 
 - notready: setupWith(key:String,domain:String) has not been called yet
 - pending: setupWith(key:String,domain:String) has been called and we are waiting for success callback.
 - ready: The API client is ready to perform searches and bookings.
 - failed: The API client failed setup please check credentials and try again.
 
 */
@objc(VVVAPIClientStatus) public enum APIClientStatus : Int,RawRepresentable {
    case notready = 0
    case pending = 1
    case ready = 2
    case failed = 3
}
