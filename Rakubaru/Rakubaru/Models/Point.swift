//
//  Point.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import Foundation

class Point {
    var idx:Int64 = 0
    var route_id:Int64 = 0
    var comment:String = ""
    var time:String = ""
    var color:String = ""
    var lat:Double = 0
    var lng:Double = 0
    var status:String = ""
}

var gPoints = [Point]()
var gPins = [Point]()
