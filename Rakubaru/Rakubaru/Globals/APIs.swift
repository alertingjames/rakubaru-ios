//
//  APIs.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import SwiftyJSON
import Alamofire
import GoogleMaps
import CoreLocation

class APIs {
    
    static func login(email : String, password: String, device:String, handleCallback: @escaping (User?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "email":email,
            "password":password,
            "device":device
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "login", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                
                NSLog("login result: \(json)")
                
                let result_code = json["result_code"].stringValue
                
                if result_code != nil {
                    if(result_code == "0"){
                        
                        let data = json["data"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.picture_url = data["picture_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.status = data["status"] as! String
                        
                        handleCallback(user, result_code)
                    
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func forgotPassword(email : String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "email":email
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "forgotpassword", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    handleCallback("0")
                }
                else if(json["result_code"].stringValue == "1"){
                    handleCallback("1")
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func getMyRoutes(member_id: Int64, handleCallback: @escaping ([Route]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getmyroutes", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    var routes = [Route]()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        let route = Route()
                        route.idx = data["id"] as! Int64
                        route.assign_id = Int64(data["assign_id"] as! String)!
                        route.user_id = Int64(data["member_id"] as! String)!
                        route.name = data["name"] as! String
                        route.description = data["description"] as! String
                        route.start_time = data["start_time"] as! String
                        route.end_time = data["end_time"] as! String
                        route.duration = Int64(data["duration"] as! String)!
                        route.speed = Double(data["speed"] as! String)!
                        route.distance = Double(data["distance"] as! String)!
                        route.status = data["status"] as! String
                        route.area_name = data["area_name"] as! String
                        route.assign_title = data["assign_title"] as! String
                        
                        let status2 = data["status2"] as! String
                        if status2.count == 0 {
                            routes.append(route)
                        }
                    }
                    
                    handleCallback(routes, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func deleteRoute(route_id: Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "route_id":String(route_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "delroute", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue != nil){
                    handleCallback(json["result_code"].stringValue)
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func reportRoute(route_id: Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "route_id":String(route_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "reportroute", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue != nil){
                    handleCallback(json["result_code"].stringValue)
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func getRouteDetails(route_id: Int64, handleCallback: @escaping ([Point]?, String) -> ())
    {
        //NSLog(url)
        let params = [
            "route_id":String(route_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "routedetails", method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    var points = [Point]()
                    let dataArray = json["points"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        let point = Point()
                        point.idx = data["id"] as! Int64
                        point.comment = data["comment"] as! String
                        point.color = data["color"] as! String
                        point.time = data["time"] as! String
                        point.lat = Double(data["lat"] as! String)!
                        point.lng = Double(data["lng"] as! String)!
                        point.status = data["status"] as! String
                        points.append(point)
                    }
                    
                    handleCallback(points, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func saveRoute(member_id: Int64, name:String, description:String, start_time:String, end_time:String, duration:Int64, speed:Double, distance:Double, points:String, status:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "name":name,
            "description":description,
            "start_time": start_time,
            "end_time": end_time,
            "duration": String(duration),
            "speed": String(speed),
            "distance": String(distance),
            "points": points,
            "status": status
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "uploadroute", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Route saving: \(json)")
                if(json["result_code"].stringValue != nil){
                    handleCallback(json["result_code"].stringValue)
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func savePin(member_id: Int64, pin_id:Int64, comment:String, time:String, lat:Double, lng:Double, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "pin_id":String(pin_id),
            "comment":comment,
            "time": time,
            "lat": String(lat),
            "lng": String(lng),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "savepin", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue != nil){
                    let pin_id = json["pin_id"].stringValue
                    let result_code = json["result_code"].stringValue
                    handleCallback(pin_id, result_code)
                }else{
                    handleCallback("", "Server issue")
                }
                
            }
        }
    }
    
    static func deletePin(pin_id: Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "pin_id":String(pin_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "delpin", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue != nil){
                    handleCallback(json["result_code"].stringValue)
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func getPins(member_id: Int64, handleCallback: @escaping ([Point]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "getmypins", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    var pins = [Point]()
                    let dataArray = json["pins"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        let pin = Point()
                        pin.idx = data["id"] as! Int64
                        pin.comment = data["comment"] as! String
                        pin.time = data["time"] as! String
                        pin.lat = Double(data["lat"] as! String)!
                        pin.lng = Double(data["lng"] as! String)!
                        pin.status = data["status"] as! String
                        
                        pins.append(pin)
                    }
                    
                    handleCallback(pins, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func logOut(member_id: Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "logout", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue != nil){
                    handleCallback(json["result_code"].stringValue)
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    func registerWithPicture(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,withImages imageArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Image Array
            for (imageDic) in imageArray
            {
                let imageDic = imageDic as! NSDictionary
                
                for (key,valus) in imageDic
                {
                    MultipartFormData.append(valus as! Data, withName:key as! String, fileName: String(NSDate().timeIntervalSince1970) + ".jpg", mimeType: "image/jpg")
                }
            }
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    func registerWithoutPicture(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    static func passwordUpdate(member_id:Int64, password : String, handleCallback: @escaping (User?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "password":password
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "passwordupdate", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                
                NSLog("login result: \(json)")
                
                let result_code = json["result_code"].stringValue
                
                if result_code != nil {
                    if(result_code == "0"){
                        
                        let data = json["data"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.picture_url = data["picture_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.status = data["status"] as! String
                        
                        handleCallback(user, result_code)
                    
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func checkDevice(member_id: Int64, device:String, handleCallback: @escaping (String,String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "device": device
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "checkdevice", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    handleCallback("0", json["status"].stringValue)
                }else if (json["result_code"].stringValue == "1") {
                    handleCallback("1", "")
                }
                else{
                    handleCallback("", "Server issue")
                }
                
            }
        }
    }
    
    
    static func checkRouteLoading(member_id: Int64, handleCallback: @escaping (String,String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "checkrouteloading", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    handleCallback("0", json["points"].stringValue)
                }else if (json["result_code"].stringValue == "1") {
                    handleCallback("1", "0")
                }
                else{
                    handleCallback("", "Server issue")
                }
                
            }
        }
    }
    
    static func getMyAreas(member_id: Int64, handleCallback: @escaping ([Area]?, String) -> ())
    {
        //NSLog(url)
        
        Alamofire.request(SERVER_URL + "getAssignedAreas?member_id=" + String(member_id)).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    var areas = [Area]()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let json = JSON(data)
                        let assignObj = json["assign"].object as! [String: Any]
                        let areaObj = json["area"].object as! [String: Any]

                        let area = Area()
                        area.idx = assignObj["id"] as! Int64
                        area.user_id = Int64(assignObj["member_id"] as! String)!
                        area.areaName = areaObj["area_name"] as! String
                        area.title = assignObj["title"] as! String
                        let start_time = assignObj["start_time"] as! String
                        if start_time != "" {
                            area.startTime = Int64(start_time)!
                        }else {
                            area.startTime = 0
                        }
                        
                        let end_time = assignObj["end_time"] as! String
                        if end_time != "" {
                            area.endTime = Int64(end_time)!
                        }else {
                            area.endTime = 0
                        }
                        area.distribution = assignObj["distribution"] as! String
                        area.copies = Int64(assignObj["copies"] as! String)!
                        area.amount = Double(assignObj["amount"] as! String)!
                        area.distance = Double(assignObj["distance"] as! String)!
                        area.myDistance = Double(areaObj["client_dist"] as! String)!
                        area.status = assignObj["status"] as! String
                        
                        let locarr = areaObj["locarr"] as! String
                        if locarr.count > 0 {
                            do {
                                // make sure this JSON is in the format we expect
                                if let jsonArray = try JSONSerialization.jsonObject(with: Data(locarr.utf8), options: []) as? [[String: Any]] {
                                    // try to read out a string array
                                    var coords = [CLLocationCoordinate2D]()
                                    for ldata in jsonArray {
                                        let lat = ldata["lat"] as! Double
                                        let lng = ldata["lng"] as! Double
                                        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                        coords.append(coord)
                                    }
                                    area.coords = coords
                                }
                            } catch let error as NSError {
                                print("Failed to load: \(error.localizedDescription)")
                            }
                            
                        }
                        areas.append(area)
                    }
                    
                    handleCallback(areas, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func deleteAssign(assign_id: Int64, handleCallback: @escaping (String) -> ())
    {
        
        Alamofire.request(SERVER_URL + "removeAssign?assign_id=" + String(assign_id)).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue != nil){
                    handleCallback(json["result_code"].stringValue)
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    
    static func getAreaLocations(area_id: Int64, handleCallback: @escaping ([Subloc]?, String) -> ())
    {
        //NSLog(url)
        
        Alamofire.request(SERVER_URL + "getAreaSublocs?assign_id=" + String(area_id)).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    var sublocs = [Subloc]()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let subloc = Subloc()
                        subloc.idx = data["id"] as! Int64
                        subloc.locationName = data["loc_name"] as! String
                        let lat = Double(data["lat"] as! String)!
                        let lng = Double(data["lng"] as! String)!
                        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        subloc.latLng = coord
                        subloc.color = data["color"] as! String
                        
                        var locarr = data["locarr"] as! String
                        locarr = locarr.replacingOccurrences(of: "'", with: "\"")
                        if locarr.count > 0 {
                            do {
                                // make sure this JSON is in the format we expect
                                if let jsonArray = try JSONSerialization.jsonObject(with: Data(locarr.utf8), options: []) as? [[String: Any]] {
                                    // try to read out a string array
                                    var coords = [CLLocationCoordinate2D]()
                                    for ldata in jsonArray {
                                        let lat = ldata["lat"] as! Double
                                        let lng = ldata["lng"] as! Double
                                        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                        coords.append(coord)
                                    }
                                    subloc.coords = coords
                                }
                            } catch let error as NSError {
                                print("Failed to load: \(error.localizedDescription)")
                            }
                        }
                        
                        sublocs.append(subloc)
                    }
                    
                    handleCallback(sublocs, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func uploadRealTimeRoute(route_id:Int64, assign_id:Int64, member_id: Int64, name:String, description:String, start_time:String, end_time:String, duration:Int64, speed:Double, distance:Double, status:String, lat:Double, lng:Double, comment:String, color:String, pulse:Bool, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        
        var pulseVal = "0"
        if pulse {
            pulseVal = "1"
        }
        
        let params = [
            "route_id":String(route_id),
            "assign_id":String(assign_id),
            "member_id":String(member_id),
            "name":name,
            "description":description,
            "start_time": start_time,
            "end_time": end_time,
            "duration": String(duration),
            "speed": String(speed),
            "distance": String(distance),
            "status": status,
            "lat":String(lat),
            "lng":String(lng),
            "comment":comment,
            "color":color,
            "pulse":pulseVal
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "upRTRoute", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Route saving: \(json)")
                if(json["result_code"].stringValue == "0"){
                    handleCallback(json["route_id"].stringValue, json["result_code"].stringValue)
                }else{
                    handleCallback("", "Server issue")
                }
                
            }
        }
    }
    
    static func getMyCumulativeDistance(member_id: Int64, handleCallback: @escaping (Double, String) -> ())
    {
        //NSLog(url)
        
        Alamofire.request(SERVER_URL + "getMyCumulativeDistance?member_id=" + String(member_id)).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(0, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    
                    handleCallback(Double(json["cumulative"].stringValue)!, "0")
                    
                }
                else{
                    handleCallback(0, "Server issue")
                }
                
            }
        }
    }
    
    
    func uploadJsonFile(withUrl strURL: String,withParam postParam: Dictionary<String, Any>, withFiles fileArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Image Array
            for (fileDic) in fileArray
            {
                let fileDic = fileDic as! NSDictionary
                
                for (key,valus) in fileDic
                {
                    MultipartFormData.append(valus as! Data, withName:key as! String, fileName: String(NSDate().timeIntervalSince1970) + ".json", mimeType: "application/json")
                }
            }
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    
    ///////////////////////////////////////////  background request /////////////////////////////////////////////////////////////////////////////////
    
    func testBackgroundRequest() {
        
//        var sessionManager: Alamofire.SessionManager
//        var backgroundSessionManager: Alamofire.SessionManager
//        self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
//        self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.youApp.identifier.backgroundtransfer"))
//
//
//        backgroundSessionManager.upload(multipartFormData: blockFormData!, usingThreshold: UInt64.init(), to: url, method: .post, headers: APIManager.headers(), encodingCompletion: { encodingResult in
//        switch encodingResult {
//        case .success(let upload, _, _):
//            upload.uploadProgress {
//                (progress) in
//                let p = progress.fractionCompleted * 100
//                uploadProgress(p)
//            }
//            upload.responseJSON { response in
//                switch(response.result) {
//                case .success(let JSON):
//                    DispatchQueue.main.async {
//                            print(JSON)
//                    }
//                case .failure(let error):
//                    DispatchQueue.main.async {
//                        print(error)
//                    }
//                }
//            }
//        case .failure(let error):
//            DispatchQueue.main.async {
//                print(error)
//            }
//        }
//        })
        
    }
    
    
}

























































