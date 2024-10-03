//
//  SettingsTableViewController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2023/10/05.
//

//import UIKit
import SwiftUI
import CoreData

class SettingsTableViewController: UITableViewController {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var recordLists : [RecordList2] = []
    var albums : [Albums] = []

    @IBOutlet weak var version_detail: UILabel!
    @IBOutlet weak var bannerView: UIView!
    @IBAction func dataImport(_ sender: UIButton) {
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
    
    @IBAction func dataExport(_ sender: UIButton) {
        _ = FileManager.default
        let docPath =  NSHomeDirectory() + "/Documents"
        let files = getFileInfoListInDir(docPath)
        //print(files)
        files.forEach { file in
            let deletefile = (docPath + "/" + file)
            //print (deletefile)
            do {
                try FileManager.default.removeItem(atPath: deletefile)
            } catch {
                print(error.localizedDescription)
            }
        }
        createFile()

    }
    func getFileInfoListInDir(_ dirName: String) -> [String] {
        let fileManager = FileManager.default
        let files: [String]
        do {
            files = try fileManager.contentsOfDirectory(atPath: dirName)
        } catch {
            let files : [String] = []
            return files
        }
        return files
    }
    @IBAction func dataDelete(_ sender: UIButton) {

        let alert: UIAlertController = UIAlertController(title: "data delete", message: "All registered data will be deleted. May I?", preferredStyle:  UIAlertController.Style.alert)
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            SettingsTableViewController.cleanUp()

            let alert = UIAlertController(title: "data delete", message: "Completed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get version info/ build number
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String{
            version_detail.text = "Version: \(version)"
        }
//            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
//            version_detail.text = "Version: \(version)  Buld: \(build)"
//        }

        let IMOBILE_BANNER_PID = "81561"
        let IMOBILE_BANNER_MID = "567770"
        let IMOBILE_BANNER_SID = "1847198"

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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // それぞれのセクション毎に何行のセルがあるかを返します
        switch section {
        case 0: // 「設定」のセクション
            return 2
        case 1: // 「その他」のセクション
            return 3
        default: // ここが実行されることはないはず
            return 0
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func loadCSV() {
            
        // Documentsディレクトリまでのパスを生成
        _ = FileManager.default
        let docPath =  NSHomeDirectory() + "/Documents"
        let filePath = docPath + "/sample.csv"
        let filePath2 = docPath + "/sample2.csv"

        if !FileManager.default.fileExists(atPath: filePath) {
            let alert = UIAlertController(title: "restore", message: "There are no backup files.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
        } else {
                    do {
                        // recordlists2
                        let csv = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
                        var groupedAttributesOfAlbums = csv.components(separatedBy: .newlines)
                        // 余計なデータを削除
                        groupedAttributesOfAlbums.removeFirst() // 先頭行のラベル
                        if groupedAttributesOfAlbums.last == "" { // 末尾の空要素（csv末尾に改行のみあれば）
                            groupedAttributesOfAlbums.removeLast()
                        }
                        // 旧データを削除
                        SettingsTableViewController.cleanUp()
                        
                        for groupedAttributesOfAlbum in groupedAttributesOfAlbums {
                            let attributesOfAlbum = groupedAttributesOfAlbum.components(separatedBy: "|")
                            let recordLists = SettingsTableViewController.newAlbum()
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

                        }
                        SettingsTableViewController.save()

                        
//                        // albums
                        let csv2 = try String(contentsOfFile: filePath2, encoding: String.Encoding.utf8)
                        var groupedAttributesOfAlbums2 = csv2.components(separatedBy: .newlines)
                        // 余計なデータを削除
                        groupedAttributesOfAlbums2.removeFirst() // 先頭行のラベル
                        if groupedAttributesOfAlbums2.last == "" { // 末尾の空要素（csv末尾に改行のみあれば）
                            groupedAttributesOfAlbums2.removeLast()
                        }
                        // 旧データを削除
                        //SettingsTableViewController.cleanUp()
                        
                        for groupedAttributesOfAlbum2 in groupedAttributesOfAlbums2 {
                            let attributesOfAlbum2 = groupedAttributesOfAlbum2.components(separatedBy: "|")
                            let albums = SettingsTableViewController.newAlbum2()
                            albums.id = attributesOfAlbum2[0]
                            albums.albumName = attributesOfAlbum2[1]
                            albums.idRecordList2 = attributesOfAlbum2[2]
                        }
                        SettingsTableViewController.save()
                        
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
    static func newAlbum2() -> Albums {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                abort()
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Albums", in: managedContext)!
            let albums = Albums(entity: entity, insertInto: managedContext)

            return albums
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
        //print(docPath)
        let filePath = docPath + "/sample.csv"
        let filePath2 = docPath + "/sample2.csv"

        // データの読み込み
        getData()
        
        // データ分csvに出力
        //RecordList2
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
                //print("Image saved.")
            } catch {
                print("Failed to save the image:", error)
            }
        }
        // 見出し行を先頭行に追加
        csv = "id|artistName|albumTitle|format|releaseCountry|releaseDate|wantsFlg|memo\n" + csv
        let data = csv.data(using: .utf8)

        //Albums
        var csv2 = ""
        let count2 = albums.count - 1
        if count2 < 0 {
//            let alert = UIAlertController(title: "data export", message: "no data", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true, completion: nil)
//            return
            print("albums no data")
        }else{
            for i in 0...count2 {
                var line2 = ""
                let album = albums[i]
                line2 += album.id!
                line2 += "|"
                line2 += album.albumName!
                line2 += "|"
                line2 += album.idRecordList2!
                line2 += "\n"
                csv2 = line2 + csv2
            }
        }
        // 見出し行を先頭行に追加
        csv2 = "id|albumName|idRecordList2\n" + csv2
        let data2 = csv2.data(using: .utf8)



        // ファイル出力
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath:filePath, contents: data, attributes: [:])
            fileManager.createFile(atPath:filePath2, contents: data2, attributes: [:])
            let alert = UIAlertController(title: "data export", message: "Completed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            
            
        }else{
            let alert: UIAlertController = UIAlertController(title: "data export", message: "A file already exists at the output destination. Can I save it?", preferredStyle:  UIAlertController.Style.alert)
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                //print("OK")
                fileManager.createFile(atPath:filePath, contents: data, attributes: [:])
                fileManager.createFile(atPath:filePath2, contents: data2, attributes: [:])
                //print(filePath)
                //print("出力しました。")

                let count = self.recordLists.count - 1
                for i in 0...count {
                    let recordList = self.recordLists[i]
                    let imageData = recordList.value(forKey: "albumImage") as? Data
                    do {
                        try imageData?.write(to: getFileURL(fileName: recordList.value(forKey: "id") as! String + ".jpg" ))
                        //print("Image saved.")
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
                //print("Cancel")
            })

            // ③ UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)

            // ④ Alertを表示
            present(alert, animated: true, completion: nil)
        
        }
    }

    func getData(){

        //RecordList2
        let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
        let sortDescripter = NSSortDescriptor(key: "artistName", ascending: true)
        request.sortDescriptors = [sortDescripter]
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            recordLists = try context.fetch(request)
        }
        catch{
            print("読み込み失敗！")
        }

        //Albums
        let request2 = NSFetchRequest<Albums>(entityName: "Albums")
        let sortDescripter2 = NSSortDescriptor(key: "albumName", ascending: true)
        request2.sortDescriptors = [sortDescripter2]
        let context2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            albums = try context2.fetch(request2)
        }
        catch{
            print("読み込み失敗2！")
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

func getFileURL(fileName: String) -> URL {
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return docDir.appendingPathComponent(fileName)
}

