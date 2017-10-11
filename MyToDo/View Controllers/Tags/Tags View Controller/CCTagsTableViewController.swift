//
//  CCTagsTableViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class CCTagsTableViewController: UITableViewController {

    private enum Segue {
        
        static let Tag = "Tag"
        static let AddTag = "AddTag"
        
    }
    
    // MARK: -
    
    var note: Note?
    
    // MARK: -
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        guard let managedObjectContext = note?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        return createEmptyMessageLabel(message: "No tags yet.")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        updateView()
    }
    
    // MARK: - View Methods
    
    fileprivate func setupView() {
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func updateView() {
        var hasTags = false
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            hasTags = fetchedObjects.count > 0
        }
        
        messageLabel.isHidden = hasTags
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        let destination = (segue.destination as! UINavigationController).topViewController as! CCTagTableViewController
        
        destination.managedObjectContext = note?.managedObjectContext
        
        if identifier == Segue.Tag {
            destination.isAdding = false
            destination.tag = fetchedResultsController.object(at: sender as! IndexPath)
        } else {
            destination.isAdding = true
        }
    }
}

// MARK: - Table view data source

extension CCTagsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects
    }
    
    func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = tag.name
        
        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            cell.textLabel?.textColor = .bitterSweet
            cell.accessoryType = .checkmark
        } else {
            cell.textLabel?.textColor = .black
            cell.accessoryType = .detailButton
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell", for: indexPath)
        
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)
        
        // Delete Tag
        note?.managedObjectContext?.delete(tag)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)
        
        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            note?.removeFromTags(tag)
        } else {
            note?.addToTags(tag)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: Segue.Tag, sender: indexPath)
    }
}

extension CCTagsTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .middle)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .middle)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
}
