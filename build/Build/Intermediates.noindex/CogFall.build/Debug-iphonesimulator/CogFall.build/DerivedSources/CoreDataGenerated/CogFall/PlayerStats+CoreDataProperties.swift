//
//  PlayerStats+CoreDataProperties.swift
//  
//
//  Created by Артем Шеруда on 18.07.26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PlayerStatsCoreDataPropertiesSet = NSSet

extension PlayerStats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerStats> {
        return NSFetchRequest<PlayerStats>(entityName: "PlayerStats")
    }

    @NSManaged public var bestOverdriveScore: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var currentNoJamStreak: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var longestPoweredStreak: Double
    @NSManaged public var totalGearsDropped: Int32
    @NSManaged public var totalGearsMeshed: Int32
    @NSManaged public var totalMechanismsBuilt: Int32
    @NSManaged public var totalRuns: Int32

}

extension PlayerStats : Identifiable {

}
