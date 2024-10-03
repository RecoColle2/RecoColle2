import UIKit
import CoreData
import SwiftUI
import AppTrackingTransparency
import AdSupport


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate  {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var noimage = UIImage(named:"noimage")!
    var addButtonItem: UIBarButtonItem! // 追加ボタン
    var wantsFlg = "false"
    var sortFlg = true
    var recordLists : [RecordList2] = []
    var uniqueCount = 0
    var uniqueValues : [String] = []
    var uniqueValues2 : [String] = []
    var column2 : [Int] = []
    var tbl_index:[[Int]] = [[]]

    @IBAction func goButton(_ sender: Any) {
        let url = NSURL(string: "https://www.discogs.com")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    @IBAction func refleshbtnTapped(_ sender: UIButton) {
        searchBar.text = nil
        getData()
        myTableView.reloadData()
    }
    @IBOutlet weak var recordCount: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bannerView: UIView!
    var word = ""
    
    // 追加
//    override func viewWillAppear(_ animated: Bool) {
//      super.viewWillAppear(animated)
//      navigationController?.isNavigationBarHidden = false
//    }

    // 追加
//    override func viewWillDisappear(_ animated: Bool) {
//      super.viewWillDisappear(animated)
//      navigationController?.isNavigationBarHidden = true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
        configureRefreshControl()  //この関数を実行することで更新処理がスタート
        
        searchBar.delegate = self
        self.searchBar.autocapitalizationType = .none
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        myTableView.rowHeight = 90
        addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = addButtonItem
        let IMOBILE_BANNER_PID = "81561"
        let IMOBILE_BANNER_MID = "567770"
        let IMOBILE_BANNER_SID = "1846313"
        
        ImobileSdkAds.setTestMode(fromAppDelegate.globalTestMode)
        print(fromAppDelegate.globalTestMode)
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

    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        print("追加ボタンが押されました")
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        searchBar.text = nil
        getData()
        myTableView.reloadData()
        let apple_id = "6474089598"
        AppVersionCompare.toAppStoreVersion(appId: apple_id) { (type) in
                    switch type {
                    case .latest:
                        print("new version")
                    case .old:
                        print("old version")
                        DispatchQueue.main.async {
                            let alert: UIAlertController = UIAlertController(title: "Alert", message: "I have the latest version", preferredStyle: .alert)
                            //OKボタン
                            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
                                //ボタンが押された時の処理
                                (action: UIAlertAction) -> Void in
                                            print("OK")
                                // アプリのURL
                                    let url = URL(string: "https://apps.apple.com/app/id6474089598")!
                                    // URLを開けるかをチェックする
                                    if UIApplication.shared.canOpenURL(url) {
                                        // URLを開く
                                        UIApplication.shared.open(url, options: [:]) { success in
                                            if success {
                                                print("Launching \(url) was successful")
                                            }
                                        }
                                    }
                            })
                            //キャンセルボタン
                            let cancelAction: UIAlertAction = UIAlertAction(title: "CANCEL", style: .default, handler: {
                                //ボタンが押された時の処理
                                (action: UIAlertAction) -> Void in
                                print("CANCEL")
                            })
                            //UIAlertControllerにActionを追加
                            alert.addAction(defaultAction)
                            alert.addAction(cancelAction)
                            //Alertを表示
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .error:
                        print("error")
                    }
                }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return column2[section]

    }
    //セルのセクションを決める
    func numberOfSections(in tableView: UITableView) -> Int {
        return uniqueCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath)
        let recordList = recordLists[tbl_index[indexPath.section][indexPath.row]]
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        let label3 = cell.contentView.viewWithTag(3) as! UILabel
        let label4 = cell.contentView.viewWithTag(4) as! UILabel
        let albumImage = cell.contentView.viewWithTag(5) as! UIImageView
        let label5 = cell.contentView.viewWithTag(6) as! UILabel
        let label6 = cell.contentView.viewWithTag(7) as! UILabel

