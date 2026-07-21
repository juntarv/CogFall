import CoreData

/// Loads the CogFall Core Data stack. Initialised inside HomeView, never at App level.
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CogFall")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        let store = container
        store.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Recover from an incompatible store rather than crashing the app.
                if let url = store.persistentStoreDescriptions.first?.url {
                    try? FileManager.default.removeItem(at: url)
                    store.loadPersistentStores { _, _ in }
                }
                NSLog("CogFall store load error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            NSLog("CogFall save error: \(error)")
        }
    }
}
