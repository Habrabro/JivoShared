//
//  BaseModelChange.swift
//  JivoShared
//
//  Created by macbook on 03.11.2020.
//

import Foundation
import JMCodingKit

open class BaseModelChange: NSObject {
    
    public let isOK: Bool
    
    override public init() {
        isOK = true

        super.init()
    }
    
    required public init(json: JsonElement) {
        isOK = json["ok"].boolValue
    }
    
    open var targetType: BaseModel.Type {
        abort()
    }
    
    open var isValid: Bool {
        return true
    }
    
    open var primaryValue: Int {
        abort()
    }
    
    open var integerKey: DatabaseContextMainKey<Int>? {
        return nil
    }
    
    open var stringKey: DatabaseContextMainKey<String>? {
        return nil
    }
}