//        label1.text = tbl_artistName[indexPath.section][indexPath.row]
//        label2.text = tbl_albumTitle[indexPath.section][indexPath.row]
//        label3.text = tbl_format[indexPath.section][indexPath.row]
//        label4.text = tbl_releaseCountry[indexPath.section][indexPath.row]
//        label5.text = tbl_memo[indexPath.section][indexPath.row]
//        label6.text = tbl_releaseDate[indexPath.section][indexPath.row]
        label1.text = recordList.artistName
        label2.text = recordList.albumTitle
        label3.text = recordList.format
        label4.text = recordList.releaseCountry
        label5.text = recordList.memo
        label6.text = recordList.releaseDate
        let imageData = recordList.albumImage
        if imageData != nil {
            let img : UIImage? = UIImage(data: imageData! as Data)
            albumImage.image = img
            //albumImage.contentMode = .scaleAspectFill
        }else{
            //let img : UIImage? = UIImage(data: "".data(using: String.Encoding.utf8)! as Data)
            albumImage.image = noimage
            //albumImage.contentMode = .scaleAspectFill
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return uniqueValues2[section]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let indexPath = myTableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? DetailViewController else {
                    fatalError("Failed to prepare DetailViewController.")
                }
                destination.recordList = recordLists[tbl_index[indexPath.section][indexPath.row]]
                destination.gamenflg = "viewController"
            }
        }
    }
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:wantsFlg = "false"
        case 1:wantsFlg = "true"
        default:break
        }
        searchBar.text = nil
        getData()
        myTableView.reloadData()
    }
    // get data
    func getData(){
        let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
        let predicate = NSPredicate(format: "wantsFlg == %@", wantsFlg)
        let sortDescripter1 = NSSortDescriptor(key: "artistName", ascending: sortFlg)//ascendind:true 昇順、false 降順です
        let sortDescripter2 = NSSortDescriptor(key: "releaseDate", ascending: sortFlg)//ascendind:true 昇順、false 降順です
        // 検索条件
        request.predicate = predicate
        // ソート条件
        request.sortDescriptors = [sortDescripter1, sortDescripter2]
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            recordLists = try context.fetch(request)
            let counts = try context.fetch(request).count
            recordCount.text = "(\(counts))"
            getAfter()
        }
        catch{
            print("読み込み失敗！")
        }
    }
    // delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var albumId = ""
        if editingStyle == .delete{
            let record = recordLists[tbl_index[indexPath.section][indexPath.row]]
            albumId = record.id!
            context.delete(record)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        
        let request = NSFetchRequest<Albums>(entityName: "Albums")
        let predicate = NSPredicate(format: "idRecordList2 == %@", albumId)
        request.predicate = predicate
 //       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let results = try! context.fetch(request)
            for result in results {
                context.delete(result)
            }
            if context.hasChanges {
                try! context.save()
            }
        }

        
        getData()
        myTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        searchBar.resignFirstResponder()
        // 入力された値がnilでなければif文のブロック内の処理を実行
        if let word = searchBar.text {
            let predicate: NSPredicate
            var wantsFlgPredicate:NSPredicate =  NSPredicate(format: "1 = 1")
            var serchBarPredicate:NSPredicate =  NSPredicate(format: "1 = 1")
            if word.isEmpty {
                predicate = NSPredicate(format: "wantsFlg == %@", wantsFlg)
            }else{
                wantsFlgPredicate = NSPredicate(format: "wantsFlg == %@", wantsFlg)
                serchBarPredicate = NSPredicate(format: "artistName BEGINSWITH %@", word)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [wantsFlgPredicate, serchBarPredicate])
            }
            let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
            let sortDescripter1 = NSSortDescriptor(key: "artistName", ascending: sortFlg)//ascendind:true 昇順、false 降順です
            let sortDescripter2 = NSSortDescriptor(key: "releaseDate", ascending: sortFlg)//ascendind:true 昇順、false 降順です
            // 検索条件
            request.predicate = predicate
            // ソート条件
            request.sortDescriptors = [sortDescripter1,sortDescripter2]
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                recordLists = try context.fetch(request)
                let counts = try context.fetch(request).count
                recordCount.text = "(\(counts))"
                getAfter()
            }
            catch{
                print("読み込み失敗！")
            }
            myTableView.reloadData()
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
        for myData in recordLists {
//            var wk_tbl_format = ""
//            var wk_tbl_releaseCountry = ""
//            var wk_tbl_memo = ""
//            var wk_tbl_releaseDate = ""
//            var wk_tbl_albumImage : Data? = nil

            let wk_tbl_artistName = myData.value(forKey: "artistName") as! String
            //let wk_tbl_albumTitle = myData.value(forKey: "albumTitle") as! String
            //if myData.value(forKey: "format") != nil {
            //    wk_tbl_format = myData.value(forKey: "format") as! String
            //}
            //if myData.value(forKey: "releaseCountry") != nil {
            //    wk_tbl_releaseCountry = myData.value(forKey: "releaseCountry") as! String
            //}
            //if myData.value(forKey: "memo") != nil {
            //    wk_tbl_memo = myData.value(forKey: "memo") as! String
            //}
            //if myData.value(forKey: "releaseDate") != nil {
            //    wk_tbl_releaseDate = myData.value(forKey: "releaseDate") as! String
            //}
            //if myData.value(forKey: "albumImage") != nil {
            //    wk_tbl_albumImage = myData.value(forKey: "albumImage") as? Data
            //}else{
            //    wk_tbl_albumImage = "".data(using: String.Encoding.utf8)
            //}

            column1.append(String(wk_tbl_artistName.prefix(1)))
            if index2 == 0 {
                wk_artistName = String(wk_tbl_artistName.prefix(1))
            }
            if wk_artistName != String(wk_tbl_artistName.prefix(1)) {
                index = index + 1
                wk_artistName = String(wk_tbl_artistName.prefix(1))
                tbl_index.append([])
            }
            
//            tbl_artistName.append([])
//            tbl_artistName[index].append(wk_tbl_artistName)
//            tbl_albumTitle.append([])
//            tbl_albumTitle[index].append(wk_tbl_albumTitle)
//            tbl_format.append([])
//            tbl_format[index].append(wk_tbl_format)
//            tbl_releaseCountry.append([])
//            tbl_releaseCountry[index].append(wk_tbl_releaseCountry)
//            tbl_memo.append([])
//            tbl_memo[index].append(wk_tbl_memo)
//            tbl_releaseDate.append([])
//            tbl_releaseDate[index].append(wk_tbl_releaseDate)
//            tbl_albumImage.append([])
//            tbl_albumImage[index].append(wk_tbl_albumImage!)
            tbl_index[index].append(index2)
            index2 = index2 + 1
//            print("aaaaaaaaaa")
//            print(tbl_index)
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
        
    
    func configureRefreshControl () {
       //RefreshControlを追加する処理
        myTableView.refreshControl = UIRefreshControl()
        myTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }

    @objc func handleRefreshControl() {
          /*
           更新したい処理をここに記入（データの受け取りなど）
         */
        searchBar.text = nil
        getData()

          //上記の処理が終了したら下記が実行されます。
        DispatchQueue.main.async {
            self.myTableView.reloadData()  //TableViewの中身を更新する場合はここでリロード処理
            self.myTableView.refreshControl?.endRefreshing()  //これを必ず記載すること
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return uniqueValues2
    }
//
//    // 特殊なことをしないのであれば特に実装しなくても対象のセクションが表示される
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        //self.myTableView.scrollToRow(at: [0, index], at: .top, animated: true)
        //print(index)
      return index
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

