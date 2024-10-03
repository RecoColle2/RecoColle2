//
//  RecordList+CoreDataProperties.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2023/01/29.
//
//

import Foundation
import CoreData


extension RecordList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordList> {
        return NSFetchRequest<RecordList>(entityName: "RecordList")
    }

    @NSManaged public var albumImage: Data?
    @NSManaged public var albumTitle: String?
    @NSManaged public var artistName: String?
    @NSManaged public var format: String?

}

extension RecordList : Identifiable {

}
