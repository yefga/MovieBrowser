//
//  CoreDataMovieCache.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import CoreData

public struct CachedMovieDTO {
    public var id: Int
    public var title: String?
    public var posterPath: String?
    public var releaseDateText: String?
    public var overview: String?
    public var voteAverage: Double?
    public var originalLanguage: String?
    public var isFavorite: Bool
    public init(
        id: Int,
        title: String? = nil,
        posterPath: String? = nil,
        releaseDateText: String? = nil,
        overview: String? = nil,
        voteAverage: Double? = nil,
        originalLanguage: String? = nil,
        isFavorite: Bool
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDateText = releaseDateText
        self.overview = overview
        self.voteAverage = voteAverage
        self.originalLanguage = originalLanguage
        self.isFavorite = isFavorite
    }
}


public enum Keys {
    static let entity = "CachedMovie"
    static let id = "id"
    static let title = "title"
    static let posterPath = "posterPath"
    static let releaseDateText = "releaseDateText"
    static let overview = "overview"
    static let voteAverage = "voteAverage"
    static let originalLanguage = "originalLanguage"
    static let isFavorite = "isFavorite"
    static let query = "query"
    static let page = "page"
}


public final class CoreDataMovieCache: MovieCacheStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(container: NSPersistentContainer = CoreDataStack.shared.persistentContainer) {
        self.container = container
        self.context = container.newBackgroundContext()
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.context.automaticallyMergesChangesFromParent = true
    }

    public func save(movies: [[String: Any]], for query: String, page: Int) throws {
        try context.performAndWait {
            // 0) Which ids are coming in?
            let incomingIDs = movies.compactMap { ($0[Keys.id] as? NSNumber)?.int64Value }
            let idPredicate = NSPredicate(format: "%K IN %@", Keys.id, incomingIDs)

            // 1) Among incoming IDs, which are already favorite?
            let favReq = NSFetchRequest<NSDictionary>(entityName: Keys.entity)
            favReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                idPredicate, NSPredicate(format: "%K == YES", Keys.isFavorite)
            ])
            favReq.resultType = .dictionaryResultType
            favReq.propertiesToFetch = [Keys.id]
            let favRows = (try? context.fetch(favReq)) ?? []
            let favoriteIDs = Set(favRows.compactMap { ($0[Keys.id] as? NSNumber)?.int64Value })

            // 2) Replace the page for (query, page)
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.entity)
            deleteFetch.predicate = NSPredicate(format: "%K == %@ AND %K == %d", Keys.query, query, Keys.page, page)
            let delete = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            _ = try? context.execute(delete)

            // 3) Insert while PRESERVING favorite flags
            let objects: [[String: Any]] = movies.map { dict in
                let id64 = (dict[Keys.id] as? NSNumber)?.int64Value
                let wasFavorite = id64.map { favoriteIDs.contains($0) } ?? false
                return [
                    Keys.id: dict[Keys.id] ?? NSNull(),
                    Keys.title: dict[Keys.title] ?? NSNull(),
                    Keys.releaseDateText: dict[Keys.releaseDateText] ?? NSNull(),
                    Keys.posterPath: dict[Keys.posterPath] ?? NSNull(),
                    Keys.overview: dict[Keys.overview] ?? NSNull(),
                    Keys.voteAverage: dict[Keys.voteAverage] ?? NSNull(),
                    Keys.originalLanguage: dict[Keys.originalLanguage] ?? NSNull(),
                    Keys.page: Int64(page),
                    Keys.query: query,
                    Keys.isFavorite: wasFavorite
                ]
            }

            let insert = NSBatchInsertRequest(entityName: Keys.entity, objects: objects)
            _ = try context.execute(insert)
            try context.save()
        }
    }

    public func fetch(for query: String, page: Int) throws -> [CachedMovieDTO] {
        try context.performAndWait {
            let req = NSFetchRequest<NSManagedObject>(entityName: Keys.entity)
            req.predicate = NSPredicate(format: "%K == %@ AND %K == %d", Keys.query, query, Keys.page, page)
            req.sortDescriptors = [NSSortDescriptor(key: Keys.title, ascending: true)]

            let rows = try context.fetch(req)
            return rows.map {
                CachedMovieDTO(
                    id: Int(($0.value(forKey: Keys.id) as? Int64) ?? 0),
                    title: $0.value(forKey: Keys.title) as? String,
                    posterPath: $0.value(forKey: Keys.posterPath) as? String,
                    releaseDateText: $0.value(forKey: Keys.releaseDateText) as? String,
                    overview: $0.value(forKey: Keys.overview) as? String,
                    voteAverage: $0.value(forKey: Keys.voteAverage) as? Double,
                    originalLanguage: $0.value(forKey: Keys.originalLanguage) as? String,
                    isFavorite: ($0.value(forKey: Keys.isFavorite) as? Bool) ?? false
                )
            }
        }
    }

    public func clear(for query: String) throws {
        try context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.entity)
            fetch.predicate = NSPredicate(format: "%K == %@", Keys.query, query)
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            _ = try context.execute(delete)
            try context.save()
        }
    }
    
    public func fetchFavorites() -> [CachedMovieDTO] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: Keys.entity)
        let rows = (try? context.fetch(request)) ?? []
        
        return rows.filter {
            ($0.value(forKey: Keys.isFavorite) as? Bool) == true
        }.compactMap {
            CachedMovieDTO(
                id: Int(($0.value(forKey: Keys.id) as? Int64) ?? 0),
                title: $0.value(forKey: Keys.title) as? String,
                posterPath: $0.value(forKey: Keys.posterPath) as? String,
                releaseDateText: $0.value(forKey: Keys.releaseDateText) as? String,
                overview: $0.value(forKey: Keys.overview) as? String,
                voteAverage: $0.value(forKey: Keys.voteAverage) as? Double,
                originalLanguage: $0.value(forKey: Keys.originalLanguage) as? String,
                isFavorite: ($0.value(forKey: Keys.isFavorite) as? Bool) ?? false
            )
        }
    }
    
    public func setFavorite(item: CachedMovieDTO) throws {
        try context.performAndWait {
            // Update isFavorite for all rows with this id
            let byId: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: Keys.entity)
            byId.predicate = NSPredicate(format: "%K == %d", Keys.id, item.id)
            let rows = (try? context.fetch(byId)) ?? []
            rows.forEach { $0.setValue(item.isFavorite, forKey: Keys.isFavorite) }

            // Anchor row to ensure Favorites are available offline
            let anchorReq: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: Keys.entity)
            anchorReq.predicate = NSPredicate(format: "%K == %d AND %K == %@", Keys.id, item.id, Keys.query, "__favorite__")
            let anchor = (try? context.fetch(anchorReq))?.first
            ?? (item.isFavorite ? NSEntityDescription.insertNewObject(forEntityName: Keys.entity, into: context) : nil)

            if let anchor {
                // If newly inserted, set identity fields
                if anchor.value(forKey: Keys.id) == nil {
                    anchor.setValue(Int64(item.id), forKey: Keys.id)
                    anchor.setValue(Int64(0), forKey: Keys.page)
                    anchor.setValue("__favorite__", forKey: Keys.query)
                }
                anchor.setValue(item.isFavorite, forKey: Keys.isFavorite)

                // Upsert minimal metadata so Favorites can render offline
                func setIfEmpty(_ key: String, _ value: Any?) {
                    if (anchor.value(forKey: key) as? String)?.isEmpty ?? (anchor.value(forKey: key) == nil) {
                        anchor.setValue(value, forKey: key)
                    }
                }
                setIfEmpty(Keys.title, item.title)
                setIfEmpty(Keys.posterPath, item.posterPath)
                setIfEmpty(Keys.releaseDateText, item.releaseDateText)
                setIfEmpty(Keys.overview, item.overview)
                setIfEmpty(Keys.voteAverage, item.voteAverage)
                setIfEmpty(Keys.originalLanguage, item.originalLanguage)
            }

            try context.save()
        }
    }
    
    public func isFavorite(id: Int) -> Bool {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: Keys.entity)
        request.predicate = NSPredicate(format: "%K == %d AND %K == YES", Keys.id, id, Keys.isFavorite)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }
}

