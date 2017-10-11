//
//  CCCategoriesTableViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/7/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class CCCategoriesTableViewController: UITableViewController {
    
    private enum Segue {
    
        static let Category = "Category"
        static let AddCategory = "AddCategory"
    }
    
    // MARK: -
    
    var note: Note?
    
    // MARK: -
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        guard let managedObjectContext = self.note?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        return createEmptyMessageLabel(message: "No categories yet.")
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
    
    private func setupView() {
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func updateView() {
        var hasCategories = false
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            hasCategories = fetchedObjects.count > 0
        }
        
        messageLabel.isHidden = hasCategories
    }

    // MARK: - Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        let destination = (segue.destination as! UINavigationController).topViewController as! CCCategoryTableViewController
        
        if identifier == Segue.AddCategory {
            destination.isAdding = true
        } else {
            destination.category = sender as? Category
        }
        
        destination.managedObjectContext = note?.managedObjectContext
    }
}

// MARK: - Table View Data Source
extension CCCategoriesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects
    }
    
    func configure(_ cell: CCCategoryTableViewCell, at indexPath: IndexPath) {
        // Fetch Note
        let category = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        if cell.delegate == nil {
            cell.delegate = self
        }
        
        cell.indexPath = indexPath
        cell.categoryLabel?.text = category.name
        cell.colorView.backgroundColor = category.color
        
        if note?.category == category {
            cell.categoryLabel?.textColor = .bitterSweet
            cell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CCCategoryTableViewCell.reuseIdentifier, for: indexPath) as! CCCategoryTableViewCell
        
        // Configure the cell...
        configure(cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Fetch Category
        let category = fetchedResultsController.object(at: indexPath)
        
        // Update Note
        note?.category = category
        
        // Pop View Controller From Navigation Stack
        let _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Category
        let category = fetchedResultsController.object(at: indexPath)
        
        // Delete Category
        note?.managedObjectContext?.delete(category)
    }
}

// MARK: - Category Table View Cell Delegate
extension CCCategoriesTableViewController: CCCategoryTableViewCellDelegate {
    
    func iconButtonTapped(at indexPath: IndexPath) {        
        let category = fetchedResultsController.object(at: indexPath)
        
        performSegue(withIdentifier: Segue.Category, sender: category)
    }
    
}

extension CCCategoriesTableViewController: NSFetchedResultsControllerDelegate {
    
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CCCategoryTableViewCell {
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
