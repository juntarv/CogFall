//
//  PreferenceEntity+CoreDataProperties.swift
//  
//
//  Created by Артем Шеруда on 18.07.26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PreferenceEntityCoreDataPropertiesSet = NSSet

extension PreferenceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreferenceEntity> {
        return NSFetchRequest<PreferenceEntity>(entityName: "PreferenceEntity")
    }

    @NSManaged public var animationsOn: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var firstLaunchCompleted: Bool
    @NSManaged public var hapticsOn: Bool
    @NSManaged public var id: UUID?

}

extension PreferenceEntity : Identifiable {

}
