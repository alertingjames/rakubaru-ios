//
//  HelpBox.swift
//  Rakubaru
//
//  Created by Andre on 12/11/20.
//

import UIKit

class HelpBox: BaseViewController {
    
    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        okButton.layer.cornerRadius = okButton.frame.height / 2
        
    }
    
    @IBAction func ok(_ sender: Any) {
        dismissDialog()
    }
    
    func dismissDialog() {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame = CGRect(x: 0, y: self.screenHeight, width: self.screenWidth, height: self.screenHeight)
        }){
            (finished) in
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
}
