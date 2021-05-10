//
//  PinSaveBox.swift
//  Rakubaru
//
//  Created by Andre on 11/28/20.
//

import UIKit

class PinSaveBox: BaseViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var deleteButton: UIButton!    
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonWidth2: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        commentBox.layer.cornerRadius = 5
        commentBox.layer.borderColor = primaryDarkColor.cgColor
        commentBox.layer.borderWidth = 1.5
        
        alertView.alpha = 0
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            UIView.animate(withDuration: 0.8) {
                self.alertView.alpha = 1.0
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.alertView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            // Code you want to be delayed
            dismissDialog()
        }
    }
    
    @IBAction func savePin(_ sender: Any) {
        if commentBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return
        }
        if gHomeVC != nil {
            gHomeVC.savePin(comment:commentBox.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        dismissDialog()
        
    }
    
    func dismissDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        alertView.alpha = 1
    }
    
    @IBAction func deletePin(_ sender: Any) {
        if gHomeVC.pin != nil {
            gHomeVC.deletePin(pin: gHomeVC.pin)
        }
        dismissDialog()
    }
    
}
