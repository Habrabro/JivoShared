//
//  DatabaseDriver.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData
import JMTimelineKit

public protocol IDatabaseDriver: class {
    func parallel() -> IDatabaseDriver
    func refresh() -> IDatabaseDriver

    func read(_ block: (IDatabaseContext) -> Void)
    func readwrite(_ block: (IDatabaseContext) -> Void)

    func add<OT>(objects: [OT])
    
    func objects<OT>(_ type: OT.Type, options: DatabaseRequestOptions?) -> [OT]
    func object<OT, VT>(_ type: OT.Type, primaryKey: VT) -> OT?
    func object<OT, VT>(_ type: OT.Type, mainKey: DatabaseContextMainKey<VT>) -> OT?
    
    func subscribe<OT>(_ type: OT.Type, options: DatabaseRequestOptions?, callback: @escaping ([OT]) -> Void) -> DatabaseListener
    func subscribe<OT>(object: OT, callback: @escaping (OT?) -> Void) -> DatabaseListener
    func unsubscribe(_ token: DatabaseSubscriberToken)
    
    func simpleRemove<OT>(objects: [OT]) -> Bool
    func customRemove<OT>(objects: [OT], recursive: Bool)
    func removeAll()
}

fileprivate struct DatabaseToken {
    let realmToken: NotificationToken
    let notificationToken: NSObjectProtocol?
}

open class DatabaseDriver: IDatabaseDriver {
    private let fileURL: URL?
    private let memoryIdentifier: String
    private let timelineCache: JMTimelineCache

    private var context: DatabaseContext
    private var tokens = [DatabaseSubscriberToken: DatabaseToken]()
    
    public init(fileURL: URL?, memoryIdentifier: String, timelineCache: JMTimelineCache) {
        self.fileURL = fileURL
        self.memoryIdentifier = memoryIdentifier
        self.timelineCache = timelineCache
        
        let config: Realm.Configuration
        if let url = fileURL {
            config = Realm.Configuration(fileURL: url, inMemoryIdentifier: nil, deleteRealmIfMigrationNeeded: true)
        }
        else {
            config = Realm.Configuration(inMemoryIdentifier: memoryIdentifier)
        }
        
        do {
            let realm = try Realm(configuration: config)
            context = DatabaseContext(
                realm: realm,
                timelineCache: timelineCache)
        }
        catch {
            abort()
        }
    }
    
    public func parallel() -> IDatabaseDriver {
        return DatabaseDriver(
            fileURL: fileURL,
            memoryIdentifier: memoryIdentifier,
            timelineCache: timelineCache)
    }
    
    public func refresh() -> IDatabaseDriver {
        context.realm.refresh()
        return self
    }

    public func read(_ block: (IDatabaseContext) -> Void) {
        block(context)
    }
    
    public func readwrite(_ block: (IDatabaseContext) -> Void) {
        context.beginChanges()
        block(context)
        context.commitChanges()
    }
    
    public func add<OT>(objects: [OT]) {
        context.beginChanges()
        context.add(objects)
        context.commitChanges()
    }
    
    public func objects<OT>(_ type: OT.Type, options: DatabaseRequestOptions?) -> [OT] {
        return context.objects(type, options: options)
    }
    
    public func object<OT, VT>(_ type: OT.Type, primaryKey: VT) -> OT? {
        return context.object(type, primaryKey: primaryKey)
    }
    
    public func object<OT, VT>(_ type: OT.Type, mainKey: DatabaseContextMainKey<VT>) -> OT? {
        return context.object(type, mainKey: mainKey)
    }
    
    public func subscribe<OT>(_ type: OT.Type, options: DatabaseRequestOptions?, callback: @escaping ([OT]) -> Void) -> DatabaseListener {
        let objects = context.getObjects(type as! Object.Type, options: options)
        let token = objects.observe { change in
            switch change {
            case .initial(let results): callback(Array(results) as! [OT])
            case .update(let results, _, _, _): callback(Array(results) as! [OT])
            case .error: break
            }
        }
        
        let internalToken = UUID()
        
        tokens[internalToken] = DatabaseToken(
            realmToken: token,
            notificationToken: options?.notificationName.map { name in
                NotificationCenter.default.addObserver(
                    forName: name,
                    object: nil,
                    queue: nil,
                    using: { _ in callback(Array(objects) as! [OT]) }
                )
            }
        )
        
        return DatabaseListener(token: internalToken, databaseDriver: self)
    }
    
    public func subscribe<OT>(object: OT, callback: @escaping (OT?) -> Void) -> DatabaseListener {
        let token = (object as! Object).observe { change in
            switch change {
            case .change: callback(object)
            case .deleted: callback(nil)
            case .error: break
            }
        }
        
        let internalToken = UUID()
        
        tokens[internalToken] = DatabaseToken(
            realmToken: token,
            notificationToken: nil
        )
        
        return DatabaseListener(token: internalToken, databaseDriver: self)
    }
    
    public func unsubscribe(_ token: DatabaseSubscriberToken) {
        if let item = tokens[token] {
            if let observer = item.notificationToken {
                NotificationCenter.default.removeObserver(observer)
            }
            
            item.realmToken.invalidate()
            tokens.removeValue(forKey: token)
        }
    }
    
    public func simpleRemove<OT>(objects: [OT]) -> Bool {
        context.beginChanges()
        defer { context.commitChanges() }
        
        return context.simpleRemove(objects: objects)
    }
    
    public func customRemove<OT>(objects: [OT], recursive: Bool) {
        context.beginChanges()
        defer { context.commitChanges() }
        
        context.customRemove(objects: objects, recursive: recursive)
    }
    
    public func removeAll() {
        context.beginChanges()
        _ = context.removeAll()
        context.commitChanges()
    }
}
