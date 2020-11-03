//
//  BaseModel.swift
//  JivoShared
//
//  Created by macbook on 02.11.2020.
//

import Foundation
import RealmSwift

open class BaseModel: Object {
    
    required public override init() {
        super.init()
    }
    
    open func apply(inside context: IDatabaseContext, with change: BaseModelChange) {
    }
    
    open func simpleDelete(context: IDatabaseContext) {
        _ = context.simpleRemove(objects: [self])
    }

    open func recursiveDelete(context: IDatabaseContext) {
        simpleDelete(context: context)
    }
}
