import CoreData
import SwiftUI

/// Achievement catalogue (seeded once).
struct AchievementSpec {
    let key: String
    let title: String
    let detail: String
    let target: Double
    let sort: Int16
}

enum AchievementCatalog {
    static let all: [AchievementSpec] = [
        .init(key: "first_bite",   title: "First Bite",        detail: "Mesh two gears into one train.",     target: 2,     sort: 0),
        .init(key: "clean_machine",title: "Clean Machine",     detail: "Win a bay with 3 gears to spare.",   target: 1,     sort: 1),
        .init(key: "overdrive_30k",title: "Overdrive 30k",     detail: "Score 30,000 in Overdrive.",         target: 30000, sort: 2),
        .init(key: "no_jam",       title: "No Jam",            detail: "Clear 5 bays with zero jams.",       target: 5,     sort: 3),
        .init(key: "full_train",   title: "Full Train",        detail: "Mesh 12 gears at once.",             target: 12,    sort: 4),
        .init(key: "master_wright",title: "Master Wright",     detail: "Earn 3★ on every campaign bay.",     target: 24,    sort: 5),
        .init(key: "warm_up",      title: "Warm Start",        detail: "Complete your first bay.",           target: 1,     sort: 6),
        .init(key: "conduit_5",    title: "Conduit Climber",   detail: "Complete 5 bays.",                   target: 5,     sort: 7),
        .init(key: "conduit_12",   title: "Half the Conduit",  detail: "Complete 12 bays.",                  target: 12,    sort: 8),
        .init(key: "spinner",      title: "Spun Up",           detail: "Reach a ×3 spin multiplier.",        target: 3,     sort: 9),
        .init(key: "tinkerer",     title: "Tinkerer",          detail: "Drop 200 gears.",                    target: 200,   sort: 10),
        .init(key: "marathon",     title: "Long Haul",         detail: "Power a mechanism for 60s total.",   target: 60,    sort: 11)
    ]
}

/// Owns Core Data mutations: seeding, persistence, achievement evaluation, reset, demo seeding.
final class Store: ObservableObject {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: Fetch helpers
    func preferences() -> PreferenceEntity {
        let req = NSFetchRequest<PreferenceEntity>(entityName: "PreferenceEntity")
        req.fetchLimit = 1
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        if let p = try? context.fetch(req).first { return p }
        return makePreferences()
    }

    func stats() -> PlayerStats {
        let req = NSFetchRequest<PlayerStats>(entityName: "PlayerStats")
        req.fetchLimit = 1
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        if let s = try? context.fetch(req).first { return s }
        return makeStats()
    }

    func level(_ index: Int) -> MechanismLevel? {
        let req = NSFetchRequest<MechanismLevel>(entityName: "MechanismLevel")
        req.predicate = NSPredicate(format: "levelIndex == %d", index)
        req.fetchLimit = 1
        req.sortDescriptors = [NSSortDescriptor(key: "levelIndex", ascending: true)]
        return try? context.fetch(req).first
    }

    func levels() -> [MechanismLevel] {
        let req = NSFetchRequest<MechanismLevel>(entityName: "MechanismLevel")
        req.sortDescriptors = [NSSortDescriptor(key: "levelIndex", ascending: true)]
        return (try? context.fetch(req)) ?? []
    }

