//
//  DepotResponse.swift
//  VVV
//
//  Created by James Swiney on 17/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** A object will the depot information for a Booking and search.  Contains the pickup and return depots and the supplier. */
@objc(VVVDepotPair) public class DepotPair : NSObject {
    
    /** The supplier of the depots */
    public let supplier : Supplier
    
    /** The depot to pick the vehicle up from */
    public let pickupDepot : Depot
    
    /** The depot to return the vehicle (can be the same as pickupDepot) */
    public let returnDepot : Depot
    
    
    
    /**
     
     Standard mapping init method for Nearby Depots request.
     
     - Parameters:
        - json: The json object from the nearby depots request.
        - supplierCode: the Supplier code for the depots eg. "HZ"
     
     */
    init?(json:[String:Any],supplierCode:String) {
        guard let supplier = SupplierManager.shared.supplierFor(code: supplierCode),
            let pickupDepots = json["pickUpDepot"] as? [[String:Any]],
            let returnDepots = json["returnDepot"] as? [[String:Any]] else { return nil }
        
        self.supplier = supplier
        
        var pickups = [Depot]()
        var returns = [Depot]()
        
        for object in pickupDepots {
            guard let depot = Depot(json: object, supplier: self.supplier) else { continue }
            pickups.append(depot)
        }
        
        for object in returnDepots {
            guard let depot = Depot(json: object, supplier: self.supplier) else { continue }
            returns.append(depot)
        }
        
        if pickups.count == 0 || returns.count == 0 {
            return nil
        }
        
        //We only want the closest depots for pickup and return so sort by distance
        pickups.sort { (depot1, depot2) -> Bool in
            guard let distance1 = depot1.distance,
                let distance2 = depot2.distance else { return false }
            return distance1 < distance2
        }
        returns.sort { (depot1, depot2) -> Bool in
            guard let distance1 = depot1.distance,
                let distance2 = depot2.distance else { return false }
            return distance1 < distance2
        }
        
        self.pickupDepot = pickups[0]
        self.returnDepot = returns[0]
        
        super.init()
    }
    
    /**
     
     Standard mapping init method for PendingBooking and Booking objects
     
     - Parameters:
     - json: The json object from the PendingBooking and Booking objects
     - supplierCode: the Supplier code for the depots eg. "HZ"
     
     */
    init?(bookingJson:[String:Any],supplierCode:String) {
        guard let supplier = SupplierManager.shared.supplierFor(code: supplierCode),
            let pickupDepotJson = bookingJson["pickupDepot"] as? [String:Any],
            let returnDepotJson = bookingJson["returnDepot"] as? [String:Any],
            let pickupDepot = Depot(bookingJson: pickupDepotJson, supplier: supplier),
            let returnDepot = Depot(bookingJson: returnDepotJson, supplier: supplier) else { return nil }
        
        self.supplier = supplier
        self.pickupDepot = pickupDepot
        self.returnDepot = returnDepot
        
        super.init()
    }
}
