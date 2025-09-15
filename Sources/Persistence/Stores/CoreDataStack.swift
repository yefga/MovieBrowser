//
//  CoreDataStack.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import CoreData

public final class CoreDataStack {
    public static let shared = CoreDataStack()

    // MARK: - Core Data stack

    public let persistentContainer: NSPersistentContainer

    private init() {
        // Locate the compiled model inside the MoviePersistence bundle
        let bundle = Bundle(for: CoreDataStack.self)
        guard
            let modelURL =
                bundle.url(forResource: "Model", withExtension: "momd")
                ?? bundle.url(forResource: "Model", withExtension: "mom"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("❌ Core Data model 'Model' not found in MoviePersistence bundle.")
        }

        let container = NSPersistentContainer(name: "Model", managedObjectModel: model)

        // ✅ Lightweight migration (adds new optional attrs, renamed/removed with mapping inference)
        if let desc = container.persistentStoreDescriptions.first {
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Failed to load persistent store: \(error)")
            }
        }

        // Merge policy: our in-memory changes win on conflict
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        self.persistentContainer = container
    }

    // MARK: - Contexts

    /// Main-thread context for reads / simple writes.
    public var context: NSManagedObjectContext { persistentContainer.viewContext }

    /// Create a background context configured like the main context.
    public func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        ctx.automaticallyMergesChangesFromParent = true
        return ctx
    }

    // MARK: - Convenience

    /// Save the main context if it has changes.
    public func saveIfNeeded() {
        let ctx = persistentContainer.viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() } catch {
            #if DEBUG
            print("⚠️ CoreData saveIfNeeded error:", error)
            #endif
        }
    }

    /// Perform work on a temporary background context and save it.
    public func performBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { ctx in
            ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            ctx.automaticallyMergesChangesFromParent = true
            block(ctx)
            if ctx.hasChanges {
                do { try ctx.save() } catch {
                    #if DEBUG
                    print("⚠️ CoreData background save error:", error)
                    #endif
                }
            }
        }
    }

    // MARK: - Debug helpers

    /// Location of the first persistent store on disk (useful for debugging).
    public var storeURL: URL? {
        persistentContainer.persistentStoreCoordinator.persistentStores.first?.url
    }

    #if DEBUG
    /// Nukes the store file for clean-room debugging. Call only in debug builds.
    public func resetStore() {
        guard let store = persistentContainer.persistentStoreCoordinator.persistentStores.first,
              let url = store.url
        else { return }

        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(
                at: url, ofType: NSSQLiteStoreType, options: nil
            )
            try persistentContainer.persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ]
            )
        } catch {
            print("⚠️ Failed to reset store:", error)
        }
    }
    #endif
}
