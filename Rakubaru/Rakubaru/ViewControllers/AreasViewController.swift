//
//  AreasViewController.swift
//  Rakubaru
//
//  Created by LGH on 3/18/21.
//

import UIKit

class AreasViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_search: UIImageView!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var lbl_noresult: UILabel!
    
    var areas = [Area]()
    var searchAreas = [Area]()
    
    @IBOutlet weak var AreaList: UITableView!
    
    var routeListButtons:RouteListButtons!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gRecentVC = self
        gAreasVC = self

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
        
        AreaList.delegate = self
        AreaList.dataSource = self
        
        AreaList.estimatedRowHeight = 220.0
        AreaList.rowHeight = UITableView.automaticDimension
        
        AreaList.separatorStyle = .none
        
        //Long Press
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        AreaList.addGestureRecognizer(longPressGesture)
        
        self.getMyAreas(member_id: thisUser.idx)
        
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
        if areas.count == 0 {
            getMyAreas(member_id: thisUser.idx)
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
            areas = self.searchAreas
            AreaList.reloadData()
            if areas.count > 0{
                lbl_noresult.isHidden = true
            }else{
                lbl_noresult.isHidden = false
            }
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == ""{
            areas = searchAreas
            AreaList.reloadData()
            if areas.count > 0{
                lbl_noresult.isHidden = true
            }else{
                lbl_noresult.isHidden = false
            }
        }else{
            areas = filter(keyword: (textField.text?.lowercased())!)
            if areas.count > 0{
                lbl_noresult.isHidden = true
            }else{
                lbl_noresult.isHidden = false
            }
            AreaList.reloadData()
        }
    }
    
    func filter(keyword:String) -> [Area]{
        var filteredAreas = [Area]()
        for area in searchAreas{
            if area.areaName.lowercased().contains(keyword){
                filteredAreas.append(area)
            }else{
                if area.distribution.lowercased().contains(keyword){
                    filteredAreas.append(area)
                }else{
                    if getTimeFromTimeStamp(timeStamp: Double(area.startTime)/1000).lowercased().contains(keyword)
                        || getTimeFromTimeStamp(timeStamp: Double(area.endTime)/1000).lowercased().contains(keyword) {
                        filteredAreas.append(area)
                    }else {
                        if area.status.lowercased().contains(keyword){
                            filteredAreas.append(area)
                        }
                    }
                }
            }
        }
        return filteredAreas
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell:AreaCell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath) as! AreaCell
            
        let index:Int = indexPath.row
        let area = areas[index]
            
        cell.areaNameBox.text = area.areaName
        cell.titleBox.text = area.title
        cell.timeBox.text = getTimeFromTimeStamp(timeStamp: Double(area.startTime)/1000) + " ~ " + getTimeFromTimeStamp(timeStamp: Double(area.endTime)/1000)
        cell.durationBox.text = getDurationDaysFromMilliseconds(timeDiff: area.endTime - area.startTime)
        cell.distanceBox.text = "距離: " + String(format: "%.2f", area.distance) + "km"
        cell.distributionBox.text = "配布物: " + area.distribution
        cell.amountBox.text = "金額: " + Int(area.amount).delimiter + " 円"
        cell.copiesBox.text = "部数: " + Int(area.copies).delimiter
        
        cell.container.tag = index
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedItem(_ :)))
        cell.container.addGestureRecognizer(tap)
            
        cell.container.sizeToFit()
        cell.container.layoutIfNeeded()
        
        return cell
    }
    
    @objc func tappedItem(_ sender:UITapGestureRecognizer? = nil) {
        if let tag = sender?.view?.tag {
            print("Selected tag: \(tag)")
            let area = areas[tag]
            gArea = area
            self.showLoadingView()
            self.getAreaSublocs(area: area)
        }
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.AreaList)
        let indexPath = AreaList.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("Long press on row, at \(indexPath!.row)")
            gArea = self.areas[indexPath!.row]
            showButtons(option: true)
        }
    }
    
    func getMyAreas(member_id:Int64){
        self.showLoadingView()
        APIs.getMyAreas(member_id: member_id, handleCallback: { [self]
            areas, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.areas = areas!
                self.searchAreas = areas!
                if self.areas.count == 0{
                    self.lbl_noresult.isHidden = false
                    self.AreaList.separatorStyle = .none
                }else{
                    self.lbl_noresult.isHidden = true
                    self.AreaList.separatorStyle = .singleLine
                }
                self.AreaList.reloadData()
            }
            else{
                print("Result: \(result_code)")
            }
        })
    }
    
    func getAreaSublocs(area:Area){
        self.showLoadingView()
        APIs.getAreaLocations(area_id: area.idx, handleCallback: { [self]
            sublocs, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                gHomeVC.clearOldDrawing()
                if area.coords.count > 0 {
                    gHomeVC.drawArea(coords: area.coords)
                    if sublocs!.count > 0 {
                        gHomeVC.drawSubareas(sublocs: sublocs!)
                    }
                }else {
                    if sublocs!.count > 0 {
                        gHomeVC.drawSubareas(sublocs: sublocs!)
                    }
                    gHomeVC.goToLocation(addr: area.areaName)
                }
                gHomeVC.showAreaDetails(area: area)
                self.dismissViewController()
            }
            else{
                print("Result: \(result_code)")
                self.getMyAreas(member_id: thisUser.idx)
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
            routeListButtons.reportButton.visibility = .gone
            routeListButtons.option = "area"
            self.addChild(routeListButtons)
            self.view.addSubview(routeListButtons.view)
        }else{
            routeListButtons.removeFromParent()
            routeListButtons.view.removeFromSuperview()
        }
    }
    
    func deleteAssign(area:Area){
        showLoadingView()
        APIs.deleteAssign(assign_id:area.idx, handleCallback:{ [self]
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast2(msg: "正常に削除されました")
                if self.areas.contains(where: { $0.idx == area.idx }){
                    self.areas.remove(at: self.areas.firstIndex(where: {$0.idx == area.idx})!)
                    self.AreaList.reloadData()
                }
            }else {
                self.showToast(msg: "何かが間違っている。")
            }
        })
    }
    
}
