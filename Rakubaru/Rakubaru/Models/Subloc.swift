//
//  Subloc.swift
//  Rakubaru
//
//  Created by LGH on 3/18/21.
//

import Foundation
import GoogleMaps
import CoreLocation

class Subloc {
    var idx:Int64 = 0
    var area_id:Int64 = 0
    var locationName:String = ""
    var color:String = ""
    var latLng:CLLocationCoordinate2D? = nil
    var coords = [CLLocationCoordinate2D]()
}
