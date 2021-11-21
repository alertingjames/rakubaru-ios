//
//  RouteNameInputBox.swift
//  Rakubaru
//
//  Created by james on 11/16/21.
//

import UIKit

class RouteNameInputBox: BaseViewController {
    
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var nameBox: UITextField!
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
        
        okayButton.layer.cornerRadius = 3
        
        nameBox.text = thisUser.name + "_" + getRouteNameTimeFromTimeStamp(timeStamp: Double(Date().currentTimeMillis()/1000))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }

    @IBAction func saveRoute(_ sender: Any) {
        if nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return
        }
        nameBox.resignFirstResponder()
        gHomeVC.startLocationRecording(name: nameBox.text!)
        dismissDialog()
        
    }
    
    func dismissDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        alertView.alpha = 1
    }
    
}
