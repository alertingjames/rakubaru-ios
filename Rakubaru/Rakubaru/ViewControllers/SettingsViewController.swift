//
//  SettingsViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapViewButton: UISwitch!
    @IBOutlet weak var autoReportButton: UISwitch!    
    @IBOutlet weak var autoReportLayout: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        backButton.setImageTintColor(.white)
        
        if gHomeVC.map.mapType == .normal {
            mapViewButton.isOn = false
        }else if gHomeVC.map.mapType == .satellite {
            mapViewButton.isOn = true
        }
        
        if gAutoReport {
            autoReportButton.isOn = true
        }else {
            autoReportButton.isOn = false
        }
        
        autoReportLayout.visibility = .gone
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func mapViewAction(_ sender: Any) {
        if mapViewButton.isOn {
            gHomeVC.map.mapType = .satellite
        }else {
            gHomeVC.map.mapType = .normal
        }
    }
    
    @IBAction func autoReportAction(_ sender: Any) {
        if autoReportButton.isOn {
            gAutoReport = true
            UserDefaults.standard.setValue(true, forKey: "auto_report")
        }else {
            gAutoReport = false
            UserDefaults.standard.setValue(false, forKey: "auto_report")
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
}
