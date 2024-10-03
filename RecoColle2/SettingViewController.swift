//
//  SettingController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2023/05/28.
//

import SwiftUI
import CoreData

class SettingViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    //    var recordLists: RecordList2!
    var recordLists : [RecordList2] = []
    // インジゲーターの設定
    //var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 表示位置を設定（画面中央）
        //indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        //indicator.style = .whiteLarge
        // インジケーターの色を設定（青色）
        //indicator.color = UIColor(red: 44/255, green: 169/255, blue: 225/255, alpha: 1)
        // インジケーターを View に追加
        //view.addSubview(indicator)
        //　ラベル枠の枠線太さと色
//        label1.layer.borderColor = UIColor.blue.cgColor
//        label1.layer.borderWidth = 1
       // ラベル枠を丸くする
//        label1.layer.masksToBounds = true
//        label2.layer.masksToBounds = true
//        // ラベル丸枠の半径
//        label1.layer.cornerRadius = 8
//        label2.layer.cornerRadius = 8
    }

    @IBAction func setting(_ sender: Any) {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
           UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func dataExport(_ sender: Any) {
        createFile()
    }
    
    @IBAction func dataImport(_ sender: Any) {

        let alert: UIAlertController = UIAlertController(title: "data import", message: "All registered data will be overwritten. May I?", preferredStyle:  UIAlertController.Style.alert)
        // インジケーターを表示＆アニメーション開始
        //indicator.startAnimating()

        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.loadCSV()

            let alert = UIAlertController(title: "data import", message: "Completed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            // インジケーターを非表示＆アニメーション終了
//            self.indicator.stopAnimating()
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })

        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    
    }
    
    func loadCSV() {
            
        // Documentsディレクトリまでのパスを生成
        _ = FileManager.default
        let docPath =  NSHomeDirectory() + "/Documents"
        let filePath = docPath + "/sample.csv"

        if !FileManager.default.fileExists(atPath: filePath) {
            let alert = UIAlertController(title: "restore", message: "There are no backup files.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
        } else {

                    do {
                        let csv = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
                        var groupedAttributesOfAlbums = csv.components(separatedBy: .newlines)

                        // 余計なデータを削除
                        groupedAttributesOfAlbums.removeFirst() // 先頭行のラベル
                        if groupedAttributesOfAlbums.last == "" { // 末尾の空要素（csv末尾に改行のみあれば）
                            groupedAttributesOfAlbums.removeLast()
                        }

                        // 旧データを削除
                        SettingViewController.cleanUp()
                        
                        for groupedAttributesOfAlbum in groupedAttributesOfAlbums {
                            let attributesOfAlbum = groupedAttributesOfAlbum.components(separatedBy: "|")
                            let recordLists = SettingViewController.newAlbum()
                            recordLists.id = attributesOfAlbum[0]
                            recordLists.artistName = attributesOfAlbum[1]
                            recordLists.albumTitle = attributesOfAlbum[2]
                            recordLists.format = attributesOfAlbum[3]
                            recordLists.releaseCountry = attributesOfAlbum[4]
                            recordLists.releaseDate = attributesOfAlbum[5]
                            recordLists.wantsFlg = attributesOfAlbum[6]
                            recordLists.memo = attributesOfAlbum[7]
                            
                            var image: UIImage!
                            let documentsURL:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL:URL = documentsURL.appendingPathComponent(attributesOfAlbum[0] + ".jpg")
                            image = UIImage(contentsOfFile: fileURL.path)

                            if image != nil {
                                let uploadImage = image!.jpegData(compressionQuality: 0.0)! as NSData
                                recordLists.albumImage = uploadImage as Data
                            }else{
                                recordLists.albumImage = nil
                            }

//                            if image?.pngData() != nil {
//                                let imageData = image.pngData()
//                                recordLists.albumImage = imageData
//                            }else {
//                                recordLists.albumImage = nil
//                            }

                        }
                        SettingViewController.save()
                        
                    } catch let error as NSError {
                        print("Failed to load csv: \(error).")
                        return
                    }

        }
    }
    static func save() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                abort()
            }

            appDelegate.saveContext()
        }
    static func newAlbum() -> RecordList2 {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                abort()
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "RecordList2", in: managedContext)!
            let recordLists = RecordList2(entity: entity, insertInto: managedContext)

            return recordLists
        }
    
    static func cleanUp() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }
        let viewContext = appDelegate.persistentContainer.viewContext
        for entity in appDelegate.persistentContainer.managedObjectModel.entities {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity.name!)
            let results = try! viewContext.fetch(fetchRequest)
            for result in results {
                viewContext.delete(result)
            }
        }

        if viewContext.hasChanges {
            try! viewContext.save()
        }
    }
    
    static func fetchAlbums(with predicate: NSPredicate?) -> [RecordList2] {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                abort()
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecordList2")
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "artistName", ascending: true)
            ]
            fetchRequest.includesSubentities = false

            do {
                let albums = try managedContext.fetch(fetchRequest) as! [RecordList2]
                return albums
            } catch let error as NSError {
                fatalError("Could not fetch albums. \(error), \(error.userInfo)")
            }
        }
    
    func createFile() {
        // Documentsディレクトリまでのパスを生成
        let fileManager = FileManager.default
        let docPath =  NSHomeDirectory() + "/Documents"
        print(docPath)
        let filePath = docPath + "/sample.csv"

        // データの読み込み
        getData()
        
        // データ分csvに出力
        var csv = ""
        let count = recordLists.count - 1
        if count < 0 {
            let alert = UIAlertController(title: "data export", message: "no data", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            return
        }
        for i in 0...count {
            var line = ""
            let recordList = recordLists[i]
            line += recordList.id!
            line += "|"
            line += recordList.artistName!
            line += "|"
            line += recordList.albumTitle!
            line += "|"
            if recordList.format == nil {
                line += ""
            }else{
                line += recordList.format!
            }
            line += "|"
            if recordList.releaseCountry == nil {
                line += ""
            }else{
                line += recordList.releaseCountry!
            }
            line += "|"
            if recordList.releaseDate == nil{
                line += ""
            }else{
                line += recordList.releaseDate!
            }
            line += "|"
            line += recordList.wantsFlg!
            line += "|"
            if recordList.memo == nil{
                line += ""
            }else{
                line += recordList.memo!
            }
            line += "\n"
            csv = line + csv
 
            let imageData = recordList.value(forKey: "albumImage") as? Data
            do {
                try imageData?.write(to: getFileURL(fileName: recordList.value(forKey: "id") as! String + ".jpg" ))
                print("Image saved.")
            } catch {
                print("Failed to save the image:", error)
            }
        }
        // 見出し行を先頭行に追加
        csv = "id|artistName|albumTitle|format|releaseCountry|releaseDate|wantsFlg|memo\n" + csv
        let data = csv.data(using: .utf8)
        // ファイル出力
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath:filePath, contents: data, attributes: [:])
            let alert = UIAlertController(title: "data export", message: "Completed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            
            
        }else{
            let alert: UIAlertController = UIAlertController(title: "data export", message: "A file already exists at the output destination. Can I save it?", preferredStyle:  UIAlertController.Style.alert)
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
                fileManager.createFile(atPath:filePath, contents: data, attributes: [:])
                print(filePath)
                print("出力しました。")

                let count = self.recordLists.count - 1
                for i in 0...count {
                    let recordList = self.recordLists[i]
                    let imageData = recordList.value(forKey: "albumImage") as? Data
                    do {
                        try imageData?.write(to: getFileURL(fileName: recordList.value(forKey: "id") as! String + ".jpg" ))
                        print("Image saved.")
                    } catch {
                        print("Failed to save the image:", error)
                    }

                }
        
                let alert = UIAlertController(title: "data export", message: "Completed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })

            // ③ UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)

            // ④ Alertを表示
            present(alert, animated: true, completion: nil)
        
        }
    }

    func getData(){
        let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
        let sortDescripter = NSSortDescriptor(key: "artistName", ascending: true)//ascendind:true 昇順、false 降順です
        // ソート条件
        request.sortDescriptors = [sortDescripter]
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            recordLists = try context.fetch(request)
        }
        catch{
            print("読み込み失敗！")
        }
    }
}

