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
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let sectionSort = NSSortDescriptor(key: "section", ascending: true)
        fetchRequest.sortDescriptors = [nameSort,sectionSort]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "section", cacheName: nil)
    }()
    
    //U
    func updateSection(forPerson person: Person, withNewSection section: Int64) {
        person.section = section
    }
    
    func randomSection(maxSection: Int) {
        var sectionsAvailabe: [Int] = []
        
        let setOfPerson: Set<Person> = CoreDataStack.context.registeredObjects as! Set<Person>
        
        var arrayOfPerson: [Person] = Array(setOfPerson)
        print(arrayOfPerson)
        
        for number in (0 ..< arrayOfPerson.count).reversed() {
            sectionsAvailabe.append(maxSection - number / 2)
        }
        while sectionsAvailabe.count != 0 {
            let milliSeconds = Calendar.current.component(.nanosecond, from: Date())
            let index = min((milliSeconds % 10), (arrayOfPerson.count - 1))
            let personToUpdate = arrayOfPerson.remove(at: index)
            updateSection(forPerson: personToUpdate, withNewSection: Int64(sectionsAvailabe.remove(at: index)))
        }
        saveToPersistentStore()
        CoreDataStack.context.reset()
    }
    
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
                print(CoreDataStack.context.registeredObjects)

            }
        } catch {
            print("Error saving: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
}
