//
//  RunRecord+CoreDataProperties.swift
//  
//
//  Created by Артем Шеруда on 18.07.26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias RunRecordCoreDataPropertiesSet = NSSet

extension RunRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunRecord> {
        return NSFetchRequest<RunRecord>(entityName: "RunRecord")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var gearsMeshed: Int16
    @NSManaged public var gearsSpare: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var levelIndex: Int16
    @NSManaged public var mode: String?
    @NSManaged public var outcome: String?
    @NSManaged public var score: Int32
    @NSManaged public var secondsPowered: Double

}

extension RunRecord : Identifiable {

}