private func shareApp(shareText: String, shareLink: URL ) {
    let items = [shareLink] as [Any]// shareLink = テンポラリファイルの絶対パス（URL型）
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    if UIDevice.current.userInterfaceIdiom == .pad {// デバイスがiPadだったら
        let deviceSize = UIScreen.main.bounds// 画面サイズ取得
        if let popPC = activityVC.popoverPresentationController {
            // ポップオーバーの設定
            // iPadの場合、sourceView、sourceRectを指定しないとクラッシュする。
            popPC.sourceView = activityVC.view // sourceRectの基準になるView
            popPC.barButtonItem = .none// ボタンの位置起点ではない
            popPC.sourceRect = CGRect(x:deviceSize.size.width/2, y: deviceSize.size.height, width: 0, height: 0)// Popover表示起点
        }
    }
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // マルチウィンドウでは無いため、単純に一番最初の要素にアクセスして、UIWindowScene にキャスト
    let rootVC = windowScene?.windows.first?.rootViewController
    // rootVC　＝　rootViewController：アプリ初期画面（大元のViewController）
    rootVC?.present(activityVC, animated: true,completion: {})
    // アニメーション有りでシェアシート（activityVC）表示（present）
}

//func getFileURL(fileName: String) -> URL {
//    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    return docDir.appendingPathComponent(fileName)
//}

struct SettingViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
