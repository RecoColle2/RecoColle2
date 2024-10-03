//
//  AlbumDetailAddViewController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2024/04/09.
//

import UIKit
import CoreData

class AlbumDetailAddViewController: UIViewController {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var counts = 0
    var checkArray:NSMutableArray = []
    var str : String?
    var recordLists : [RecordList2] = []
    var sortFlg = true
    var noimage = UIImage(named:"noimage")!

    @IBOutlet weak var BannerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func add(_ sender: Any) {
        if checkArray.count == 0 {
            let alert = UIAlertController(title: "alert", message: "please select", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            for check in checkArray {
                let index:IndexPath = check as! IndexPath
                let recordList = recordLists[index.row]
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let album = Albums(context: context)
                let myid: String = NSUUID().uuidString
                album.id = myid
                album.idRecordList2 = recordList.id
                album.albumName = str
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        //ボタンの角を丸くする
        addButton.layer.cornerRadius = 10
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AlbumDetailAddViewController: UICollectionViewDataSource {
    
    // 2-1. セクション数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        getData()
        return 1
    }
    
    // 2-2. セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return counts
    }
    
    // 2-3. セルに値をセット
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

//        if flg == "add" {
            // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            
            // セルのラベルに値をセット。viewWithTagにはタグの番号を指定
            //let title = cell.contentView.viewWithTag(1) as! UILabel
            //title.text = titleLabels[indexPath.row]
            
            let albumImage = cell.contentView.viewWithTag(1) as! UIImageView
            let recordList = recordLists[indexPath.row]
            //title.text = recordList.albumTitle
            let imageData = recordList.albumImage
            if imageData != nil {
                let img : UIImage? = UIImage(data: imageData! as Data)
                albumImage.image = img
                albumImage.contentMode = .scaleAspectFill
            }else{
                //let img : UIImage? = UIImage(data: "".data(using: String.Encoding.utf8)! as Data)
                albumImage.image = noimage
                //albumImage.contentMode = .scaleAspectFill
            }
            //
            // セルに枠線をセット
            cell.layer.borderColor = UIColor.lightGray.cgColor // 外枠の色
            cell.layer.borderWidth = 1.0 // 枠線の太さ
            
            return cell
//        }else{
//            if wk_counts == (indexPath.row + 1) {
//                // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
//                let albumImage = cell.contentView.viewWithTag(1) as! UIImageView
//                albumImage.image = plus
//                // セルに枠線をセット
//                cell.layer.borderColor = UIColor.lightGray.cgColor // 外枠の色
//                cell.layer.borderWidth = 1.0 // 枠線の太さ
//                
//                return cell
//
//            }else{
//                
//                
//            // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
//            let album = albums[indexPath.row]
//
//            let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
//            let predicate = NSPredicate(format: "id == %@", album.idRecordList2!)
//            request.predicate = predicate
//            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            do {
//                recordLists = try context.fetch(request)
//            }
//            catch{
//                print("読み込み失敗！")
//            }
////
//            let albumImage = cell.contentView.viewWithTag(1) as! UIImageView
//            let recordList = recordLists[0]
//            let imageData = recordList.albumImage
//            if imageData != nil {
//                let img : UIImage? = UIImage(data: imageData! as Data)
//                albumImage.image = img
//                albumImage.contentMode = .scaleAspectFill
//            }else{
//                let img : UIImage? = UIImage(data: "".data(using: String.Encoding.utf8)! as Data)
//                albumImage.image = img
//                albumImage.contentMode = .scaleAspectFill
//            }
//            //
//            // セルに枠線をセット
//            cell.layer.borderColor = UIColor.lightGray.cgColor // 外枠の色
//            cell.layer.borderWidth = 1.0 // 枠線の太さ
//            
//            return cell
//            }
//        }
    }
    
//    // ヘッダーの設定
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//      // 1. ヘッダーセクションを作成
//      guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
//        fatalError("ヘッダーがありません")
//      }
//
//     // 2. ヘッダーセクションのラベルにテキストをセット
//     if kind == UICollectionView.elementKindSectionHeader {
//         header.sectionHeader.text = str
//         return header
//     }
//
//     return UICollectionReusableView()
//    }

    func getData(){
//        if flg == "add" {
            let request = NSFetchRequest<RecordList2>(entityName: "RecordList2")
            //        let predicate = NSPredicate(format: "wantsFlg == %@", wantsFlg)
            let sortDescripter1 = NSSortDescriptor(key: "artistName", ascending: sortFlg)//ascendind:true 昇順、false 降順です
            let sortDescripter2 = NSSortDescriptor(key: "releaseDate", ascending: sortFlg)//ascendind:true 昇順、false 降順です
            // 検索条件
            //        request.predicate = predicate
            // ソート条件
            request.sortDescriptors = [sortDescripter1, sortDescripter2]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                recordLists = try context.fetch(request)
                counts = recordLists.count
            }
            catch{
                print("読み込み失敗！")
            }
//        }else{
//            let request = NSFetchRequest<Albums>(entityName: "Albums")
//            let predicate = NSPredicate(format: "albumName == %@", str!)
//            // 検索条件
//            request.predicate = predicate
//            // ソート条件
//            let sortDescripter1 = NSSortDescriptor(key: "id", ascending: sortFlg)
//            request.sortDescriptors = [sortDescripter1]
//
//            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            do {
//                albums = try context.fetch(request)
//                counts = albums.count + 1
//                wk_counts = counts
//                getAfter()
//            }
//            catch{
//                print("読み込み失敗！")
//            }
//        }
    }
    
//    func getAfter() {
//        var column1 : [String] = []
//        column2 = []
//        uniqueValues2 = []
//        var index = 0
//        var index2 = 0
//        var wk_artistName = ""
//        tbl_index = [[]]
//        for myData in albums {
//
//            let wk_tbl_artistName = myData.value(forKey: "id") as! String
//            column1.append(String(wk_tbl_artistName.prefix(1)))
//            if index2 == 0 {
//                wk_artistName = String(wk_tbl_artistName.prefix(1))
//            }
//            if wk_artistName != String(wk_tbl_artistName.prefix(1)) {
//                index = index + 1
//                wk_artistName = String(wk_tbl_artistName.prefix(1))
//                tbl_index.append([])
//            }
//            
//            tbl_index[index].append(index2)
//            index2 = index2 + 1
//        }
//        //配列の重複要素を数える
//        var wk_elt : String = ""
//        var cnt = 0
//        for elt in column1 {
//            if wk_elt == ""{
//                wk_elt = elt
//            }
//            if wk_elt == elt {
//                cnt = cnt + 1
//            }else{
//                column2.append(cnt)
//                wk_elt = elt
//                cnt = 1
//            }
//        }
//        column2.append(cnt)
//        
//        let orderedSet = NSOrderedSet(array: column1)
//        uniqueValues = orderedSet.array as! [String]
//        //uniqueCount = uniqueValues.count
//        for wk in uniqueValues{
//            let aaa = wk as String
//            let bbb = aaa.prefix(1)
//            uniqueValues2.append(String(bbb))
//        }
//        uniqueCount = uniqueValues2.count
//    }

}


// セルのサイズを調整する
extension AlbumDetailAddViewController: UICollectionViewDelegateFlowLayout {

