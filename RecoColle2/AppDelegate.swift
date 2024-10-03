//
//  AppDelegate.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2022/11/23.
//

import UIKit
import CoreData //追加


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var globalTestMode = true
    
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

//    lazy var persistentContainer: NSPersistentContainer = {
//        let storeURL = URL.storeURL(for: "group.com.marume3591.RecoColle2", databaseName: "DataModel")
//        let storeDescription = NSPersistentStoreDescription(url: storeURL)
//
//        let container = NSPersistentContainer(name: "DataModel")
//
//        container.persistentStoreDescriptions = [storeDescription]
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSCustomPersistentContainer(name: "DataModel")

            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    print(error.localizedDescription)
                }
            })
            return container
        }()

    // MARK: - Core Data Saving support

    func saveContext () {
        //NSPersistentContainer内のNSManagedObjectContextを定数contextに代入
        let context = persistentContainer.viewContext

        //NSManagedObjectContextに変更があったら、保存しますよ
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
      self.saveContext() //追加
    }

}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}


