//
//  Commons.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import Foundation
import UIKit

/////////// Color //////////////////
var primaryColor = UIColor(rgb: 0xffc107, alpha: 1.0)
var primaryDarkColor = UIColor(rgb: 0xff9800, alpha: 1.0)

var s00_02 = UIColor(rgb: 0xe60012, alpha: 1.0)
var s02_04 = UIColor(rgb: 0xf39800, alpha: 1.0)
var s04_06 = UIColor(rgb: 0xfff100, alpha: 1.0)
var s06_08 = UIColor(rgb: 0x8fc31f, alpha: 1.0)
var s08_16 = UIColor(rgb: 0x009944, alpha: 1.0)
var s16_32 = UIColor(rgb: 0x00a0e9, alpha: 1.0)
var s32_64 = UIColor(rgb: 0x0068b7, alpha: 1.0)
var s64_100 = UIColor(rgb: 0x1d2088, alpha: 1.0)


////////// Request URL /////////////////
let SERVER_URL = "https://www.rakubaru-posting.com/rakubaru/"


/////////// Map ////////////////////////////////
var RADIUS:Float = 15.24
var baseUrl:String = "https://maps.googleapis.com/maps/api/geocode/json?"
var apikey:String = "AIzaSyBR4FwW8dPoTLk9nsxazxfYG5ErlDMhWhk"


////////  Variables ///////////////////////////
var gAutoReport:Bool = true
var gRoutesOption:String = ""

///////// ViewController //////////////////////////
var gRecentVC:UIViewController!
var gHomeVC:HomeViewController!
var gMyRoutesVC:MyRoutesViewController!
var gReportsVC:ReportsViewController!
var gAreasVC:AreasViewController!