    // セルサイズを指定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // 横方向のサイズを調整
        //let cellSizeWidth:CGFloat = self.view.frame.width/2

        // widthとheightのサイズを返す
        //return CGSize(width: cellSizeWidth, height: cellSizeWidth/2)
        //return CGSize(width: 100, height: 100)
        let cellSize: CGFloat = view.frame.size.width/4-3
        return CGSize(width: cellSize, height: cellSize)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let cellWidth = Int(flowLayout.itemSize.width)
//            let cellSpacing = Int(flowLayout.minimumInteritemSpacing)
//            let cellCount = counts
//
//            let totalCellWidth = cellWidth * cellCount
//            let totalSpacingWidth = cellSpacing * (cellCount - 1)
//
//            let inset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//
//            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
//        }
}
extension AlbumDetailAddViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            collectionView.allowsMultipleSelection = true
        }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
//            if flg == "update" {
//                wk_indexPath = indexPath
//                if wk_counts == (indexPath.row + 1) {
//                    performSegue(withIdentifier: "toAlbumDetailAddViewController",sender: nil)
//                }else{
//                    performSegue(withIdentifier: "toDetailViewController",sender: nil)
//                }
//            }else{
                //cell.backgroundColor = UIColor.lightGray // 背景色を青に変更
                //青にする(色)
                cell.layer.borderColor = UIColor.red.cgColor
                //線の太さ(太さ)
                cell.layer.borderWidth = 5
                if checkArray.contains(indexPath){    //チェックが既に入っているか
                    checkArray.remove(indexPath)
                }
                checkArray.add(indexPath)
//            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            //cell.backgroundColor = UIColor.clear // 背景色を青に変更
            //青にする(色)
            cell.layer.borderColor = UIColor.clear.cgColor
            //線の太さ(太さ)
            cell.layer.borderWidth = 0
            checkArray.remove(indexPath)
        }
    }
}
