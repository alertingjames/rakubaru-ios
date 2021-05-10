//
//  LoadingDialog.swift
//  Rakubaru
//
//  Created by Andre on 11/28/20.
//

import UIKit

class LoadingDialog: BaseViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var messageBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
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
        
    }
    

}
