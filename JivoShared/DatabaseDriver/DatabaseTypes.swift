//
//  DatabaseOptions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

public typealias DatabaseSubscriberToken = UUID

public struct DatabaseResponseSort {
    let keyPath: String
    let ascending: Bool
    
    public init(keyPath: String, ascending: Bool) {
        self.keyPath = keyPath
        self.ascending = ascending
    }
}

public struct DatabaseRequestOptions {
    let filter: NSPredicate?
    let sortBy: [DatabaseResponseSort]
    let notificationName: Notification.Name?
    
    public init(filter: NSPredicate? = nil, sortBy: [DatabaseResponseSort] = [], notificationName: Notification.Name? = nil) {
        self.filter = filter
        self.sortBy = sortBy
        self.notificationName = notificationName
    }
}
