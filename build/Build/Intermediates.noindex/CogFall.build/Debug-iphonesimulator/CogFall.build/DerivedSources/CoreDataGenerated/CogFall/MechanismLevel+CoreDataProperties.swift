//
//  MechanismLevel+CoreDataProperties.swift
//  
//
//  Created by Артем Шеруда on 18.07.26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias MechanismLevelCoreDataPropertiesSet = NSSet

extension MechanismLevel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MechanismLevel> {
        return NSFetchRequest<MechanismLevel>(entityName: "MechanismLevel")
    }

    @NSManaged public var bestScore: Int32
    @NSManaged public var bestStars: Int16
    @NSManaged public var completed: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var fewestGearsUsed: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var lastPlayedAt: Date?
    @NSManaged public var levelIndex: Int16
    @NSManaged public var name: String?
    @NSManaged public var unlocked: Bool

}

extension MechanismLevel : Identifiable {

}
