import UIKit
import CoreData

class CoreDataModel {
    static func loadCSV() {
        loadAlbumsCSV()
    }

    static func loadAlbumsCSV() {
        guard let path = Bundle.main.path(forResource:"Albums", ofType:"csv") else {
            print("Failed to find Albums.csv.")
            return
        }

        do {
            let csv = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            var groupedAttributesOfAlbums = csv.components(separatedBy: .newlines)

            // 余計なデータを削除
            groupedAttributesOfAlbums.removeFirst() // 先頭行のラベル
            if groupedAttributesOfAlbums.last == "" { // 末尾の空要素（csv末尾に改行のみあれば）
                groupedAttributesOfAlbums.removeLast()
            }

            // 旧データを削除
            let oldAlbums = fetchAlbums(with: nil)
            oldAlbums.forEach {delete(album: $0)}

            for groupedAttributesOfAlbum in groupedAttributesOfAlbums {
                let attributesOfAlbum = groupedAttributesOfAlbum.components(separatedBy: ",")
                let album = newAlbum()

                album.index = Int16(attributesOfAlbum[0])!
                album.title = attributesOfAlbum[1]
            }

            save()
        } catch let error as NSError {
            print("Failed to load csv: \(error).")
            return
        }
    }

    static func newAlbum() -> Album {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedContext)!
        let album = Album(entity: entity, insertInto: managedContext)

        return album
    }

    static func fetchAlbums(with predicate: NSPredicate?) -> [Album] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Album")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        fetchRequest.includesSubentities = false

        do {
            let albums = try managedContext.fetch(fetchRequest) as! [Album]
            return albums
        } catch let error as NSError {
            fatalError("Could not fetch albums. \(error), \(error.userInfo)")
        }
    }

    static func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        appDelegate.saveContext()
    }

    static func delete(album: Album) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(album)
    }
}
