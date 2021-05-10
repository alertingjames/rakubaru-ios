//
//  HintBox.swift
//  Rakubaru
//
//  Created by Andre on 11/30/20.
//

import UIKit

class HintBox: BaseViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var messageBox: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        messageBox.layer.cornerRadius = 5
        messageBox.layer.borderWidth = 1.2
        messageBox.layer.borderColor = primaryDarkColor.cgColor
        messageBox.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
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
        
    }    

    @IBAction func okAction(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "hint_read")
        dismissDialog()
    }
    
    func dismissDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        alertView.alpha = 1
    }

}
