//
//  DatabaseContext.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import RealmSwift
import JMTimelineKit
import JivoShared

public struct DatabaseContextMainKey<VT> {
    let key: String
    let value: VT
    
    public init(key: String, value: VT) {
        self.key = key
        self.value = value
    }
}

public protocol IDatabaseContext {
    var timelineCache: JMTimelineCache { get }

    var hasChanges: Bool { get }
    func createObject<OT>(_ type: OT.Type) -> OT
    func add<OT>(_ objects: [OT])
    
    func objects<OT>(_ type: OT.Type, options: DatabaseRequestOptions?) -> [OT]
    func object<OT, VT>(_ type: OT.Type, primaryKey: VT) -> OT?
    func object<OT, VT>(_ type: OT.Type, mainKey: DatabaseContextMainKey<VT>) -> OT?
    
    func simpleRemove<OT>(objects: [OT]) -> Bool
    func customRemove<OT>(objects: [OT], recursive: Bool)
    func removeAll() -> Bool
    
    func setValue(_ value: Int, for key: Int)
    func valueForKey(_ key: Int) -> Int?
}

open class DatabaseContext: IDatabaseContext {
    let realm: Realm
    public let timelineCache: JMTimelineCache
    
    private var hasAddedObjects = false
    private var values = [Int: Int]()
    
    init(realm: Realm, timelineCache: JMTimelineCache) {
        self.realm = realm
        self.timelineCache = timelineCache
    }
    
    public var hasChanges: Bool {
        return hasAddedObjects
    }
    
    public func createObject<OT>(_ type: OT.Type) -> OT {
        hasAddedObjects = true
        return realm.create(type as! Object.Type) as! OT
    }
    
    public func add<OT>(_ objects: [OT]) {
        hasAddedObjects = true
        realm.add(objects as! [Object])
    }
    
    public func objects<OT>(_ type: OT.Type, options: DatabaseRequestOptions?) -> [OT] {
        let objects = getObjects(type as! Object.Type, options: options)
        return Array(objects) as! [OT]
    }
    
    public func object<OT, KT>(_ type: OT.Type, primaryKey: KT) -> OT? {
        return realm.object(ofType: type as! Object.Type, forPrimaryKey: primaryKey) as? OT
    }
    
    public func object<OT, VT>(_ type: OT.Type, mainKey: DatabaseContextMainKey<VT>) -> OT? {
        let key = mainKey.key
        let value = mainKey.value
        return realm.objects(type as! Object.Type).filter("\(key) == %@", value).first as? OT
    }
    
    public func simpleRemove<OT>(objects: [OT]) -> Bool {
        realm.delete(objects as! [Object])
        return true
    }
    
    public func customRemove<OT>(objects: [OT], recursive: Bool) {
        if recursive {
            (objects as! [BaseModel]).forEach { $0.recursiveDelete(context: self) }
        }
        else {
            (objects as! [BaseModel]).forEach { $0.simpleDelete(context: self) }
        }
    }
    
    public func removeAll() -> Bool {
        realm.deleteAll()
        return true
    }
    
    public func setValue(_ value: Int, for key: Int) {
        values[key] = value
    }
    
    public func valueForKey(_ key: Int) -> Int? {
        return values[key]
    }
    
    internal func beginChanges() {
        hasAddedObjects = false
        realm.beginWrite()
    }
    
    internal func commitChanges() {
        try! realm.commitWrite()
        realm.refresh()
        hasAddedObjects = false
    }
    
    internal func getObjects<OT: Object>(_ type: OT.Type, options: DatabaseRequestOptions?) -> Results<OT> {
        var objects = realm.objects(type)
        
        if let filter = options?.filter {
            objects = objects.filter(filter)
        }
        
        if let sort = options?.sortBy {
            objects = objects.sorted(
                by: sort.map {
                    SortDescriptor(keyPath: $0.keyPath, ascending: $0.ascending)
                }
            )
        }
        
        return objects
    }
}
