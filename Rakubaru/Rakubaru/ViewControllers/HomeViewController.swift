//
//  HomeViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import DropDown
import GoogleMaps
import GooglePlaces
import CoreLocation
import AddressBookUI
import SwiftyJSON

class HomeViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var manager = CLLocationManager()
    var map = GMSMapView()
    var myMarker:GMSMarker? = nil
    var circle:GMSCircle? = nil
    var camera: GMSCameraPosition? = nil
    var thisUserLocation:CLLocationCoordinate2D? = nil
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    @IBOutlet weak var speedBox: UILabel!
    
    var isLocationRecording:Bool = false
    var totalDistance:Double = 0.0
    var speed:Double = 0.0
    var mSpeed:Double = 0.0
    var duration:Int64 = 0
    var startedTime:Int64 = 0
    var endedTime:Int64 = 0
    var polylines = [GMSPolyline]()
    var traces = [Point]()
    var traces1 = [Point]()
    var markers = [GMSMarker]()
    
    var routeSaveBox:RouteSaveBox!
    var questionDialog:QuestionDialog!
    var loadingDialog:LoadingDialog!
    var pintSaveBox:PinSaveBox!
    
    var route:Route!
    var coordinate:CLLocationCoordinate2D!
    var marker:GMSMarker!
    var pin:Point!
    var isMyLocation:Bool = false
    
    var timer: Timer!
    var isLoading:Bool = false
    var savingPoints:Int64 = 0
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var areaNameBox: UILabel!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var copiesBox: UILabel!
    @IBOutlet weak var amountBox: UILabel!
    @IBOutlet weak var distBox: UILabel!
    @IBOutlet weak var timeBox: UILabel!
    @IBOutlet weak var durBox: UILabel!
    @IBOutlet weak var distributionBox: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var routeID:Int64 = 0
    var assignID:Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gHomeVC = self
        
        container.visibility = .gone
        closeButton.setImageTintColor(.blue)
        
        gAutoReport = true
        UserDefaults.standard.setValue(true, forKey: "auto_report")
        
        routeSaveBox = (self.storyboard!.instantiateViewController(withIdentifier: "RouteSaveBox") as! RouteSaveBox)
        questionDialog = (self.storyboard!.instantiateViewController(withIdentifier: "QuestionDialog") as! QuestionDialog)
        loadingDialog = (self.storyboard!.instantiateViewController(withIdentifier: "LoadingDialog") as! LoadingDialog)
        pintSaveBox = (self.storyboard!.instantiateViewController(withIdentifier: "PinSaveBox") as! PinSaveBox)
        
        menuBtn.layer.cornerRadius = 5
        settingsBtn.layer.cornerRadius = 5
        menuBtn.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        settingsBtn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        locationBtn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        startBtn.layer.cornerRadius = startBtn.frame.height / 2
        panelView.layer.cornerRadius = 8
        panelView.isHidden = true
        
        timeBox.numberOfLines = 0

        // User Location
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
        if CLLocationManager.locationServicesEnabled() {
            disableLocationManager()
            // manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
        isLocationRecording = false
        totalDistance = 0
        speed = 0
        duration = 0
        startedTime = 0
        endedTime = 0
        
        // Move this viewcontroller to background by clicking on Home Button
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        // Move this viewcontroller to foreground by clicking on app icon
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
    }
    
    @objc func appToBackground(notification: NSNotification) {
        print("Moved to background")
        checkDevice(member_id: thisUser.idx, device: getDeviceID())
        endCheckLoading()
    }
    
    @objc func appToForeground(notification: NSNotification) {
        print("Moved to foreground.")
        checkDevice(member_id: thisUser.idx, device: getDeviceID())
        startCheckLoading()
    }
    
    @objc override func viewWillAppear(_ animated: Bool) {
        if isLocationRecording {
            distanceBox.text = String(format: "%.2f", totalDistance) + "km"
            duration = Date().currentTimeMillis() - startedTime
            durationBox.text = getDurationFromMilliseconds(ms:duration)
            if duration > 1000 {
                speed = totalDistance * 3600 / (Double(duration) / 1000)
            }else {
                speed = totalDistance * 3600 / 1
            }
            speedBox.text = String(format: "%.2f", speed) + "km/h"
            
        }
        
        checkDevice(member_id: thisUser.idx, device: getDeviceID())
    }
    
    func reset() {
        startedTime = Date().currentTimeMillis()
        clearPolylines()
        totalDistance = 0
        duration = 0
        panelView.isHidden = true
    }
    
    func clearPolylines() {
        for polyline in polylines {
            polyline.map = nil
        }
        polylines.removeAll()
        traces.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("My Location = \(userLocation)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            if thisUserLocation == nil{
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 16.0, bearing: 0, viewingAngle: 0)
                map = GMSMapView.map(withFrame: self.mapView.frame, camera: camera!)
                map.animate(to: camera!)
                map.delegate = self
                self.mapView.addSubview(map)
                map.isMyLocationEnabled = true
                map.isBuildingsEnabled = true
                map.settings.myLocationButton = false
                map.mapType = .normal
//                map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 5)
                getPins()
            }else{
                let currentZoom = self.map.camera.zoom;
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: currentZoom, bearing: 0, viewingAngle: 0)
                if !isMyLocation {
                    map.animate(to: camera!)
                    isMyLocation = true
                }
            }
            thisUserLocation = center
            if thisUserLocation != nil && isLocationRecording {
                drawRoute(loc: thisUserLocation!)
            }
            
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        self.marker = nil
        self.pin = nil
        pintSaveBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        self.pintSaveBox.titleBox.text = "ピンを刺す"
        self.pintSaveBox.commentBox.text = ""
        self.pintSaveBox.commentBox.becomeFirstResponder()
        self.pintSaveBox.buttonWidth.constant = screenWidth - 120
        self.pintSaveBox.buttonWidth2.constant = 0
        self.addChild(self.pintSaveBox)
        self.view.addSubview(self.pintSaveBox.view)
        self.coordinate = coordinate
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("InfoView tapped")
        let mks = markers.filter{ mk in
            return mk.position.latitude == marker.position.latitude && mk.position.longitude == marker.position.longitude
        }
        if mks.count > 0 {
            let pins = gPins.filter{ pin in
                return pin.lat == mks[0].position.latitude && pin.lng == mks[0].position.longitude
            }
            if pins.count > 0 {
                self.pin = pins[0]
                print("Selected pin: \(self.pin.comment) - \(self.pin.idx)")
                self.marker = mks[0]
                pintSaveBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
                self.pintSaveBox.titleBox.text = "ピンコメントの編集"
                self.pintSaveBox.commentBox.text = mks[0].title
                self.pintSaveBox.commentBox.becomeFirstResponder()
                self.pintSaveBox.buttonWidth.constant = (screenWidth - 120)/2
                self.pintSaveBox.buttonWidth2.constant = (screenWidth - 120)/2
                self.addChild(self.pintSaveBox)
                self.view.addSubview(self.pintSaveBox.view)
                self.coordinate = mks[0].position
            }
        }
    }
    
    var lastDistance:Double = 0
    var cnt:Int = 0
    
    func drawRoute(loc:CLLocationCoordinate2D) {
        if isLocationRecording {
            let currentTime = Date().currentTimeMillis()
            if traces.count == 0 {
                let point = Point()
                point.lat = thisUserLocation!.latitude
                point.lng = thisUserLocation!.longitude
                point.time = String(currentTime)
                traces.append(point)
                return
            }
            
            var point1:CLLocationCoordinate2D!
            var point2:CLLocationCoordinate2D!
            
            let path = GMSMutablePath()
            
            let lastRpoint = traces.last
            
            var pulse:Bool = false
            if traces.count >= 2 {
                let lastRpoint0 = traces[traces.count - 2]
                let dist0 = getDistance(from: CLLocationCoordinate2D(latitude: lastRpoint0.lat, longitude: lastRpoint0.lng), to: CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng))
                let dist1 = getDistance(from: CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng), to: CLLocationCoordinate2D(latitude: thisUserLocation!.latitude, longitude: thisUserLocation!.longitude))
                let dist2 = getDistance(from: CLLocationCoordinate2D(latitude: lastRpoint0.lat, longitude: lastRpoint0.lng), to: CLLocationCoordinate2D(latitude: thisUserLocation!.latitude, longitude: thisUserLocation!.longitude))
                if dist2 < dist0 || dist2 < dist1 {
                    pulse = true
                    traces.remove(at: traces.firstIndex(where: {$0.idx == lastRpoint!.idx})!)
                    polylines.last?.map = nil
                    polylines.removeLast()
                    totalDistance = totalDistance - lastDistance * 0.001
                    
                    path.addLatitude(lastRpoint0.lat, longitude: lastRpoint0.lng)
                    path.addLatitude(thisUserLocation!.latitude, longitude: thisUserLocation!.longitude)
                    
                    point1 = CLLocationCoordinate2D(latitude: lastRpoint0.lat, longitude: lastRpoint0.lng)
                    point2 = CLLocationCoordinate2D(latitude: thisUserLocation!.latitude, longitude: thisUserLocation!.longitude)
                    
                }else {
                    path.addLatitude(lastRpoint!.lat, longitude: lastRpoint!.lng)
                    path.addLatitude(thisUserLocation!.latitude, longitude: thisUserLocation!.longitude)
                    
                    point1 = CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng)
                    point2 = CLLocationCoordinate2D(latitude: thisUserLocation!.latitude, longitude: thisUserLocation!.longitude)
                }
            }else {
                path.addLatitude(lastRpoint!.lat, longitude: lastRpoint!.lng)
                path.addLatitude(thisUserLocation!.latitude, longitude: thisUserLocation!.longitude)
                
                point1 = CLLocationCoordinate2D(latitude: lastRpoint!.lat, longitude: lastRpoint!.lng)
                point2 = CLLocationCoordinate2D(latitude: thisUserLocation!.latitude, longitude: thisUserLocation!.longitude)
            }
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            
            ////////////////////     Meter   ///////////////////////
            lastDistance = getDistance(from: point1, to: point2)
            
            ////////     km/h    //////////////////////////////
            var secs = currentTime - Int64(lastRpoint!.time)!
            if secs < 1000 { secs = 1000 }
            mSpeed = lastDistance * 3.6 / ( Double(secs) * 0.001 )
            print("Speed: \(mSpeed) km/h")
            
            polyline.strokeColor = getColorFromSpeed(speed: mSpeed)
            polyline.geodesic = true
            polyline.map = map
            polylines.append(polyline)
            
            totalDistance = totalDistance + lastDistance * 0.001
            distanceBox.text = String(format: "%.2f", totalDistance) + "km"
            duration = currentTime - startedTime
            durationBox.text = getDurationFromMilliseconds0(ms: duration)
            speedBox.text = String(format: "%.2f", mSpeed) + "km/h"
            
            var tSecs = currentTime - Int64(startedTime)
            if tSecs < 1000 { tSecs = 1000 }
            speed = totalDistance * 3600 / ( Double(tSecs) * 0.001 )
            
            let point = Point()
            point.lat = thisUserLocation!.latitude
            point.lng = thisUserLocation!.longitude
            point.time = String(currentTime)
            point.color = getColorFromSpeed(speed: mSpeed).htmlRGBColor
            traces.append(point)
            if !Reachability.isConnectedToNetwork() {
                traces1.append(point)
                print("Offline traces: \(traces1.count)")
            }
            
            if traces.count == 2 {
                traces[0].color = point.color
            }
            
            endedTime = Date().currentTimeMillis()
            let color = getColorFromSpeed(speed: mSpeed).htmlRGBColor
            
            if Reachability.isConnectedToNetwork() {
                if traces1.count > 0 {
                    cnt += 1
                    if cnt > 5 {
                        upRoute()
                    }else {
                        traces1.append(point)
                    }
                }else {
                    uploadRealTimeRoute(route_id: routeID, assign_id: assignID, member_id: thisUser.idx, name: "", description: "", start_time: String(startedTime), end_time: String(endedTime), duration: duration, speed: speed, distance: totalDistance, status: "report", lat: loc.latitude, lng: loc.longitude, comment: "", color: color, end: 1, pulse: pulse)
                }
            }
            
            print("Recording traces: \(traces.count)")
        }
    }
    
    func getColorFromSpeed(speed:Double) -> UIColor {
        var color = s00_02
        if speed >= 0 && speed < 2 { color = s00_02 }
        else if speed >= 2 && speed < 4 { color = s02_04 }
        else if speed >= 4 && speed < 6 { color = s04_06 }
        else if speed >= 6 && speed < 8 { color = s06_08 }
        else if speed >= 8 && speed < 16 { color = s08_16 }
        else if speed >= 16 && speed < 32 { color = s16_32 }
        else if speed >= 32 && speed < 64 { color = s32_64 }
        else if speed >= 64 { color = s64_100 }
        return color
    }
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLoc.distance(from: toLoc)
        return distanceInMeters
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if isLoading { return }
        let dropDown = DropDown()
        dropDown.anchorView = (sender as! AnchorView)
        dropDown.dataSource = [
            "  配布エリア",
//            "  過去ログ（全件）",
            "  過去ログ",
            "  プロフィール"
        ]
        
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AreasViewController")
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
//            else if idx == 1{
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyRoutesViewController")
//                gRoutesOption = "saved_history"
//                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
//            }
            else if idx == 1{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyRoutesViewController")
                gRoutesOption = "reports"
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
            else if idx == 2{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController")
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 14.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 50
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 180
        
        dropDown.show()
    }
    
    @IBAction func moveToMyLocation(_ sender: Any) {
        if thisUserLocation != nil {
            camera = GMSCameraPosition.camera(withLatitude: (thisUserLocation!.latitude), longitude: (thisUserLocation!.longitude), zoom: 16.0, bearing: 0, viewingAngle: 0)
            map.animate(to: camera!)
        }
    }
    
    @IBAction func openSettings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SettingsViewController")
        self.transitionVc(vc: vc!, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        if isLoading { return }
        if isLocationRecording {            
            routeSaveBox = (self.storyboard!.instantiateViewController(withIdentifier: "RouteSaveBox") as! RouteSaveBox)
            routeSaveBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            routeSaveBox.titleBox.text = "ルートに説明を追加します。"
            routeSaveBox.end = 2
            routeSaveBox.nameBox.visibility = .gone
            routeSaveBox.descBox.text = ""
            routeSaveBox.checkBox.visibilityh = .gone
            routeSaveBox.checkBoxLabel.visibilityh = .gone
            if gAutoReport {
                routeSaveBox.checkBox.isChecked = true
            }else {
                routeSaveBox.checkBox.isChecked = false
            }
            self.addChild(self.routeSaveBox)
            self.view.addSubview(self.routeSaveBox.view)
            
        }else {
            routeSaveBox = (self.storyboard!.instantiateViewController(withIdentifier: "RouteSaveBox") as! RouteSaveBox)
            routeSaveBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            routeSaveBox.titleBox.text = "ルートに名前を付けます。"
            routeSaveBox.end = 0
            routeSaveBox.nameBox.text = thisUser.name + "_" + getRouteNameTimeFromTimeStamp(timeStamp: Double(Date().currentTimeMillis()/1000))
            routeSaveBox.descBox.text = ""
            routeSaveBox.descBox.visibility = .gone
            routeSaveBox.checkBox.visibilityh = .gone
            routeSaveBox.checkBoxLabel.visibilityh = .gone
            if gAutoReport {
                routeSaveBox.checkBox.isChecked = true
            }else {
                routeSaveBox.checkBox.isChecked = false
            }
            self.addChild(self.routeSaveBox)
            self.view.addSubview(self.routeSaveBox.view)
        }
        
        checkDevice(member_id: thisUser.idx, device: getDeviceID())
        
    }
    
    func startLocationRecording(name:String) {
        startedTime = Date().currentTimeMillis()
        totalDistance = 0
        duration = 0
        
        savingPoints = 0
        isLoading = false
        
        routeID = 0

        if gArea != nil {
            assignID = gArea.idx
        }
        endedTime = Date().currentTimeMillis()
        let color = getColorFromSpeed(speed: mSpeed).htmlRGBColor
        
        self.uploadRealTimeRoute(route_id: self.routeID, assign_id: self.assignID, member_id: thisUser.idx, name: name, description: "", start_time: String(self.startedTime), end_time: String(self.endedTime), duration: self.duration, speed: self.speed, distance: self.totalDistance, status: "report", lat: thisUserLocation!.latitude, lng: thisUserLocation!.longitude, comment: "", color: color, end: 0, pulse: false)
    }
    
    func enableLocationManager() {
        manager.startUpdatingLocation()
    }

    func disableLocationManager() {
        manager.stopUpdatingLocation()
    }
    
    //////// End route
    
    func endRoute(desc:String) {
        let color:String = getColorFromSpeed(speed: mSpeed).htmlRGBColor
        self.endedTime = Date().currentTimeMillis()
        self.uploadRealTimeRoute(route_id: self.routeID, assign_id: self.assignID, member_id: thisUser.idx, name: "", description: desc, start_time: String(self.startedTime), end_time: String(self.endedTime), duration: self.duration, speed: self.speed, distance: self.totalDistance, status: "report", lat: self.thisUserLocation!.latitude, lng: self.thisUserLocation!.longitude, comment: "", color: color, end: 2, pulse: false)
    }
    
    
    func openTimeTakingDialog(route:Route) {
        questionDialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        questionDialog.titleBox.text = "注意！"
        questionDialog.messageBox.text = "時間がかかります。よろしいですか？"
        questionDialog.messageBox.numberOfLines = 3
        questionDialog.noButton.setTitle("いや", for: .normal)
        questionDialog.yesButton.setTitle("はい", for: .normal)
        self.addChild(self.questionDialog)
        self.view.addSubview(self.questionDialog.view)
        self.route = route
    }
    
    var isLongTime:Bool = false
    
    func saveRoute(route:Route, islongtime:Bool) {
        self.route = route
        
        if islongtime {
            loadingDialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            loadingDialog.messageBox.text = "データをアップロードしています。。。"
            self.addChild(self.loadingDialog)
            self.view.addSubview(self.loadingDialog.view)
        }else {
            self.showLoadingView()
        }
        
        isLongTime = islongtime
        
        isLoading = true
        savingPoints = Int64(traces.count)
        
        print("Saving traces: \(traces.count)")
        
        APIs.saveRoute(member_id: thisUser.idx, name: route.name, description: route.description, start_time: route.start_time, end_time: route.end_time, duration: route.duration, speed: route.speed, distance: route.distance, points: createRoutePointsJsonString(), status: route.status, handleCallback: { [self]
            result_code in
            self.dismissLoadingView()
            self.dismissLoadingDialog()
            
            print(result_code)
            if result_code == "0"{
                if route.status != "" {
                    showToast2(msg: "正常に送信されました！")
                }else {
                    showToast2(msg: "保存された")
                }
                isLoading = false
                savingPoints = 0
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyRoutesViewController")
                gRoutesOption = "saved_history"
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else {
//                self.showToast(msg: "何かが間違っている。")
                print("Result: \(result_code)")
            }
            
        })
    }
    
    func createRoutePointsJsonString() -> String{
        var jsonArray = [Any]()
        for point in traces{
            let jsonObject: [String: String] = [
                "lat": String(point.lat),
                "lng": String(point.lng),
                "comment": point.comment,
                "color": point.color,
                "time": point.time
            ]
            
            jsonArray.append(jsonObject)
        }
        
        let jsonItemsObj:[String: Any] = [
            "points":jsonArray
        ]
        
        let jsonStr = self.stringify(json: jsonItemsObj)
        return jsonStr
        
    }
    
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    func dismissLoadingDialog() {
        self.loadingDialog.removeFromParent()
        self.loadingDialog.view.removeFromSuperview()
        self.loadingDialog.alertView.alpha = 1
    }
    
    func savePin(comment:String) {
        
        let currentTimeStamp = Date().currentTimeMillis()
        let currentTime = self.getTimeFromTimeStamp(timeStamp: Double(currentTimeStamp/1000)).replacingOccurrences(of: "AM", with: "午前").replacingOccurrences(of: "PM", with: "午後")
        
        if self.pin == nil {
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let title = comment.lowercased()
            marker.title = title.capitalizingFirstLetter()
            let snippet = currentTime.lowercased()
            marker.snippet = snippet.capitalizingFirstLetter()
            marker.map = self.map
            marker.icon = UIImage(named: "targetmarker")
            marker.appearAnimation = .pop
            map.selectedMarker = marker
            
            self.markers.append(marker)

            let pin = Point()
            pin.idx = 0
            pin.lat = coordinate.latitude
            pin.lng = coordinate.longitude
            pin.comment = comment
            pin.time = currentTime
            
            self.pin = pin
        }else {
            if self.marker != nil {
                let title = comment.lowercased()
                self.marker.title = title.capitalizingFirstLetter()
                let snippet = currentTime.lowercased()
                self.marker.snippet = snippet.capitalizingFirstLetter()
                map.selectedMarker = self.marker
            }
            
            self.pin.comment = comment
            self.pin.time = currentTime
        }
        
        APIs.savePin(member_id: thisUser.idx, pin_id: self.pin.idx, comment: comment, time: String(currentTimeStamp), lat: self.pin.lat, lng: self.pin.lng, handleCallback: { [self] pin_id, result_code in
            if result_code == "0" {
                self.pin.idx = Int64(pin_id)!
                let pins = gPins.filter{ pin in
                    return pin.idx == self.pin.idx
                }
                if pins.count == 0 {
                    gPins.append(self.pin)
                }
                showToast2(msg: "保存された")
                pintSaveBox.commentBox.text = ""
            }else {
                self.showToast(msg: "何かが間違っている。")
            }
        })
        
        self.resignFirstResponder()
        
    }
    
    func deletePin(pin:Point) {
        if self.marker != nil {
            self.marker.map = nil
            let mks = self.markers.filter{ mk in
                return mk === self.marker
            }
            if mks.count > 0 {
                self.markers.remove(at: self.markers.firstIndex(where: {$0 === self.marker})!)
            }
        }
        APIs.deletePin(pin_id: pin.idx, handleCallback: {[self]
            result_code in
            if result_code == "0" {
                gPins.remove(at: gPins.firstIndex(where: {$0.idx == pin.idx})!)
                showToast2(msg: "正常に削除されました")
            }else {
                showToast(msg: "何かが間違っている。")
            }
            self.resignFirstResponder()
        })
    }
    
    func clearPins() {
        for marker in self.markers {
            marker.map = nil
        }
        self.markers.removeAll()
    }
    
    func getPins() {
        APIs.getPins(member_id: thisUser.idx, handleCallback: { [self]
            pins, result_code in
            if result_code == "0" {
                gPins = pins!
                clearPins()
                for pin in pins! {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lng)
                    marker.isFlat = true
                    let title = pin.comment.lowercased()
                    marker.title = title.capitalizingFirstLetter()
                    let snippet = pin.time.lowercased()
                    marker.snippet = snippet.capitalizingFirstLetter()
                    marker.map = self.map
                    marker.icon = UIImage(named: "targetmarker")
                    marker.appearAnimation = .pop
                    map.selectedMarker = marker
                    
                    self.markers.append(marker)
                }
            }else {
                showToast(msg: "何かが間違っている。")
            }
        })
    }
    
    func startCheckLoading() {
        if !isLocationRecording && isLoading {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(processChecking), userInfo: nil, repeats: true)
            if isLoading { self.showLoadingView() }
        }
    }
    
    func endCheckLoading() {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    @objc func processChecking(){
        print("Current time: \(Date().currentTimeMillis())")
        
        APIs.checkRouteLoading(member_id: thisUser.idx, handleCallback: { [self]
            result_code, points in
            if result_code == "0" {
                if traces.count == Int(points) {
                    if self.loadingView.isAnimating {
                        dismissLoadingView()
                    }
                    endCheckLoading()
                    isLoading = false
                    savingPoints = 0
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyRoutesViewController")
                    gRoutesOption = "saved_history"
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else if traces.count > Int(points)! {
                    if !self.isLongTime { showLoadingView() }
                    isLoading = true
                }
            }else {
                if self.loadingView.isAnimating {
                    dismissLoadingView()
                }
                endCheckLoading()
                isLoading = false
            }
        })
        
    }
    
    var areaPolygon:GMSPolygon!
    var subAreaPolygons = [GMSPolygon]()
    
    
    func clearOldDrawing() {
        if areaPolygon != nil {
            areaPolygon.map = nil
        }
        for polygon in subAreaPolygons {
            polygon.map = nil
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

        subAreaPolygons = polygons

        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
        map.animate(with: update)
    }
    
    func drawArea(coords:[CLLocationCoordinate2D]) {
        var bounds = GMSCoordinateBounds()
        let path = GMSMutablePath()
        for coord in coords {
            bounds = bounds.includingCoordinate(coord)
            path.add(coord)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
        map.animate(with: update)

        let polygon = GMSPolygon(path: path)
        polygon.strokeColor = UIColor(rgb: 0xFF0000, alpha: 0.8)
        polygon.fillColor = UIColor(rgb: 0xFF0000, alpha: 0.2)
        polygon.strokeWidth = 1.0
        polygon.map = map
        areaPolygon = polygon
    }
    
    func goToLocation(addr:String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addr) { [self] (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }
            // Use your location
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 14.0, bearing: 0, viewingAngle: 0)
            self.map.animate(to: camera)
        }
    }
    
    func showAreaDetails(area:Area) {
        container.visibility = .visible
        areaNameBox.text = area.areaName
        titleBox.text = area.title
        if area.startTime > 0 {
            timeBox.text = getTimeFromTimeStamp(timeStamp: Double(area.startTime)/1000) + " ~ " + getTimeFromTimeStamp(timeStamp: Double(area.endTime)/1000)
        }else {
            timeBox.text = " --- "
        }
        durBox.text = getDurationDaysFromMilliseconds(timeDiff: area.endTime - area.startTime)
        distBox.text = "距離: " + String(format: "%.2f", area.distance) + "km"
        distributionBox.text = "配布物: " + area.distribution
        amountBox.text = "金額: " + Int(area.amount).delimiter + " 円"
        copiesBox.text = "部数: " + Int(area.copies).delimiter
    }
    
    @IBAction func closeDetailFrame(_ sender: Any) {
        if isLocationRecording { return }
        container.visibility = .gone
        clearOldDrawing()
        assignID = 0
        gArea = Area()
    }
    
    func uploadRealTimeRoute(route_id:Int64, assign_id:Int64, member_id: Int64, name:String, description:String, start_time:String, end_time:String, duration:Int64, speed:Double, distance:Double, status:String, lat:Double, lng:Double, comment:String, color:String, end:Int, pulse:Bool) {
        if end == 0 || end == 2 { self.showLoadingView()}
        APIs.uploadRealTimeRoute(route_id: route_id, assign_id: assign_id, member_id: member_id, name: name, description: description, start_time: start_time, end_time: end_time, duration: duration, speed: speed, distance: distance, status: status, lat: lat, lng: lng, comment: comment, color: color, pulse: pulse, handleCallback: { [self]
            route_id, result_code in
            if end == 0 || end == 2 { self.dismissLoadingView() }
            
            print(result_code)
            if result_code == "0"{
                routeID = Int64(route_id)!
                if end == 0 {
                    clearPolylines()
                    startBtn.backgroundColor = .red
                    startBtn.layer.cornerRadius = startBtn.frame.height / 2
                    startBtn.setTitleColor(.yellow, for: .normal)
                    startBtn.setTitle("終了", for: .normal)
                    panelView.isHidden = false
                    isLocationRecording = true
                    enableLocationManager()
                    
                    savingPoints = 0
                    isLoading = false
                    
                    distanceBox.text = String(format: "%.2f", 0) + "km"
                    durationBox.text = getDurationFromMilliseconds0(ms: 0)
                    speedBox.text = String(format: "%.2f", 0) + "km/h"

                }else {
                    if end == 2 {
    //                    isLoading = false
    //                    savingPoints = 0
                        
                        startBtn.backgroundColor = primaryDarkColor
                        startBtn.layer.cornerRadius = startBtn.frame.height / 2
                        startBtn.setTitleColor(.white, for: .normal)
                        startBtn.setTitle("開始", for: .normal)
                        isLocationRecording = false
                        disableLocationManager()
                        
                        if status != "" {
                            showToast2(msg: "正常に送信されました！")
                        }else {
                            showToast2(msg: "保存された")
                        }
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyRoutesViewController")
                        gRoutesOption = "reports"
                        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                    }
                }
            }else {
//                self.showToast(msg: "何かが間違っている。")
                print("Result: \(result_code)")
            }
            
        })
    }
    
    func upRoute() {
        
        let jsonFile = createPointsJsonStr().data(using: .utf8)!
        
        let params = [
            "route_id":String(routeID),
        ] as [String : Any]
        
        let fileDic = ["jsonfile" : jsonFile]
        // Here you can pass multiple image in array i am passing just one
        let fileArray = NSMutableArray(array: [fileDic as NSDictionary])
            
        self.showLoadingView()
        APIs().uploadJsonFile(withUrl: SERVER_URL + "upRoute", withParam: params, withFiles: fileArray) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Response: \(response)")
            if isSuccess == true{
                let result_code = response["result_code"] as Any
                if result_code as! String == "0"{
                    print("Offline loading: \(response)")
                    self.traces1.removeAll()
                    self.cnt = 0
                }
            }else{
                let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                self.showToast(msg: "Issue: \n" + message)
            }
        }
        
        
    }
    
    func createPointsJsonStr() -> String {
        var jsonStr = ""
        var jsonArray = [Any]()
        for rpoint in traces1 {
            let jsonObject: [String: String] = [
                "lat": String(rpoint.lat),
                "lng": String(rpoint.lng),
                "comment": rpoint.comment,
                "time": String(rpoint.time),
                "color": rpoint.color,
            ]
            jsonArray.append(jsonObject)
        }
        
        let jsonItemsObj:[String: Any] = [
            "points":jsonArray
        ]
        
        jsonStr = self.stringify(json: jsonItemsObj)
        return jsonStr
    }
    
    
}


















































