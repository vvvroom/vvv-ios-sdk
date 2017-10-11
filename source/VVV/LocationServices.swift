//
//  LocationServices.swift
//  VVV
//
//  Created by James Swiney on 16/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServicesDelegate {
    
    func currentLocationUpdated(location:CLLocation)
    
}

/** An object to manage core location services, authorisation and current location updates */
class LocationServices : NSObject {
    
    /** The Location manager */
    let coreManager : CLLocationManager
    
    /** Stores the current location once updated from the coreManager */
    var currentLocation : CLLocation?
    
    /** The delegate to provice location updates */
    var delegate : LocationServicesDelegate?
    
    /** Checks the auth status to determine whether the first time prompt has shown up. */
    var userHasSeenAuthPrompt : Bool { get {
        let status = CLLocationManager.authorizationStatus()
        return status != .notDetermined
        }
    }
    
    /** A block that will call back once authrisation prompt has been tapped. */
    var authoriseBlock : ((CLLocation?)->())?
    
    /** Standard init sets notifcation monitoring and sets up coreManager  */
    override init() {
        coreManager = CLLocationManager()
        super.init()
        coreManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLocationUpdates), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    /**
     
     Checks auth status and if it is notDetermined will trigger request that will pop up authorisation alert.
     If it doesn't show the alert will callback immediately with the current location if available.
     
     - Parameters:
        - completion: the block to be called once the auth prompt has been dismissed, contains current location if available.
     
     */
    func authorise(completion:@escaping (CLLocation?)->()) {
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            self.authoriseBlock = completion
            coreManager.requestWhenInUseAuthorization()
        } else {
            completion(self.currentLocation)
        }
    }
    
}

//MARK: - Service start and stop
extension LocationServices {
    
    /**
     
     Called when recieved the app became active notification, and checks status and starts location updates.  If authorisation is denied will clear any saved current location.

     */
    @objc func appBecameActive() {
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted  {
            self.currentLocation = nil
        }
        startLocationUpdates()
    }
    
    /**
     
     Checks auth status and if available starts significant change location updates (saves power over normal location updates).
     
     */
    func startLocationUpdates() {
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.denied {
            print("location Auth Denied")
            return
        }
        
        if status == CLAuthorizationStatus.restricted {
            print("location Auth Restricted")
            return
        }
        
        if status == CLAuthorizationStatus.notDetermined {
            return
        }
        
        coreManager.startMonitoringSignificantLocationChanges()
    }
    
    /**
     
     Stop location updates, triggered when app enters background notification if called.
     
     */
    @objc func stopLocationUpdates() {
        coreManager.stopMonitoringSignificantLocationChanges()
    }
    
}

//MARK: - LocationManagerDelegate
extension LocationServices : CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            coreManager.startUpdatingLocation()
        } else {
            if let block = self.authoriseBlock {
                block(self.currentLocation)
                self.authoriseBlock = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        self.currentLocation = location
        
        if let block = self.authoriseBlock {
            block(self.currentLocation)
            self.authoriseBlock = nil
        }
        if let delegate = self.delegate {
            delegate.currentLocationUpdated(location: location)
        }
    }
    
}
