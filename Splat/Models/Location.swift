//
//  SplatLocation.swift
//  Splat
//
//  Created by Aaron Tainter on 3/25/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    /* Use structs to work around class variables */
    struct States {
        static var list = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    }
    
    class func getStates(state: String)->[String]! {
        if let foundIndex = find(Location.States.list, state) {
            var list = Location.States.list
            list.removeAtIndex(foundIndex)
            return list
        }
        return Location.States.list
    }
    
    override init() {
        super.init()
    }
}