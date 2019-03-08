//
//  PairTableViewController.swift
//  PairRandomizer
//
//  Created by Dominic Lanzillotta on 3/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData

class PairTableViewController: UITableViewController {
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        PersonController.shared.fetchPeopleBySection.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "personCell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footerView")
        self.title = "Pair Randomizer"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
    }
    //MARK: - UIElements
    let randomizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Randomize Sections", for: .normal)
        button.addTarget(self, action: #selector(randomizeSections), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Actions
    @objc func addPerson() {
        addPersonAlert()
    }
    
    @objc func randomizeSections() {
        PersonController.shared.randomSection()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return PersonController.shared.fetchPeopleBySection.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersonController.shared.fetchPeopleBySection.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Group \(PersonController.shared.fetchPeopleBySection.sectionIndexTitles[section])"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath)
        
        cell.textLabel?.text = PersonController.shared.fetchPeopleBySection.object(at: indexPath).name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.addSubview(randomizeButton)
        randomizeButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        randomizeButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        randomizeButton.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        randomizeButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true

        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.numberOfSections == section + 1 {
            return 50
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let personToDelete = PersonController.shared.fetchPeopleBySection.object(at: indexPath)
            PersonController.shared.remove(person: personToDelete)
        }
    }
    
    //MARK: - Private Functions
    func addPersonAlert() {
        var nameTextField: UITextField?
        let addPersonController = UIAlertController(title: "Add new Person", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Save Name", style: .default) { [weak self] action in
            if let name = nameTextField?.text {
                let sections = self?.tableView.numberOfSections ?? 0
                if sections == 0 {
                    PersonController.shared.createNewPerson(withName: name, inSection: 0)
                } else {
                    var personIsInserted = false
                    for section in 0 ..< sections {
                        let rows = self?.tableView.numberOfRows(inSection: section) ?? 0
                        if rows <= 1 {
                            PersonController.shared.createNewPerson(withName: name, inSection: Int64(section))
                            personIsInserted = true
                            break
                        }
                    }
                    if !personIsInserted {
                        PersonController.shared.createNewPerson(withName: name, inSection: Int64(sections))
                    }
                }
            }
        }
        confirmAction.isEnabled = false
        addPersonController.addTextField { textField in
            textField.placeholder = "Add name..."
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let name = textField.text, !name.isEmpty {
                    confirmAction.isEnabled = true
                    nameTextField = textField
                } else {
                    confirmAction.isEnabled = false
                }
            }
        }
        addPersonController.addAction(confirmAction)
        addPersonController.addAction(cancelAction)
        
        self.present(addPersonController, animated: true, completion: nil)
    }
}

//MARK: - NSFetchResultsControllerDelegate
extension PairTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else {return}
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type{
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
}
