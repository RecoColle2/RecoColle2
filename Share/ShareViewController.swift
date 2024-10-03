//
//  ShareViewController.swift
//  Share
//
//  Created by 丸田信一 on 2023/09/17.
//

//import UIKit
import Social
//import Foundation
import CoreData
//HTTP通信してくれるやつ
import Alamofire
//スクレイピングしてくれるやつ
import Kanna

class NSCustomPersistentContainer: NSPersistentCloudKitContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.marume3591.RecoColle2")
        storeURL = storeURL?.appendingPathComponent("DataModel.sqlite")
        return storeURL!
    }

}

class ShareViewController: SLComposeServiceViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
    
    override func loadPreviewView() -> UIView! {
            return DummyPreview()
        }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {

        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.

//        let kUTTypeURL:String  = "public.url"
//        let item:NSExtensionItem = self.extensionContext!.inputItems.first as! NSExtensionItem
//        for (itemProvider) in item.attachments! {
//                if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypeURL)) {
//                    itemProvider.loadItem(forTypeIdentifier: String(kUTTypeURL), options: nil, completionHandler: { (item, error) in
//                            if let url: NSURL = item as? NSURL {
//                                var disArtistName = "" as String
//                                var disAlbumTitle = "" as String
//                                var disFormat = "" as String
//                                var disRleaseDate = "" as String
//                                var disRleaseCountry = "" as String
//                                let context = self.persistentContainer.viewContext
//                                let urlStr = url.absoluteString
//                                let urlStr2 = urlStr?.replacingOccurrences(of: "/ja/", with: "/")
//                                print("qqqqqqqqqqqqqqqqq")
//                                print(urlStr2 as Any)
//                                var resizedPicture: UIImage!
//
//                                    let recordList = RecordList2(context: context)
//                                    //スクレイピング対象のサイトを指定
//                                    AF.request(urlStr2!).responseString { response in
//                                        switch response.result {
//                                            case .success(let value):
//                                                if let doc = try? HTML(html: value, encoding: .utf8) {
//                                                    var sizes1 = [String]()
//                                                    var sizes2 = [String]()
//                                                    var sizes3 = [String]()
//                                                    var sizes4 = [String]()
//                                                    var sizes5 = [String]()
//
//                                                    // title
//                                                    for link in doc.xpath("//title") {
//                                                        print("== title ==")
//                                                        sizes1.append(link.text ?? "")
//                                                        sizes1.append(link.toHTML ?? "")
//                                                        sizes1.append(link.innerHTML ?? "")
//                                                    }
//                                                    
//                                                    for (_, value) in sizes1.enumerated() {
//                                                        if value.contains("–"){
//                                                            let splitResult2 = value.components(separatedBy: "–")
//                                                            disArtistName = splitResult2[0].trimmingCharacters(in: .whitespaces)
//                                                            if splitResult2[1].contains("-"){
//                                                                let splitResult3 = splitResult2[1].components(separatedBy: "-")
//                                                                disAlbumTitle = splitResult3[0].trimmingCharacters(in: .whitespaces)
//                                                            }else{
//                                                                disAlbumTitle = splitResult2[1].trimmingCharacters(in: .whitespaces)
//                                                            }
//                                                        }else{
//                                                            if value.contains("–"){
//                                                                let splitResult2 = value.components(separatedBy: "–")
//                                                                disArtistName = splitResult2[0].trimmingCharacters(in: .whitespaces)
//                                                                if splitResult2[1].contains("-"){
//                                                                    let splitResult3 = splitResult2[1].components(separatedBy: "-")
//                                                                    disAlbumTitle = splitResult3[0].trimmingCharacters(in: .whitespaces)
//                                                                }else{
//                                                                    disAlbumTitle = splitResult2[1].trimmingCharacters(in: .whitespaces)
//                                                                }
//                                                            }else{
//                                                                disArtistName = value.trimmingCharacters(in: .whitespaces)
//                                                            }
//                                                        }
//                                                    }
//
//                                                    // format
//                                                    for link in doc.xpath("//div[@class='format_item_3SAJn']") {
//                                                        sizes2.append(link.text ?? "")
//                                                    }
//                                                    for (_, value) in sizes2.enumerated() {
//                                                        disFormat = value
//                                                    }
//
//                                                    // release date
//                                                    for link in doc.xpath("//time") {
//                                                        sizes3.append(link.text ?? "")
//                                                    }
//                                                    for (index, value) in sizes3.enumerated() {
//                                                        if index == 0 {
//                                                            disRleaseDate = value
//                                                        }else{
//                                                            break
//                                                        }
//                                                    }
//
//                                                    // release country
//                                                    for link in doc.xpath("//div[@class='info_23nnx']") {
//                                                        sizes4.append(link.text ?? "")
//                                                    }
//                                                    for (_, value) in sizes4.enumerated() {
//                                                        let splitResult2 = value.components(separatedBy: ":")
//                                                        disRleaseCountry = splitResult2[3].trimmingCharacters(in: .whitespaces)
////                                                        print(disRleaseCountry)
//                                                        if let range = disRleaseCountry.range(of: "Released") {
//                                                            disRleaseCountry.removeSubrange(range)
//                                                        }
//                                                    }
//
//                                                    // img
//                                                    for link in doc.css("img") {
//                                                        sizes5.append(link["src"] ?? "")
//                                                    }
//                                                    for (index, value) in sizes5.enumerated() {
//                                                        if index == 1 {
//                                                            guard let url = URL(string: value) else {
//                                                                        //print("エラー1")
//                                                                        return
//                                                            }
//                                                            do {
//                                                                let data = try Data(contentsOf: url)
//                                                                guard let image = UIImage(data: data) else {
//                                                                    //print("エラー2")
//                                                                    return
//                                                                }
//                                                                resizedPicture = image.resize3(targetSize: CGSize(width: 80, height: 80))
//                                                            } catch {
//                                                                //print("エラー3")
//                                                                return
//                                                            }
//                                                        }else{
//                                                            if index > 1 {
//                                                                break
//                                                            }
//                                                        }
//                                                    }
//                                                    if  disArtistName == "" {                                                        recordList.artistName = "error"
//                                                    }else{
//                                                        recordList.artistName = disArtistName
//                                                    }
//                                                    if disAlbumTitle == "" {
//                                                        recordList.albumTitle = "error"
//                                                    }else{
//                                                        recordList.albumTitle = disAlbumTitle
//                                                    }
//                                                    if disFormat == "" {
//                                                        recordList.format = "error"
//                                                    }else{
//                                                        recordList.format = disFormat
//                                                    }
//                                                    if disRleaseDate == "" {
//                                                        recordList.releaseDate = "error"
//                                                    }else{
//                                                        recordList.releaseDate = disRleaseDate
//                                                    }
//                                                    if disRleaseCountry == "" {
//                                                        recordList.releaseCountry = "error"
//                                                    }else{
//                                                        recordList.releaseCountry = disRleaseCountry
//                                                    }
//                                                    recordList.wantsFlg = "false"
//                                                    if resizedPicture != nil {
//                                                        let uploadImage = resizedPicture!.jpegData(compressionQuality: 0.1)! as NSData
//                                                        recordList.albumImage = uploadImage as Data
//                                                    }else{
//                                                        recordList.albumImage = nil
//                                                    }
//                                                    let myid: String = NSUUID().uuidString
//                                                    recordList.id = myid
//
//                                                    //print("save")
//                                                    try? context.save()
//                                                }
//                                            case .failure(let error):
//                                                print(error)
//                                            }
//                                            
//                                        }                                    
//                            }
//                    })
//                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                }
//        }

        let extensionItem: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first!

        let kUTTypeURL:String  = "public.url"
        let puclicURL = String(kUTTypeURL)  // "public.url"

        // shareExtension で NSURL を取得
        if ((itemProvider?.hasItemConformingToTypeIdentifier(puclicURL)) != nil) {
            itemProvider?.loadItem(forTypeIdentifier: puclicURL, options: nil, completionHandler: { (item, error) in
                // NSURLを取得する
                if let url: NSURL = item as? NSURL {
                    //print("aaaaaaaaaaaaaaaaaaa")
                    print(url)
                    var disArtistName = "" as String
                    var disAlbumTitle = "" as String
                    var disFormat = "" as String
                    var disRleaseDate = "" as String
                    var disRleaseCountry = "" as String
                    let context = self.persistentContainer.viewContext
                    let urlStr = url.absoluteString
                    let urlStr2 = urlStr?.replacingOccurrences(of: "/ja/", with: "/")
                    var resizedPicture: UIImage!

                        let recordList = RecordList2(context: context)
                        //スクレイピング対象のサイトを指定
                        AF.request(urlStr2!).responseString { response in
                            switch response.result {
                                case .success(let value):
                                    if let doc = try? HTML(html: value, encoding: .utf8) {
                                        var sizes1 = [String]()
                                        var sizes2 = [String]()
                                        var sizes3 = [String]()
                                        var sizes5 = [String]()

                                        // title
                                        for link in doc.xpath("//title") {
//                                            print("== title ==")
                                            sizes1.append(link.text ?? "")
                                        }
                                        for (_, value) in sizes1.enumerated() {
//                                            print("222222222")
//                                            print(value)
                                            if value.contains("–"){
                                                let splitResult2 = value.components(separatedBy: "–")
                                                disArtistName = splitResult2[0].trimmingCharacters(in: .whitespaces)
                                                if splitResult2[1].contains("("){
                                                    let splitResult3 = splitResult2[1].components(separatedBy: "(")
                                                    disAlbumTitle = splitResult3[0].trimmingCharacters(in: .whitespaces)
                                                }else{
                                                    disAlbumTitle = splitResult2[1].trimmingCharacters(in: .whitespaces)
                                                }
//                                                print("disArtistName")
//                                                print(disArtistName)
//                                                print("disAlbumTitle")
//                                                print(disAlbumTitle)
                                                

                                            }else
                                            if value.contains("-"){
                                                let splitResult2 = value.components(separatedBy: "-")
                                                disArtistName = splitResult2[0].trimmingCharacters(in: .whitespaces)
                                                if splitResult2[1].contains("("){
                                                    let splitResult3 = splitResult2[1].components(separatedBy: "(")
                                                    disAlbumTitle = splitResult3[0].trimmingCharacters(in: .whitespaces)
                                                }else{
                                                    disAlbumTitle = splitResult2[1].trimmingCharacters(in: .whitespaces)
                                                }
//                                                print("disArtistName")
//                                                print(disArtistName)
//                                                print("disAlbumTitle")
//                                                print(disAlbumTitle)
                                                let splitResult4 = disAlbumTitle.components(separatedBy: "|")
//                                                print(splitResult4[0])
                                                disAlbumTitle = splitResult4[0]
                                            }

                                        }
                                        // format
//                                        for link in doc.xpath("//div[@class='format_item_3SAJn']") {
//                                        for link in doc.xpath("//span[@class='MuiTypography-root MuiTypography-labelSmall css-lludyt']") {
                                        for link in doc.xpath("//a[@class='MuiTypography-root MuiTypography-labelSmall MuiLink-root MuiLink-underlineAlways css-13pr5sl']") {
//                                            print("9999999")
//                                            print(link.toHTML as Any)
//                                            sizes2.append(link.text ?? "")
//                                            sizes2.append(link.toHTML ?? "")
                                            let str : String = link.toHTML ?? ""
                                            if str.contains("format") { // -> true
//                                                print("formatが含まれる")
//                                                print(str)
                                                sizes2.append(link.text ?? "")
                                            }
                                            if str.contains("country") { // -> true
//                                                print("countryが含まれる")
//                                                print(str)
                                                sizes2.append(link.text ?? "")
                                            }
                                            if str.contains("datetime") { // -> true
//                                                print("datetimeが含まれる")
//                                                print(str)
                                                sizes2.append(link.text ?? "")
                                            }
//                                            print("9999999")
//                                            print(link.toHTML as Any)

                                        }
                                        for (index, value) in sizes2.enumerated() {
//                                            print("888888")
//                                            print(index)
                                            if index == 0 {
                                                disFormat = value
                                            }
                                            if index == 1 {
                                                disRleaseCountry = value
                                            }
                                            if index == 2 {
                                                disRleaseDate = value
                                                break
                                            }
                                        }

//                                        print("999999")
//                                        print(disFormat)
//                                        print(disRleaseCountry)
//                                        print(disRleaseDate)
                                        
                                        if disRleaseDate == "" {
                                        // release date
                                            for link in doc.xpath("//time") {
                                                sizes3.append(link.text ?? "")
                                            }
                                            for (index, value) in sizes3.enumerated() {
                                                if index == 0 {
                                                    disRleaseDate = value
                                                }else{
                                                    break
                                                }
                                            }
                                        }

                                        // release country
//                                        for link in doc.xpath("//div[@class='info_23nnx']") {
//                                            sizes4.append(link.text ?? "")
//                                        }
//                                        for (_, value) in sizes4.enumerated() {
//                                            let splitResult2 = value.components(separatedBy: ":")
//                                            disRleaseCountry = splitResult2[3].trimmingCharacters(in: .whitespaces)
//                                            if let range = disRleaseCountry.range(of: "Released") {
//                                                disRleaseCountry.removeSubrange(range)
//                                            }
//                                        }

                                        // img
                                        for link in doc.css("img") {
                                            sizes5.append(link["src"] ?? "")
                                        }
                                        for (index, value) in sizes5.enumerated() {
                                            if index == 0 {
                                                guard let url = URL(string: value) else {
                                                            //print("エラー1")
                                                            return
                                                }
                                                do {
                                                    let data = try Data(contentsOf: url)
                                                    //print("ppppppppppppppppppppppppppppppppppppppp")
                                                    //print(url)
                                                    guard let image = UIImage(data: data) else {
                                                        //print("エラー2")
                                                        return
                                                    }
                                                    resizedPicture = image.resize3(targetSize: CGSize(width: 80, height: 80))
                                                } catch {
                                                    //print("エラー3")
                                                    return
                                                }
                                            }else{
                                                if index > 1 {
                                                    break
                                                }
                                            }
                                        }
                                        if  disArtistName == "" {
//                                            recordList.artistName = "error"
                                        }else{
                                            recordList.artistName = disArtistName
                                        }
                                        if disAlbumTitle == "" {
//                                            recordList.albumTitle = "error"
                                        }else{
                                            recordList.albumTitle = disAlbumTitle
                                        }
                                        if disFormat == "" {
//                                            recordList.format = "error"
                                        }else{
                                            recordList.format = disFormat
                                        }
                                        if disRleaseDate == "" {
//                                            recordList.releaseDate = "error"
                                        }else{
                                            recordList.releaseDate = disRleaseDate
                                        }
                                        if disRleaseCountry == "" {
//                                            recordList.releaseCountry = "error"
                                        }else{
                                            recordList.releaseCountry = disRleaseCountry
                                        }
                                        recordList.wantsFlg = "false"
                                        if resizedPicture != nil {
                                            let uploadImage = resizedPicture!.jpegData(compressionQuality: 0.1)! as NSData
                                            recordList.albumImage = uploadImage as Data
                                        }else{
                                            recordList.albumImage = nil
                                        }
                                        let myid: String = NSUUID().uuidString
                                        recordList.id = myid

                                        //print("save")
                                        try? context.save()
                                    }
                                case .failure(let error):
                                    print(error)
                                }

                            }
                    // ----------
                    // 保存処理
                    // ----------
//                    let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
//                    sharedDefaults.set(url.absoluteString!, forKey: self.keyName)  // そのページのURL保存
//                    sharedDefaults.synchronize()
                }
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            })
        }

    }
    
    override func configurationItems() -> [Any]! {
        return []
    }

    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSCustomPersistentContainer(name: "DataModel")

            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    print(error.localizedDescription)
                }
            })
            return container
        }()

}
//class Gyudon: NSObject {
//    var size: String = ""
//    var price: String = ""
//}

extension UIImage {

    func resize3(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}

class DummyPreview: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: 120)
    }
}
