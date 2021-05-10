//
//  Area.swift
//  Rakubaru
//
//  Created by LGH on 3/18/21.
//

import Foundation
import GoogleMaps
import CoreLocation

class Area {
    var idx:Int64 = 0
    var user_id:Int64 = 0
    var areaName:String = ""
    var title:String = ""
    var distribution:String = ""
    var startTime:Int64 = 0
    var endTime:Int64 = 0
    var copies:Int64 = 0
    var unitPrice:Double = 0
    var allowance:Int64 = 0
    var amount:Double = 0
    var distance:Double = 0
    var myDistance:Double = 0
    var status:String = ""
    var coords = [CLLocationCoordinate2D]()
    var sublocs = [Subloc]()
}

var gArea = Area()

