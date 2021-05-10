//
//  ProfileViewController.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit
import TextFieldEffects
import YPImagePicker
import SwiftyJSON

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var emailBox: UILabel!
    @IBOutlet weak var cumulativeBox: UILabel!
    @IBOutlet weak var nameBox: HoshiTextField!
    @IBOutlet weak var phoneBox: HoshiTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var picker:YPImagePicker!
    var imageFile:Data!
    var ImageArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        backButton.setImageTintColor(.white)
        
        emailBox.text = thisUser.email
        
        nameBox.placeholder = "氏名"
        nameBox.minimumFontSize = 5
        nameBox.textColor = .black
        nameBox.font = UIFont(name: "Helvetica", size: 19)
        nameBox.addTarget(self, action: #selector(nameBoxDidChange), for: .editingChanged)
        
        nameBox.text = thisUser.name
        if nameBox.text != "" {
            saveButton.alpha = 1.0
        }
        
        phoneBox.placeholder = "電話番号"
        phoneBox.minimumFontSize = 5
        phoneBox.textColor = .black
        phoneBox.font = UIFont(name: "Helvetica", size: 19)
        phoneBox.keyboardType = .phonePad
        
        phoneBox.text = thisUser.phone_number
        
        pictureBox.layer.cornerRadius = pictureBox.frame.height / 2
        loadPicture(imageView: pictureBox, url: URL(string: thisUser.picture_url)!)
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "図書館"
        config.wordings.cameraTitle = "カメラ"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        setRoundShadowButton(button: saveButton, corner: saveButton.frame.height/2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickPicture))
        pictureView.addGestureRecognizer(tap)
        
        getMyCumulativeDistance(member_id: thisUser.idx)
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @objc func pickPicture(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIView) != nil || (gesture.view as? UILabel) != nil {
            picker.didFinishPicking { [picker] items, _ in
                if let photo = items.singlePhoto {
                    self.pictureBox.image = photo.image
                    self.pictureBox.layer.cornerRadius = self.pictureBox.frame.height / 2
                    self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
                }
                picker!.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
    }
    
    @objc func nameBoxDidChange(_ textField: UITextField) {
        if textField.text!.count > 0  {
            saveButton.alpha = 1.0
        }else {
            saveButton.alpha = 0.3
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    @IBAction func toPasswordReset(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ResetPasswordViewController")
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        logout()
    }
    
    @IBAction func saveProfile(_ sender: Any) {
        
        if saveButton.alpha < 1.0 { return }
        
        if nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            showToast(msg: "あなたの名前を入力してください。")
            return
        }
        
        if (phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! > 0 && !isValidPhone(phone: phoneBox.text!){
            showToast(msg: "無効な電話番号")
            return
        }
            
        let parameters: [String:Any] = [
            "member_id" : String(thisUser.idx),
            "name" : nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "phone_number": phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
        ]
            
        if self.imageFile != nil{
            
            let ImageDic = ["file" : self.imageFile!]
            // Here you can pass multiple image in array i am passing just one
            ImageArray = NSMutableArray(array: [ImageDic as NSDictionary])
                
            self.showLoadingView()
            APIs().registerWithPicture(withUrl: SERVER_URL + "editmember", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        let json = JSON(response)
                        self.processData(json: json)
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "登録されていません。")
                        self.logout()
                    }else {
                        self.showToast(msg: "何かが間違っている。")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }else{
            self.showLoadingView()
            APIs().registerWithoutPicture(withUrl: SERVER_URL + "editmember", withParam: parameters) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        let json = JSON(response)
                        self.processData(json: json)
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "登録されていません。")
                        self.logout()
                    }else {
                        self.showToast(msg: "何かが間違っている。")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }
        
    }
    
    func processData(json:JSON){
        let data = json["data"].object as! [String: Any]
        
        let user = User()
        user.idx = data["id"] as! Int64
        user.name = data["name"] as! String
        user.email = data["email"] as! String
        user.password = data["password"] as! String
        user.picture_url = data["picture_url"] as! String
        user.phone_number = data["phone_number"] as! String
        user.status = data["status"] as! String
            
        thisUser = user

        UserDefaults.standard.set(thisUser.email, forKey: "email")
        UserDefaults.standard.set(thisUser.password, forKey: "password")
        
        showToast2(msg: "アカウントが正常に更新されました。")
        dismissViewController()
    }
    
    func getMyCumulativeDistance(member_id:Int64) {
        APIs.getMyCumulativeDistance(member_id: member_id, handleCallback: { [self]
            cumulative, result_code in
            if result_code == "0" {
                self.cumulativeBox.text = "累計距離: " + String(format: "%.2f", cumulative) + "km"
            }
        })
    }
    
}








































