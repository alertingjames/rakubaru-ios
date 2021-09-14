//
//  LoginViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import TextFieldEffects

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var emailBox: HoshiTextField!
    @IBOutlet weak var passwordBox: HoshiTextField!
    @IBOutlet weak var showBtn: UIButton!
    var showF:Bool = false
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgotpasswordBtn: UIButton!
    
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    var deviceID:String = ""
    
    var hintBox:HintBox!
    var helpBox:HelpBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hintBox = (self.storyboard?.instantiateViewController(identifier: "HintBox"))! as HintBox
        helpBox = (self.storyboard?.instantiateViewController(identifier: "HelpBox"))! as HelpBox
        helpBox.view.frame = CGRect(x: 0, y: self.screenHeight, width: self.screenWidth, height: self.screenHeight)

        iconWidth.constant = screenWidth / 3
        showBtn.setImageTintColor(.black)
                
        emailBox.placeholder = "メールアドレス"
        emailBox.minimumFontSize = 5
        emailBox.textColor = .black
        emailBox.font = UIFont(name: "Helvetica", size: 19)
        emailBox.keyboardType = UIKeyboardType.emailAddress
        emailBox.addTarget(self, action: #selector(emailBoxDidChange), for: .editingChanged)
        
        passwordBox.placeholder = "パスワード"
        passwordBox.minimumFontSize = 5
        passwordBox.paddingRightCustom = 35
        passwordBox.textColor = .black
        passwordBox.font = UIFont(name: "Helvetica", size: 19)
        passwordBox.isSecureTextEntry = true
        passwordBox.addTarget(self, action: #selector(passwordBoxDidChange), for: .editingChanged)
        
        setRoundShadowButton(button: loginBtn, corner: loginBtn.frame.height/2)        
        deviceID = getDeviceID()
        
        let hint_read = UserDefaults.standard.bool(forKey: "hint_read")
        if !hint_read {
            hintBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            self.addChild(hintBox)
            self.view.addSubview(hintBox.view)
        }
        
    }
    
    @IBAction func toForgotPassword(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController")
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func togglePasswordShowing(_ sender: Any) {
        if showF == false{
            showBtn.setImage(unshow, for: UIControl.State.normal)
            showF = true
            passwordBox.isSecureTextEntry = false
        }else{
            showBtn.setImage(show, for: UIControl.State.normal)
            showF = false
            passwordBox.isSecureTextEntry = true
        }
        showBtn.setImageTintColor(.black)
    }
    
    @IBAction func login(_ sender: Any) {
        
        if loginBtn.alpha < 1.0 { return }
        
        if !isValidEmail(email: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) {
            showToast(msg: "無効なメール")
            return
        }
        
        showLoadingView()
        APIs.login(email: emailBox.text!, password: passwordBox.text!, device: deviceID, handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if result_code == "1" {
                // unregistered user
                thisUser.idx = 0
                self.logout()
            }else if result_code == "2" {
                // incorrect password
                thisUser.idx = 0
                self.showToast(msg: "パスワードが間違っています。")
            }else if result_code == "3" {
                // already logged in with another device
                thisUser.idx = 0
                self.showToast(msg: "すでに別の電話からログインしています。 別の電話で同時にログインすることはできません。")
            }else if result_code == "100" {
                // already logged in with another device
                thisUser.idx = 0
                self.showToast(msg: "あなたの管理者の支払いは困っています。 それが解決されるまでログインすることはできません。")
            }else{
                thisUser.idx = 0
                self.showToast(msg: "何かが間違っている。")
            }
        })
        
    }
    
    @objc func emailBoxDidChange(_ textField: UITextField) {
        if passwordBox.text!.count > 0 && textField.text!.count > 0 && self.isValidEmail(email: textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            loginBtn.alpha = 1.0
        }else {
            loginBtn.alpha = 0.3
        }
    }
    
    @objc func passwordBoxDidChange(_ textField: UITextField) {
        if emailBox.text!.count > 0 && textField.text!.count > 0 && self.isValidEmail(email: emailBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            loginBtn.alpha = 1.0
        }else {
            loginBtn.alpha = 0.3
        }
    }

    @IBAction func openHelp(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { [self] in
            helpBox.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            self.addChild(helpBox)
            self.view.addSubview(helpBox.view)
        }
    }
    
    
}
