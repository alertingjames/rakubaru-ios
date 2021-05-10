//
//  Route.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import Foundation

class Route {
    var idx:Int64 = 0
    var user_id:Int64 = 0
    var assign_id:Int64 = 0
    var name:String = ""
    var description:String = ""
    var start_time:String = ""
    var end_time:String = ""
    var duration:Int64 = 0
    var speed:Double = 0
    var distance:Double = 0
    var status:String = ""
    var area_name:String = ""
    var assign_title:String = ""
}

var gRoute = Route()
