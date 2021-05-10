//
//  ResetPasswordViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import TextFieldEffects

class ResetPasswordViewController: BaseViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pwShowButton: UIButton!
    
    @IBOutlet weak var oldBox: HoshiTextField!
    @IBOutlet weak var newBox: HoshiTextField!
    @IBOutlet weak var confirmBox: HoshiTextField!  
    
    var showF:Bool = false
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")

    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        backButton.setImageTintColor(.black)
        
        oldBox.placeholder = "既存のパスワード"
        oldBox.minimumFontSize = 5
        oldBox.paddingRightCustom = 35
        oldBox.textColor = .black
        oldBox.font = UIFont(name: "Helvetica", size: 19)
        oldBox.isSecureTextEntry = true
        oldBox.addTarget(self, action: #selector(oldPwDidChange
                            ), for: .editingChanged)
        
        newBox.placeholder = "新しいパスワード"
        newBox.minimumFontSize = 5
        newBox.paddingRightCustom = 35
        newBox.textColor = .black
        newBox.font = UIFont(name: "Helvetica", size: 19)
        newBox.isSecureTextEntry = true
        newBox.addTarget(self, action: #selector(newPwDidChange
                            ), for: .editingChanged)
        
        confirmBox.placeholder = "パスワードの確認"
        confirmBox.minimumFontSize = 5
        confirmBox.paddingRightCustom = 35
        confirmBox.textColor = .black
        confirmBox.font = UIFont(name: "Helvetica", size: 19)
        confirmBox.isSecureTextEntry = true
        confirmBox.addTarget(self, action: #selector(confirmPwDidChange
                            ), for: .editingChanged)
        
        setRoundShadowButton(button: submitButton, corner: submitButton.frame.height/2)
        pwShowButton.setImageTintColor(.darkGray)
    }
    

    @IBAction func togglePwShow(_ sender: Any) {
        if showF == false{
            pwShowButton.setImage(unshow, for: UIControl.State.normal)
            showF = true
            newBox.isSecureTextEntry = false
        }else{
            pwShowButton.setImage(show, for: UIControl.State.normal)
            showF = false
            newBox.isSecureTextEntry = true
        }
        pwShowButton.setImageTintColor(.darkGray)
    }
    
    @IBAction func submit(_ sender: Any) {
        if submitButton.alpha < 1.0 { return }
        self.showLoadingView()
        APIs.passwordUpdate(member_id:thisUser.idx, password:newBox.text!.trimmingCharacters(in: .whitespacesAndNewlines), handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                self.showToast2(msg: "正常に更新されました。")
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "1"{
                thisUser.idx = 0
                self.showToast(msg: "登録されていません。")
                self.logout()
            }else {
                self.showToast(msg: "何かが間違っている。")
            }
        })
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func oldPwDidChange(_ textField: UITextField) {
        if newBox.text!.count > 0 && textField.text!.count > 0 && confirmBox.text!.count > 0 {
            if textField.text == thisUser.password && newBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == confirmBox.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                submitButton.alpha = 1.0
            }else {
                submitButton.alpha = 0.3
            }
        }else {
            submitButton.alpha = 0.3
        }
    }
    
    @objc func newPwDidChange(_ textField: UITextField) {
        if oldBox.text!.count > 0 && textField.text!.count > 0 && confirmBox.text!.count > 0 {
            if oldBox.text == thisUser.password && textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == confirmBox.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                submitButton.alpha = 1.0
            }else {
                submitButton.alpha = 0.3
            }
        }else {
            submitButton.alpha = 0.3
        }
    }
    
    @objc func confirmPwDidChange(_ textField: UITextField) {
        if newBox.text!.count > 0 && textField.text!.count > 0 && oldBox.text!.count > 0 {
            if oldBox.text == thisUser.password && newBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                submitButton.alpha = 1.0
            }else {
                submitButton.alpha = 0.3
            }
        }else {
            submitButton.alpha = 0.3
        }
    }
    
}
