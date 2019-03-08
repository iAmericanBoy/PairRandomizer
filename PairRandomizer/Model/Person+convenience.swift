//
//  Person.swift
//  PairRandomizer
//
//  Created by Dominic Lanzillotta on 3/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

extension Person {
@discardableResult
    convenience init(name: String, section: Int64, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        self.section = section
    }
}
