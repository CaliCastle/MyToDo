//
//  NotesViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/3/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController {
    
    // MARK: - Segues
    
    private enum Segue {
    
        static let Note = "Note"
        static let AddNote = "AddNote"
        
    }
    
    // MARK: - Properties
    
    fileprivate var coreDataManager = CoreDataManager(modelName: "Notes")
    
    fileprivate let estimatedRowHeight = CGFloat(80)
    
    fileprivate lazy var messageLabel: UILabel = {
        return createEmptyMessageLabel(message: "You don't have any notes yet.")
    }()
    
    // MARK: - Date Formatter
    fileprivate lazy var updatedAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        
        return dateFormatter
    }()
    
    // MARK: - Fetched Results Controller
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataManager.mainManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    /// Has Notes or Not
    fileprivate var hasNotes: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        
        return fetchedObjects.count > 0
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchNotes()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.AddNote:
            guard let destination = segue.destination as? AddNoteViewController else { return }
            destination.managedObjectContext = coreDataManager.mainManagedObjectContext
            break
        case Segue.Note:
            guard let destination = segue.destination as? CCNoteViewController else { return }
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            // Fetch Note
            let note = fetchedResultsController.object(at: indexPath)
            
            // Configure Destination
            destination.delegate = self
            destination.note = note
            
            // Deselects Row
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    fileprivate func setupView() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        activityIndicator.stopAnimating()
        tableView.isHidden = false
        
        setupTableView()
    }
    
    fileprivate func updateView() {
        messageLabel.isHidden = hasNotes
    }

    fileprivate func setupTableView() {
        tableView.rowHeight = estimatedRowHeight
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func fetchNotes() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to Execute Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
}

// MARK: - Table View Data Source
extension NotesViewController {
    
    /// How Many Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections.count
    }
    
    /// How Many Rows Per Section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects
    }

    /// Configure Each Table View Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CCNoteTableViewCell.reuseIdentifier, for: indexPath) as? CCNoteTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: CCNoteTableViewCell, at indexPath: IndexPath) {
        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.titleLabel.text = note.title
        cell.contentsLabel.text = note.contents
        cell.tagsLabel.text = note.alphabetizedTagsAsString ?? "No Tags"
        cell.updatedAtLabel.text = updatedAtDateFormatter.string(from: note.updatedAtAsDate)
        cell.colorView.backgroundColor = note.category?.color
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)
        
        // Delete Note
        coreDataManager.mainManagedObjectContext.delete(note)
    }
}

// MARK: - FetchedResultsController Delegate
extension NotesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .left)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .middle)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CCNoteTableViewCell {
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
}

extension NotesViewController: CCNoteViewControllerDelegate {
    
    func deleteNote(note: Note) {
        coreDataManager.mainManagedObjectContext.delete(note)
    }
    
    func addNewNote() {
        performSegue(withIdentifier: Segue.AddNote, sender: nil)
    }
}
