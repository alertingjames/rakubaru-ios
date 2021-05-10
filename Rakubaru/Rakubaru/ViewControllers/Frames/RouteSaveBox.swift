//
//  RouteSaveBox.swift
//  Rakubaru
//
//  Created by Andre on 11/28/20.
//

import UIKit
import SimpleCheckbox

class RouteSaveBox: BaseViewController {
    
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var descBox: UITextView!
    @IBOutlet weak var checkBox: Checkbox!
    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    var end:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        nameBox.layer.cornerRadius = 5
        nameBox.layer.borderColor = primaryDarkColor.cgColor
        nameBox.layer.borderWidth = 1.5
        
        descBox.layer.cornerRadius = 5
        descBox.layer.borderColor = primaryDarkColor.cgColor
        descBox.layer.borderWidth = 1.5
        
        descBox.setPlaceholder(string: "メモ（オプション）")
        descBox.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        descBox.delegate = self
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        alertView.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            UIView.animate(withDuration: 0.8) {
                self.alertView.alpha = 1.0
            }
        }
        
        checkBox.checkedBorderColor = primaryDarkColor
        checkBox.uncheckedBorderColor = primaryDarkColor
        checkBox.borderCornerRadius = 2
        checkBox.checkmarkColor = primaryDarkColor
        checkBox.checkmarkStyle = .square
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(checkboxValueChanged(sender:)))
        checkBoxLabel.addGestureRecognizer(tap)
        
        okayButton.layer.cornerRadius = 3
        
        nameBox.text = thisUser.name + "_" + getRouteNameTimeFromTimeStamp(timeStamp: Double(Date().currentTimeMillis()/1000))
        if gAutoReport {
            checkBox.isChecked = true
        }else {
            checkBox.isChecked = false
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
    }
    
    @objc func checkboxValueChanged(sender: UILabel) {
        if checkBox.isChecked {
            checkBox.isChecked = false
        }else {
            checkBox.isChecked = true
        }
    }


    @IBAction func saveRoute(_ sender: Any) {
        if end == 0 {
            if nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                return
            }
            nameBox.resignFirstResponder()
//            var status = "report"
//            if checkBox.isChecked {
//                status = "report"
//            }
            gHomeVC.startLocationRecording(name: nameBox.text!)
            dismissDialog()
        }else if end == 2 {
            descBox.resignFirstResponder()
            gHomeVC.endRoute(desc: descBox.text!)
            dismissDialog()
        }
        
        
//        let route = Route()
//        route.user_id = thisUser.idx
//        route.name = nameBox.text!
//        route.description = descBox.text
//        route.duration = gHomeVC.duration
//        route.distance = gHomeVC.totalDistance
//        route.speed = gHomeVC.speed
//        route.start_time = String(gHomeVC.startedTime)
//        route.end_time = String(gHomeVC.endedTime)
//
//        if checkBox.isChecked {
//            route.status = "report"
//        }
//
//        if gHomeVC.traces.count > 2000 {
//            gHomeVC.openTimeTakingDialog(route:route)
//            dismissDialog()
//        }else {
//            gHomeVC.saveRoute(route: route, islongtime: false)
//            dismissDialog()
//        }
        
    }
    
    func dismissDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        alertView.alpha = 1
    }
    
}
