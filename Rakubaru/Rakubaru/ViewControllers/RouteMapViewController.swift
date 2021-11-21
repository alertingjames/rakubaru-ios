//
//  RouteMapViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import GoogleMaps
import CoreLocation
import AddressBookUI
import Alamofire
import SwiftyJSON

class RouteMapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    @IBOutlet weak var mapViewButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var manager = CLLocationManager()
    var map = GMSMapView()
    var myMarker:GMSMarker? = nil
    var circle:GMSCircle? = nil
    var camera: GMSCameraPosition? = nil
    var thisUserLocation:CLLocationCoordinate2D? = nil
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    @IBOutlet weak var speedBox: UILabel!
    
    var loadingDialog:LoadingDialog!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingDialog = (self.storyboard!.instantiateViewController(withIdentifier: "LoadingDialog") as! LoadingDialog)
        
        backButton.layer.cornerRadius = 5
        mapViewButton.layer.cornerRadius = 5
        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        mapViewButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        locationButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        
        // User Location
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
        if gPoints.count > 100 {
            showLoadingDialog()
        }
        
        if gRoute.assign_id > 0 {
            getRouteArea(route_id: gRoute.idx)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("My Location = \(userLocation)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            if thisUserLocation == nil{
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 16.0, bearing: 0, viewingAngle: 0)
                map = GMSMapView.map(withFrame: self.mapView.frame, camera: camera!)
//                map.animate(to: camera!)
                map.delegate = self
                self.mapView.addSubview(map)
                map.isMyLocationEnabled = true
                map.isBuildingsEnabled = true
                map.settings.myLocationButton = false
                map.mapType = .normal
//                map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 5)                
                drawRoute()
            }else{
                let currentZoom = self.map.camera.zoom;
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: currentZoom, bearing: 0, viewingAngle: 0)
//                map.animate(to: camera!)
            }
            thisUserLocation = center
            
        }
        
    }
    
    func drawRoute() {
        
        for pin in gPins {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lng)
            let title = pin.comment.lowercased()
            marker.title = title.capitalizingFirstLetter()
            let snippet = pin.time.replacingOccurrences(of: "AM", with: "午前").replacingOccurrences(of: "PM", with: "午後").lowercased()
            marker.snippet = snippet.capitalizingFirstLetter()
            marker.map = self.map
            marker.icon = UIImage(named: "targetmarker")
            marker.appearAnimation = .pop
            map.selectedMarker = marker
        }
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: gPoints[0].lat, longitude: gPoints[0].lng)
        marker.isFlat = true
        let title1 = "開始".lowercased()
        marker.title = title1.capitalizingFirstLetter()
        marker.map = self.map
        marker.appearAnimation = .pop
        map.selectedMarker = marker
        
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: gPoints.last!.lat, longitude: gPoints.last!.lng)
        marker.isFlat = true
        let title2 = "終了".lowercased()
        marker.title = title2.capitalizingFirstLetter()
        marker.map = self.map
        marker.appearAnimation = .pop
        map.selectedMarker = marker
        
        distanceBox.text = String(format: "%.2f", gRoute.distance) + "km"
        durationBox.text = getDurationFromMilliseconds(ms: gRoute.duration)
        speedBox.text = String(format: "%.2f", gRoute.speed) + "km/h"
        
        var bounds = GMSCoordinateBounds()
        for point in gPoints {
            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng))
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
        map.animate(with: update)
        
        var pts = [Point]()
        for point in gPoints {
            pts.append(point)
            let path = GMSMutablePath()
            if pts.count > 1 {
                let lastPoint1 = pts[pts.count - 2]
                let lastPoint2 = pts.last
                path.addLatitude(lastPoint1.lat, longitude: lastPoint1.lng)
                path.addLatitude(lastPoint2!.lat, longitude: lastPoint2!.lng)
                
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 5.0

                print("Color: \(point.color)")
                
                if point.color == "" { polyline.strokeColor = .red }
                else { polyline.strokeColor = UIColor(hexString: point.color.replacingOccurrences(of: "#", with: "")) }
                polyline.geodesic = true
                polyline.map = map
                
                if point.idx == gPoints.last?.idx {
                    dismissLoadingDialog()
                }
                
            }
        }
    }
    
    func showLoadingDialog() {
        loadingDialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        loadingDialog.messageBox.text = "データのロード。。。"
        self.addChild(self.loadingDialog)
        self.view.addSubview(self.loadingDialog.view)
    }
    
    func dismissLoadingDialog() {
        self.loadingDialog.removeFromParent()
        self.loadingDialog.view.removeFromSuperview()
        self.loadingDialog.alertView.alpha = 1
    }

    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    @IBAction func toggleMapView(_ sender: Any) {
        if map != nil {
            if map.mapType == .normal {
                map.mapType = .satellite
                mapViewButton.setImage(UIImage(named: "map.png"), for: .normal)
            }else {
                map.mapType = .normal
                mapViewButton.setImage(UIImage(named: "satellite.png"), for: .normal)
            }
        }
    }
    
    @IBAction func moveToMyLocation(_ sender: Any) {
        if thisUserLocation != nil {
            camera = GMSCameraPosition.camera(withLatitude: (thisUserLocation!.latitude), longitude: (thisUserLocation!.longitude), zoom: 16.0, bearing: 0, viewingAngle: 0)
            map.animate(to: camera!)
        }
    }
    
    func getRouteArea(route_id:Int64) {
        
        let params = [
            "route_id":String(route_id),
        ] as [String : Any]
        
        Alamofire.request(SERVER_URL + "routearea", method: .post, parameters: params).responseJSON { response in
            let json = JSON(response.result.value!)
            NSLog("\(json)")
            if(json["result_code"].stringValue == "0"){
                var areas = [Area]()
                let data = json["data"].object as! [String: Any]
                let areaObj = data["area"] as! [String: Any]
                
                let area = Area()
                area.areaName = areaObj["area_name"] as! String
                
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
                
                self.drawArea(coords: area.coords)
                
                let sublocArr = data["sublocs"] as! [[String: Any]]
                var sublocs = [Subloc]()
                for data in sublocArr{
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
                
                self.drawSubareas(sublocs: sublocs)
                
            }
        }
        
    }
    
    
    func drawSubareas(sublocs:[Subloc]) {
        var bounds = GMSCoordinateBounds()
        var polygons = [GMSPolygon]()
        for subloc in sublocs {
            let path = GMSMutablePath()
            for coord in subloc.coords {
                path.add(coord)
                bounds = bounds.includingCoordinate(coord)
            }
            let polygon = GMSPolygon(path: path)
            polygon.strokeColor = hexStringToUIColor(hex: subloc.color, alpha: 0.8)
            polygon.fillColor = hexStringToUIColor(hex: subloc.color, alpha: 0.2)
            polygon.strokeWidth = 1.0
            polygon.map = map
            polygons.append(polygon)
        }

//        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
//        map.animate(with: update)
    }
    
    func drawArea(coords:[CLLocationCoordinate2D]) {
        var bounds = GMSCoordinateBounds()
        let path = GMSMutablePath()
        for coord in coords {
            bounds = bounds.includingCoordinate(coord)
            path.add(coord)
        }
//        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
//        map.animate(with: update)

        let polygon = GMSPolygon(path: path)
        polygon.strokeColor = UIColor(rgb: 0xFF0000, alpha: 0.8)
        polygon.fillColor = UIColor(rgb: 0xFF0000, alpha: 0.2)
        polygon.strokeWidth = 1.0
        polygon.map = map
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker.snippet != nil {
            let infoView:MarkerView = (Bundle.main.loadNibNamed("MarkerView", owner: self, options: nil)!.first as? MarkerView)!
            let frame = CGRect(x: 10, y: 10, width: 200, height: infoView.frame.height)
            infoView.frame = frame
            infoView.titleBox.text = marker.title
            infoView.timeBox.text = marker.snippet
            return infoView
        }else {
            return nil
        }
    }
    
}
