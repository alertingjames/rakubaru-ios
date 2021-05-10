//
//  ViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit

class ViewController: BaseViewController {

    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconWidth.constant = screenWidth * 1.2 / 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            let email = UserDefaults.standard.string(forKey: "email")
            let password = UserDefaults.standard.string(forKey: "password")
            
            if email?.count ?? 0 > 0 && password?.count ?? 0 > 0{
                self.login(email: email!, password: password!, device: self.getDeviceID())
            }else{
                thisUser.idx = 0
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier:"LoginViewController")
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
            
        }
        
    }
    
    func login(email:String, password: String, device:String) {
        showLoadingView()
        APIs.login(email: email, password: password, device:device, handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
        })
    }
    
    
    
}

