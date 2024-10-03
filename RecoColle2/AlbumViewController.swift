//
//  AlbumViewController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2024/02/25.
//

import UIKit
import CoreData


class AlbumViewController: UIViewController {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var sortFlg = true
    var albums : [Albums] = []
    var counts = 0
    var uniqueCount = 0
    var uniqueValues : [String] = []
    var uniqueValues2 : [String] = []
    var column2 : [Int] = []
    var tbl_index:[[Int]] = [[]]
    var recordLists : [RecordList2] = []
    var wkAlbumName = ""
    var albumName: UITextField!
    
    @IBOutlet weak var BannerView: UIView!
    
    @IBAction func addButton(_ sender: UIButton) {
        var alertTextField: UITextField?
        //部品のアラートを作る
        let alertController = UIAlertController(title: "Add New Album", message: "Input Album Name", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) in alertTextField = textField})
        //ちなみにUIAlertControllerStyle.alertをactionsheetに変えると下からにょきっと出てくるやつになるよ
        alertController.addAction(UIAlertAction(title: "Cancel",style: UIAlertAction.Style.cancel,handler: nil))
        //OKボタン追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action:UIAlertAction!) in
            if alertTextField?.text == "" {
                return
            }
            if let text = alertTextField?.text {
                self.wkAlbumName = text
            }
            //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 0.5秒後に実行したい処理
                self.performSegue(withIdentifier: "toNext", sender: nil)
            }})
        alertController.addAction(okAction)
        //アラートを表示する
        present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        //albumName.text = ""
        getData()
        TableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let IMOBILE_BANNER_PID = "81561"
        let IMOBILE_BANNER_MID = "567770"
        let IMOBILE_BANNER_SID = "1857230"

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
        self.BannerView.addSubview(imobileAdView)
        // 広告を表示します
        ImobileSdkAds.showBySpotID(forAdMobMediation: IMOBILE_BANNER_SID, view: imobileAdView)


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextView = segue.destination as! AlbumDetailViewController
        nextView.str = wkAlbumName
        if segue.identifier == "toNext" {
            nextView.flg = "add"
        }else{
            nextView.flg = "update"
        }
    }

    func getData(){
        let request = NSFetchRequest<Albums>(entityName: "Albums")
        // ソート条件
        let sortDescripter1 = NSSortDescriptor(key: "albumName", ascending: sortFlg)
        //let sortDescripter2 = NSSortDescriptor(key: "id", ascending: sortFlg)
        //request.sortDescriptors = [sortDescripter1, sortDescripter2]
        request.sortDescriptors = [sortDescripter1]

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            albums = try context.fetch(request)
            counts = albums.count
            getAfter()
        }
        catch{
            print("読み込み失敗！")
        }
    }

    func getAfter() {
        var column1 : [String] = []
        column2 = []
        uniqueValues2 = []
        var index = 0
        var index2 = 0
        var wk_artistName = ""
        tbl_index = [[]]
        for myData in albums {

            let wk_tbl_artistName = myData.value(forKey: "albumName") as! String
            column1.append(String(wk_tbl_artistName))
            if index2 == 0 {
                wk_artistName = String(wk_tbl_artistName)
            }
            if wk_artistName != String(wk_tbl_artistName) {
                index = index + 1
                wk_artistName = String(wk_tbl_artistName)
                tbl_index.append([])
            }
            
            tbl_index[index].append(index2)
            index2 = index2 + 1
        }
        //配列の重複要素を数える
        var wk_elt : String = ""
        var cnt = 0
        for elt in column1 {
            if wk_elt == ""{
                wk_elt = elt
            }
            if wk_elt == elt {
                cnt = cnt + 1
            }else{
                column2.append(cnt)
                wk_elt = elt
                cnt = 1
            }
        }
        column2.append(cnt)
        
        let orderedSet = NSOrderedSet(array: column1)
        uniqueValues = orderedSet.array as! [String]
        //uniqueCount = uniqueValues.count
        for wk in uniqueValues{
            let aaa = wk as String
            let bbb = aaa.prefix(1)
            uniqueValues2.append(String(bbb))
        }
        uniqueCount = uniqueValues2.count
    }
}

extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    /// データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return uniqueCount
    }
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        let album = albums[tbl_index[indexPath.section][indexPath.row]]
        let title = cell.contentView.viewWithTag(1) as! UILabel
        let labelCounts = cell.contentView.viewWithTag(3) as! UILabel
        title.text = album.albumName
        labelCounts.text = "(\(tbl_index[indexPath.section].count))"

        let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
        let predicate = NSPredicate(format: "id == %@", album.idRecordList2!)
        request.predicate = predicate
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            recordLists = try context.fetch(request)
        }
        catch{
            print("読み込み失敗！")
        }
        let recordList = recordLists[0]
        let albumImage = cell.contentView.viewWithTag(2) as! UIImageView
        let imageData = recordList.albumImage
        if imageData != nil {
            let img : UIImage? = UIImage(data: imageData! as Data)
            albumImage.image = img
            albumImage.contentMode = .scaleAspectFill
        }else{
            let img : UIImage? = UIImage(data: "".data(using: String.Encoding.utf8)! as Data)
            albumImage.image = img
            albumImage.contentMode = .scaleAspectFill
        }


        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath){
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if editingStyle == .delete{
            let record = albums[tbl_index[indexPath.section][indexPath.row]]
            let request = NSFetchRequest<Albums>(entityName: "Albums")
            let predicate = NSPredicate(format: "albumName == %@", record.albumName!)
            request.predicate = predicate
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                let results = try! context.fetch(request)
                for result in results {
                    context.delete(result)
                }
                if context.hasChanges {
                    try! context.save()
                }

            }
        }
        getData()
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[tbl_index[indexPath.section][indexPath.row]]
        wkAlbumName = album.albumName!
        performSegue(withIdentifier: "toNext2", sender: self )

    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return .leastNormalMagnitude
    }
}
