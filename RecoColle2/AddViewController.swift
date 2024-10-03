//
//  AddViewController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2022/12/15.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var formatTextField: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var Button: UIButton!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    
//    var formats: [String] = []
    weak var pickerView: UIPickerView?
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var wantsLabel: UILabel!
    var wantsFlg = "false"
    @IBAction func wantsSwitch(_ sender: UISwitch) {
        if ( sender.isOn ) {
            wantsLabel.text = "Add to Wants List"
            wantsFlg = "true"
        } else {
            wantsLabel.text = "Add to Collection List"
            wantsFlg = "false"
        }
    }
    @IBOutlet weak var bannerView: UIStackView!

    var image: UIImage!
    var resizedPicture: UIImage!

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        //キーボードの状況を取得する
        NotificationCenter.default.addObserver(self, selector: #selector(showkeyboard),name:UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidekeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        wantsLabel.text = "Add to Collection List"
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        // メモの枠
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.layer.borderWidth = 1.0
        //ボタンの角を丸くする
        Button.layer.cornerRadius = 10
        // 画像の枠
        self.albumImage.layer.borderColor = UIColor.lightGray.cgColor
        self.albumImage.layer.borderWidth = 1

        let IMOBILE_BANNER_PID = "81561"
        let IMOBILE_BANNER_MID = "567770"
        let IMOBILE_BANNER_SID = "1847196"

        ImobileSdkAds.setTestMode(fromAppDelegate.globalTestMode)
        // スポット情報を設定します
        ImobileSdkAds.register(withPublisherID: IMOBILE_BANNER_PID, mediaID:IMOBILE_BANNER_MID, spotID:IMOBILE_BANNER_SID)
        DispatchQueue.global().async {
            // 広告の取得を開始します
            ImobileSdkAds.start(bySpotID: IMOBILE_BANNER_SID)
        }

        // 表示する広告のサイズ
        let imobileAdSize = CGSizeMake(320, 50)
        // デバイスの画面サイズ
        let screenSize = UIScreen.main.bounds.size
        // 広告の表示位置を算出(画面中央下)
        let imobileAdPosX: CGFloat = (screenSize.width - imobileAdSize.width) / 2
        let imobileAdPosY: CGFloat = 0

        // 広告を表示するViewを作成します
        let imobileAdView = UIView(frame: CGRectMake(imobileAdPosX, imobileAdPosY, imobileAdSize.width, imobileAdSize.height))
        //広告を表示するViewをViewControllerに追加します
        self.bannerView.addSubview(imobileAdView)
        // 広告を表示します
        ImobileSdkAds.showBySpotID(forAdMobMediation: IMOBILE_BANNER_SID, view: imobileAdView)
        
    }
// pickerView
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return formats.count
//    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return formats[row]
//    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        formatTextField.text = formats[row]
//    }
// add Buttom
    @IBAction func btnTapped(_ sender: Any) {
        var flg = ""
        var errorMassage = ""
        
//        if image?.pngData() != nil {
//            let imageData = image.pngData()
//            recordList.albumImage = imageData
//        }else {
//            recordList.albumImage = nil
//        }

        if textField.text!.isEmpty == true {
            flg = "1"
            errorMassage = "Artist Name"
        }
        if flg == "" {
            if textField2.text!.isEmpty == true {
                flg = "2"
                errorMassage = "Album Title"
            }
        }
//        if flg == "" {
//            if formatTextField.text!.isEmpty == true {
//                flg = "3"
//                errorMassage = "Format"
//            }
//        }
        if flg == "" {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let recordList = RecordList2(context: context)
            recordList.artistName = textField.text!
            recordList.albumTitle = textField2.text!
            recordList.format = formatTextField.text!
            recordList.releaseCountry = textField3.text!
            recordList.memo = memoTextView.text!
            recordList.wantsFlg = wantsFlg
            recordList.releaseDate = textField4.text!
            let myid: String = NSUUID().uuidString
            recordList.id = myid

            if resizedPicture != nil {
                resizedPicture = image.resize(targetSize: CGSize(width: 80, height: 80))
                let uploadImage = resizedPicture!.jpegData(compressionQuality: 0.1)! as NSData
                recordList.albumImage = uploadImage as Data
            }else{
                recordList.albumImage = nil
            }
//            if image != nil {
//                let uploadImage = image!.jpegData(compressionQuality: 0.0)! as NSData
//                recordList.albumImage = uploadImage as Data
//            }else{
//                recordList.albumImage = nil
//            }

            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController!.popViewController(animated: true)
        }else{
            let alui = UIAlertController(title: "Required", message: errorMassage, preferredStyle: UIAlertController.Style.alert)
            let btn = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil)
            alui.addAction(btn)
            present(alui, animated: true, completion: nil)
         }
    }
// 画像選択
    @IBAction func photoBtnTapped(_ sender: Any) {
    // カメラロール表示
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController,animated: true,completion: nil)
    }
    // カメラロール表示
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[.originalImage] as? UIImage
        resizedPicture = image.resize(targetSize: CGSize(width: 200, height: 200))

//        albumImage.image = image
        albumImage.image = resizedPicture
        self.albumImage.layer.borderColor = UIColor.blue.cgColor
        self.albumImage.layer.borderWidth = 1
        picker.dismiss(animated: true)
    }
    //キーボード表示時
    @objc func showkeyboard(notification:Notification){
        //print("Keyboard表示")
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]as AnyObject).cgRectValue
        //キーボードの一番上の座標（Y座標）
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        //ログインボタンの一番下の座標（Y座標）
        let loginButtonMaxY = bannerView.frame.maxY
        
        let distance = loginButtonMaxY - keyboardMinY + 20
        //print(loginButtonMaxY)
        //print(keyboardMinY)
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        //ビューを上げる時のアニメーション
        UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping:1, initialSpringVelocity:1, options:[], animations: {
            self.view.transform = transform
        })
        
    }
    //キーボード非表示時
    @objc func hidekeyboard(){
        //print("keyboard非表示")
        
        //ビューを下げる時のアニメーション
        UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping:1, initialSpringVelocity:1, options:[], animations: {
            self.view.transform = .identity
        })
    }
 
    //他の部分を触ったときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}
