//
//  DetailViewController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2022/11/25.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

//    var viewTable: Data!
    var recordList: RecordList2!
    var gamenflg : String?
    var noimage = UIImage(named:"noimage")!


    @IBOutlet weak var TextField1: UITextField!
    @IBOutlet weak var TextField2: UITextField!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var Format: UITextField!
    @IBOutlet weak var TextField3: UITextField!
    @IBOutlet weak var wantsLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var Button: UIButton!
    @IBOutlet weak var TextField4: UITextField!
    @IBOutlet weak var uiSwitch: UISwitch!
    @IBOutlet weak var bannerView: UIStackView!
    
//    @IBOutlet weak var ebayBotton: UIButton!
    var image: UIImage!
    var resizedPicture: UIImage!

    //    var formats: [String] = []
    weak var pickerView: UIPickerView?
    var wantsFlg = "false"

    @IBAction func onTapImage(_ sender: Any) {
        performSegue(withIdentifier: "toEbaySearch", sender: self )
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//print("aaaaaaaaaaaaaaa")
//print(gamenflg)
//        if gamenflg == "albumDetail" {
//            ebayBotton.isHidden = true
//        }
        
        //キーボードの状況を取得する
        NotificationCenter.default.addObserver(self, selector: #selector(showkeyboard),name:UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidekeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)

        // フォーマット初期値
//        formats.append("")
//        formats.append("Record")
//        formats.append("CD")
//        formats.append("Casett")
//        formats.append("Other")

        // フォーマットPickerView
//        let pv = UIPickerView()
//        pv.delegate = self
//        pv.dataSource = self
//        Format.delegate = self
//        Format.inputAssistantItem.leadingBarButtonGroups = []
//        Format.inputView = pv
//        self.pickerView = pv
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        // TextField
        TextField1.text = recordList.artistName
        TextField2.text = recordList.albumTitle
        TextField3.text = recordList.releaseCountry
        TextField4.text = recordList.releaseDate
        Format.text = recordList.format

        // メモの枠
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.text = recordList.memo

        //ボタンの角を丸くする
        Button.layer.cornerRadius = 10

        //wantsFlgの設定
        wantsFlg = recordList.wantsFlg ?? "false"
        if wantsFlg == "true" {
            uiSwitch.isOn = true;
            wantsLabel.text = "Added to Wants List"
        }else{
            uiSwitch.isOn = false;
            wantsLabel.text = "Added to Collection List"
        }
        
        let imageData = self.recordList.value(forKey: "albumImage") as? Data
        if let data = imageData, let img = UIImage(data: data) {
            resizedPicture = img.resize2(targetSize: CGSize(width: 80, height: 80))
            img.jpegData(compressionQuality: 0.1)
            albumImage.image = img.resize2(targetSize: CGSize(width: 80, height: 80))
            // 画像の枠
           self.albumImage.layer.borderColor = UIColor.lightGray.cgColor
            self.albumImage.layer.borderWidth = 1
         }else{
             albumImage.image = noimage
         }

        let IMOBILE_BANNER_PID = "81561"
        let IMOBILE_BANNER_MID = "567770"
        let IMOBILE_BANNER_SID = "1847197"

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
    
//    @IBAction func ebaySearch(_ sender: Any) {
//        performSegue(withIdentifier: "toEbaySearch", sender: self )
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let nextView = segue.destination as! EbayViewController
////        nextView.str = wkAlbumName
//        if segue.identifier == "toNext" {
//            nextView.flg = "add"
//        }else{
//            nextView.flg = "update"
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEbaySearch" {
            guard let destination = segue.destination as? EbayViewController else {
                fatalError("Failed to prepare EbayViewController.")
            }
            destination.recordList = recordList
        }
    }

    @IBAction func wantsSwitch(_ sender: UISwitch) {
        if ( sender.isOn ) {
            wantsLabel.text = "Add to Wants List"
            wantsFlg = "true"
        } else {
            wantsLabel.text = "Add to Collection List"
            wantsFlg = "false"
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBAction func btnTapped(_ sender: Any) {

        var flg = ""
        var errorMassage = ""
        if TextField1.text!.isEmpty == true {
            flg = "1"
            errorMassage = "Artist Name"
        }
        if flg == "" {
            if TextField2.text!.isEmpty == true {
                flg = "2"
                errorMassage = "Album Title"
            }
        }
        if flg == "" {

            recordList.artistName = TextField1.text!
            recordList.albumTitle = TextField2.text!
            recordList.format = Format.text!
            recordList.releaseCountry = TextField3.text!
            recordList.releaseDate = TextField4.text!
            recordList.wantsFlg = wantsFlg
            recordList.memo = textView.text!
            if resizedPicture != nil {
                //resizedPicture = image.resize2(targetSize: CGSize(width: 80, height: 80))
                let uploadImage = resizedPicture!.jpegData(compressionQuality: 0.1)! as NSData
                recordList.albumImage = uploadImage as Data
            }else{
                recordList.albumImage = nil
           }
        
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            if gamenflg == "albumDetail" {
                self.dismiss(animated: true, completion: nil)
            }else{
                navigationController!.popViewController(animated: true)
            }

        }else{
            let alui = UIAlertController(title: "Required", message: errorMassage, preferredStyle: UIAlertController.Style.alert)
            let btn = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil)
            alui.addAction(btn)
            present(alui, animated: true, completion: nil)
         }
   }
    
    @IBAction func photoBtnTapped(_ sender: Any) {
        // カメラロール表示
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = ["public.image"]
            present(imagePickerController,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[.originalImage] as? UIImage
        resizedPicture = image.resize2(targetSize: CGSize(width: 200, height: 200))
        albumImage.image = resizedPicture
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
//        print(loginButtonMaxY)
//        print(keyboardMinY)

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

    func resize2(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}
