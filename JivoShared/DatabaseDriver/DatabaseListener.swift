//
//  DatabaseListener.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public final class DatabaseListener {
    private let token: DatabaseSubscriberToken
    private weak var databaseDriver: IDatabaseDriver!
    
    init(token: DatabaseSubscriberToken, databaseDriver: IDatabaseDriver) {
        self.token = token
        self.databaseDriver = databaseDriver
    }
    
    deinit {
        databaseDriver?.unsubscribe(token)
    }
}
