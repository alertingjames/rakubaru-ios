//
//  RouteListButtons.swift
//  Rakubaru
//
//  Created by Andre on 11/27/20.
//

import UIKit

class RouteListButtons: BaseViewController {
    
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    var option:String = "route"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reportButton.layer.cornerRadius = 20
        deleteButton.layer.cornerRadius = 20
        
        buttonView.alpha = 0
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        UIView.animate(withDuration: 0.8) {
            self.buttonView.alpha = 1.0
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.buttonView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            self.removeFromParent()
            self.view.removeFromSuperview()
            self.buttonView.alpha = 1
        }
    }
    
    @IBAction func reportRoute(_ sender: Any) {
        gMyRoutesVC.showButtons(option: false)
        gMyRoutesVC.reporteRoute(route: gRoute)
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        if self.option == "area" {
            gAreasVC.showButtons(option: false)
            gAreasVC.deleteAssign(area: gArea)
        }else {
            gMyRoutesVC.showButtons(option: false)
            gMyRoutesVC.deleteRoute(route: gRoute)
        }
    }
    
}