    func achievements() -> [AchievementRecord] {
        let req = NSFetchRequest<AchievementRecord>(entityName: "AchievementRecord")
        req.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: true)]
        return (try? context.fetch(req)) ?? []
    }

    // MARK: Seeding
    private func stamp(_ obj: NSManagedObject) {
        obj.setValue(UUID(), forKey: "id")
        obj.setValue(Date(), forKey: "createdAt")
    }

    @discardableResult private func makePreferences() -> PreferenceEntity {
        let p = PreferenceEntity(context: context)
        stamp(p)
        p.hapticsOn = true
        p.animationsOn = true
        p.firstLaunchCompleted = false
        save()
        return p
    }

    @discardableResult private func makeStats() -> PlayerStats {
        let s = PlayerStats(context: context)
        stamp(s)
        save()
        return s
    }

    func seedIfNeeded() {
        _ = preferences()
        _ = stats()
        if levels().isEmpty {
            for def in BayLibrary.all {
                let l = MechanismLevel(context: context)
                stamp(l)
                l.levelIndex = Int16(def.index)
                l.name = def.name
                l.unlocked = def.index == 1
                l.completed = false
                l.bestStars = 0
                l.bestScore = 0
                l.fewestGearsUsed = 0
            }
        }
        if achievements().isEmpty {
            for spec in AchievementCatalog.all {
                let a = AchievementRecord(context: context)
                stamp(a)
                a.key = spec.key
                a.title = spec.title
                a.detail = spec.detail
                a.target = spec.target
                a.sortIndex = spec.sort
                a.progress = 0
                a.unlocked = false
            }
        }
        save()
    }

    // MARK: Persist a finished run
    func persist(_ r: GameResult) {
        let s = stats()
        s.totalRuns += 1
        s.totalGearsDropped += Int32(r.gearsUsed)
        s.totalGearsMeshed += Int32(r.gearsMeshed)
        s.longestPoweredStreak = max(s.longestPoweredStreak, r.secondsPowered)
        if r.solved { s.totalMechanismsBuilt += 1 }
        if r.mode == .overdrive {
            s.bestOverdriveScore = max(s.bestOverdriveScore, Int32(r.score))
        }
        if r.mode == .campaign {
            if r.solved && r.jams == 0 { s.currentNoJamStreak += 1 }
            else if !r.solved { s.currentNoJamStreak = 0 }
        }

        if r.mode == .campaign, let lvl = level(r.levelIndex) {
            lvl.lastPlayedAt = Date()
            if r.solved {
                lvl.completed = true
                lvl.bestStars = max(lvl.bestStars, Int16(r.stars))
                lvl.bestScore = max(lvl.bestScore, Int32(r.score))
                let prev = lvl.fewestGearsUsed
                lvl.fewestGearsUsed = prev == 0 ? Int16(r.gearsUsed) : min(prev, Int16(r.gearsUsed))
                if let next = level(r.levelIndex + 1) { next.unlocked = true }
            }
        }

        let rec = RunRecord(context: context)
        stamp(rec)
        rec.mode = r.mode.rawValue
        rec.levelIndex = Int16(r.levelIndex)
        rec.score = Int32(r.score)
        rec.gearsMeshed = Int16(r.gearsMeshed)
        rec.gearsSpare = Int16(r.gearsSpare)
        rec.secondsPowered = r.secondsPowered
        rec.outcome = r.solved ? "solved" : (r.mode == .overdrive ? "ended" : "jammed")

        evaluateAchievements(latestRun: r)
        save()
    }

    // MARK: Achievements
    private func evaluateAchievements(latestRun r: GameResult) {
        let s = stats()
        let all = levels()
        let completedCount = all.filter { $0.completed }.count
        let threeStarCount = all.filter { $0.bestStars >= 3 }.count

        for a in achievements() {
            var progress = a.progress
            switch a.key ?? "" {
            case "first_bite":    progress = Double(s.totalGearsMeshed)
            case "clean_machine": if r.solved && r.gearsSpare >= 3 { progress = 1 }
            case "overdrive_30k": progress = Double(s.bestOverdriveScore)
            case "no_jam":        progress = Double(s.currentNoJamStreak)
            case "full_train":    progress = max(progress, Double(r.gearsMeshed))
            case "master_wright": progress = Double(threeStarCount)
            case "warm_up":       progress = Double(s.totalMechanismsBuilt)
            case "conduit_5":     progress = Double(completedCount)
            case "conduit_12":    progress = Double(completedCount)
            case "spinner":       progress = max(progress, r.peakMultiplier)
            case "tinkerer":      progress = Double(s.totalGearsDropped)
            case "marathon":      progress = s.longestPoweredStreak
            default: break
            }
            a.progress = progress
            if !a.unlocked && progress >= a.target {
                a.unlocked = true
                a.unlockedAt = Date()
            }
        }
    }

    // MARK: Onboarding / reset
    func completeOnboarding() {
        let p = preferences()
        p.firstLaunchCompleted = true
        save()
    }

    func resetProgress() {
        deleteAll("MechanismLevel")
        deleteAll("RunRecord")
        deleteAll("AchievementRecord")
        deleteAll("PlayerStats")
        let p = preferences()
        p.firstLaunchCompleted = false
        save()
        // re-seed so the app is immediately usable (never a black screen)
        seedIfNeeded()
    }

    private func deleteAll(_ entity: String) {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let del = NSBatchDeleteRequest(fetchRequest: req)
        del.resultType = .resultTypeObjectIDs
        if let result = try? context.execute(del) as? NSBatchDeleteResult,
           let ids = result.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [context])
        }
    }

    // MARK: Demo seeding (screenshot tour only — normal launches unaffected)
    func seedDemoProgress() {
        seedIfNeeded()
        let ls = levels()
        for l in ls {
            let idx = Int(l.levelIndex)
            if idx <= 6 {
                l.completed = true
                l.unlocked = true
                l.bestStars = idx % 3 == 0 ? 2 : 3
                l.bestScore = Int32(4000 + idx * 900)
                l.fewestGearsUsed = Int16(6 + idx % 3)
            } else if idx == 7 {
                l.unlocked = true
            }
        }
        let s = stats()
        s.totalGearsDropped = 1204
        s.totalGearsMeshed = 1204
        s.totalMechanismsBuilt = 6
        s.bestOverdriveScore = 42180
        s.longestPoweredStreak = 72
        s.totalRuns = 24
        s.currentNoJamStreak = 4
        for a in achievements() {
            switch a.key ?? "" {
            case "first_bite", "clean_machine", "overdrive_30k", "warm_up", "conduit_5", "spinner":
                a.progress = a.target; a.unlocked = true; a.unlockedAt = Date()
            case "no_jam":     a.progress = 4
            case "full_train": a.progress = 9
            case "tinkerer":   a.progress = a.target; a.unlocked = true; a.unlockedAt = Date()
            default: break
            }
        }
        let p = preferences()
        p.firstLaunchCompleted = true
        save()
    }

    func save() {
        guard context.hasChanges else { return }
        do { try context.save() } catch { NSLog("CogFall Store save: \(error)") }
    }
}
