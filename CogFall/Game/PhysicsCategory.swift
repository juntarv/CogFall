import Foundation

/// Single source of truth for physics collision bitmasks. Never define these elsewhere.
enum PhysicsCategory {
    static let none: UInt32    = 0
    static let gear: UInt32    = 1 << 0
    static let wall: UInt32    = 1 << 1
    static let spindle: UInt32 = 1 << 2
    static let target: UInt32  = 1 << 3
}
