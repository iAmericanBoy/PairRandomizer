//
//  PersonController.swift
//  PairRandomizer
//
//  Created by Dominic Lanzillotta on 3/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

class PersonController {
    
    //MARK: - Singlton
    static let shared = PersonController()
    
    //MARK: - init
    init() {
        do{
            try fetchPeopleBySection.performFetch()
        } catch {
            print("Error loading fetchResultsController. \(String(describing: error)), \(error.localizedDescription)")
        }
    }
    
    //MARK: - CRUD
    //C
    func createNewPerson(withName name: String, inSection section: Int64) {
        Person(name: name, section: section)
        saveToPersistentStore()
    }
    
    //R
    let fetchPeopleBySection: NSFetchedResultsController<Person> = {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "section", cacheName: nil)
    }()
    
    //D
    func remove(person: Person) {
        if let moc = person.managedObjectContext {
            moc.delete(person)
            saveToPersistentStore()
        }
    }
    
    //MARK: - CoreData Save
    func saveToPersistentStore() {
        do {
            if CoreDataStack.context.hasChanges {
                try CoreDataStack.context.save()
            }
        } catch {
            print("Error saving: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
}
