//
//  AchievementRecord+CoreDataProperties.swift
//  
//
//  Created by Артем Шеруда on 18.07.26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias AchievementRecordCoreDataPropertiesSet = NSSet

extension AchievementRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AchievementRecord> {
        return NSFetchRequest<AchievementRecord>(entityName: "AchievementRecord")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var detail: String?
    @NSManaged public var id: UUID?
    @NSManaged public var key: String?
    @NSManaged public var progress: Double
    @NSManaged public var sortIndex: Int16
    @NSManaged public var target: Double
    @NSManaged public var title: String?
    @NSManaged public var unlocked: Bool
    @NSManaged public var unlockedAt: Date?

}

extension AchievementRecord : Identifiable {

}
