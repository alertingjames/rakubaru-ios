//
//  RoutesViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import Kingfisher
import DropDown

class MyRoutesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var routeList: UITableView!
    @IBOutlet weak var img_search: UIImageView!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var lbl_noresult: UILabel!
    
    var routes = [Route]()
    var searchRoutes = [Route]()
    
    var routeListButtons:RouteListButtons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gRecentVC = self
        gMyRoutesVC = self
        
        if gRoutesOption == "saved_history" {
            lbl_title.text = "過去ログ（全件）"
        }else if gRoutesOption == "reports" {
            lbl_title.text = "過去ログ"
        }
        
        routeListButtons = (self.storyboard!.instantiateViewController(withIdentifier: "RouteListButtons") as! RouteListButtons)

        view_searchbar.isHidden = true
        lbl_noresult.isHidden = true
        btn_search.setImageTintColor(.white)
        btn_search.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        btn_back.setImageTintColor(.white)
        btn_back.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        setIconTintColor(imageView: img_search, color: .white)
        
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        edt_search.textColor = .white
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        routeList.delegate = self
        routeList.dataSource = self
        
        routeList.estimatedRowHeight = 190.0
        routeList.rowHeight = UITableView.automaticDimension
        
        routeList.separatorStyle = .none
        
        //Long Press
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        routeList.addGestureRecognizer(longPressGesture)
        
        self.getMyRoutes(member_id: thisUser.idx)
        
        // Move this viewcontroller to foreground by clicking on app icon
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
    }
    
    @objc func appToForeground(notification: NSNotification) {
        print("Moved to foreground.")
        checkDevice(member_id: thisUser.idx, device: getDeviceID())
        if routes.count == 0 {
            getMyRoutes(member_id: thisUser.idx)
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func openSearch(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            edt_search.becomeFirstResponder()
            btn_search.setImage(UIImage(named: "cancelicon"), for: .normal)
            btn_search.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            lbl_title.isHidden = true
                
        }else{
            view_searchbar.isHidden = true
            edt_search.resignFirstResponder()
            btn_search.setImage(UIImage(named: "ic_search"), for: .normal)
            btn_search.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
            btn_search.setImageTintColor(.white)
            lbl_title.isHidden = false
            edt_search.text = ""
            routes = searchRoutes
            routeList.reloadData()
            if routes.count > 0{
                lbl_noresult.isHidden = true
            }else{
                lbl_noresult.isHidden = false
            }
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == ""{
            routes = searchRoutes
            routeList.reloadData()
            if routes.count > 0{
                lbl_noresult.isHidden = true
            }else{
                lbl_noresult.isHidden = false
            }
        }else{
            routes = filter(keyword: (textField.text?.lowercased())!)
            if routes.count > 0{
                lbl_noresult.isHidden = true
            }else{
                lbl_noresult.isHidden = false
            }
            routeList.reloadData()
        }
    }
    
    func filter(keyword:String) -> [Route]{
        var filteredRoutes = [Route]()
        for route in searchRoutes{
            if route.name.lowercased().contains(keyword){
                filteredRoutes.append(route)
            }else{
                if route.description.lowercased().contains(keyword){
                    filteredRoutes.append(route)
                }else{
                    if getTimeFromTimeStamp(timeStamp: Double(route.start_time)!/1000).lowercased().contains(keyword)
                        || getTimeFromTimeStamp(timeStamp: Double(route.end_time)!/1000).lowercased().contains(keyword) {
                        filteredRoutes.append(route)
                    }else {
                        if route.status.lowercased().contains(keyword){
                            filteredRoutes.append(route)
                        }
                    }
                }
            }
        }
        return filteredRoutes
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell:RouteCell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! RouteCell
            
        let index:Int = indexPath.row
        let route = routes[index]
            
        cell.nameBox.text = route.name
        cell.speedBox.text = String(format: "%.2f", route.speed) + "km/h"
        cell.timeBox.text = getTimeFromTimeStamp(timeStamp: Double(route.start_time)!/1000) + " ~ " + getTimeFromTimeStamp(timeStamp: Double(route.end_time)!/1000)
        cell.durationBox.text = getDurationFromMilliseconds(ms: route.duration)
        cell.distanceBox.text = String(format: "%.2f", route.distance) + "km"
        cell.descBox.text = route.description
        if route.description.count > 0 {
            cell.descBox.visibility = .visible
        }else {
            cell.descBox.visibility = .gone
        }
        
        if route.area_name.count > 0 {
            cell.areaNameBox.visibility = .visible
            cell.areaNameBox.text = route.area_name
        }else {
            cell.areaNameBox.visibility = .gone
        }
        
        if route.assign_title.count > 0 {
            cell.assignTitleBox.visibility = .visible
            cell.assignTitleBox.text = route.assign_title
        }else {
            cell.assignTitleBox.visibility = .gone
        }
        
        cell.container.tag = index
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedItem(_ :)))
        cell.container.addGestureRecognizer(tap)
            
        cell.descBox.sizeToFit()
        cell.container.sizeToFit()
        cell.container.layoutIfNeeded()
        
        if route.status.count > 0{
            cell.statusBox.visibilityh = .visible
        }else{
            cell.statusBox.visibilityh = .gone
        }
        return cell
    }
    
    @objc func tappedItem(_ sender:UITapGestureRecognizer? = nil) {
        if let tag = sender?.view?.tag {
            print("Selected tag: \(tag)")
            let route = routes[tag]
            gRoute = route
            self.showLoadingView()
            APIs.getRouteDetails(route_id: route.idx, handleCallback: {
                points, result_code in
                self.dismissLoadingView()
                print("Saved traces: \(points!.count)")
                print(result_code)
                if result_code == "0"{
                    gPoints = points!
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RouteMapViewController")
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
                else{
                    self.showToast(msg: "何かが間違っている。")
                }
            })
        }
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.routeList)
        let indexPath = routeList.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("Long press on row, at \(indexPath!.row)")
            if gRoutesOption == "saved_history" {
                gRoute = routes[indexPath!.row]
                showButtons(option: true)
            }
        }
    }
    
    func getMyRoutes(member_id:Int64){
        self.showLoadingView()
        APIs.getMyRoutes(member_id: member_id, handleCallback: { [self]
            routes, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                if gRoutesOption == "saved_history" {
                    self.routes = routes!
                    self.searchRoutes = routes!
                }else if gRoutesOption == "reports" {
                    self.routes = routes!.filter{ route in
                        return route.status == "reported"
                    }
                    self.searchRoutes = self.routes
                }
                if self.routes.count == 0{
                    self.lbl_noresult.isHidden = false
                    if gRoutesOption == "saved_history" {
                        self.lbl_noresult.text = "保存された履歴はありません。。。"
                    }else if gRoutesOption == "reports" {
                        self.lbl_noresult.text = "レポートはありません。。。"
                    }
                    self.routeList.separatorStyle = .none
                }else{
                    self.lbl_noresult.isHidden = true
                    self.routeList.separatorStyle = .singleLine
                }
                self.routeList.reloadData()
            }
            else{
//                self.showToast(msg: "何かが間違っている。")
                print("Result: \(result_code)")
            }
        })
    }
    
    @IBAction func back(_ sender: Any) {
        if gHomeVC.isLocationRecording {
            self.dismissViewController()
        }else {
            gHomeVC.reset()
            self.dismissViewController()
        }
    }
    
    func showButtons(option:Bool){
        if option == true{
            routeListButtons.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            if gRoute.status == "" {
                routeListButtons.reportButton.visibility = .visible
            } else if gRoute.status == "reported" {
                routeListButtons.reportButton.visibility = .gone
            }
            routeListButtons.option = "route"
            self.addChild(routeListButtons)
            self.view.addSubview(routeListButtons.view)
        }else{
            routeListButtons.removeFromParent()
            routeListButtons.view.removeFromSuperview()
        }
    }
    
    func deleteRoute(route:Route){
        showLoadingView()
        APIs.deleteRoute(route_id:route.idx, handleCallback:{ [self]
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast2(msg: "正常に削除されました")
                if self.routes.contains(where: { $0.idx == route.idx }){
                    self.routes.remove(at: self.routes.firstIndex(where: {$0.idx == route.idx})!)
                    self.routeList.reloadData()
                }
            }else {
                self.showToast(msg: "何かが間違っている。")
            }
        })
    }
    
    func reporteRoute(route:Route){
        showLoadingView()
        APIs.reportRoute(route_id:route.idx, handleCallback:{ [self]
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                route.status = "reported"
                self.showToast2(msg: "正常に送信されました！")
                self.routeList.reloadData()
            }else {
                self.showToast(msg: "何かが間違っている。")
            }
        })
    }
    
}
