//
//  ForgotPasswordViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import TextFieldEffects

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet weak var view_desc: UIView!
    @IBOutlet weak var emailBox: HoshiTextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view_desc.layer.cornerRadius = 8
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        emailBox.placeholder = "メールアドレス"
        emailBox.minimumFontSize = 5
        emailBox.textColor = .black
        emailBox.font = UIFont(name: "Helvetica", size: 19)
        emailBox.keyboardType = UIKeyboardType.emailAddress
        emailBox.addTarget(self, action: #selector(emailBoxDidChange), for: .editingChanged)
        
        setRoundShadowButton(button: submitBtn, corner: submitBtn.frame.height/2)
    }
    
    @objc func emailBoxDidChange(_ textField: UITextField) {
        if textField.text!.count > 0 && self.isValidEmail(email: textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            submitBtn.alpha = 1.0
        }else {
            submitBtn.alpha = 0.3
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    @IBAction func submit(_ sender: Any) {
        if submitBtn.alpha < 1.0 { return }
        forgotPassword(email: emailBox.text!)
    }
    
    func forgotPassword(email:String) {
        showLoadingView()
        APIs.forgotPassword(email: email, handleCallback:{
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast2(msg: "パスワードリセットのリンクをメールでお送りしました。 チェックしてください。")
                self.openMailBox()
            }else if result_code == "1"{
                self.showToast(msg: "登録されていません。")
            }else {
                self.showToast(msg: "何かが間違っている。")
            }
        })
    }
    
    func openMailBox(){
        let mailURL = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.openURL(mailURL)
        }
    }
    
}
