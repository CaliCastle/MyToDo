//
//  CCTagTableViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class CCTagTableViewController: UITableViewController {

    // MARK: - Properties
    
    @IBOutlet var tagTextField: UITextField!
    
    var isAdding = false
    
    var managedObjectContext: NSManagedObjectContext?
    
    var tag: Tag?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tagTextField.becomeFirstResponder()
    }

    fileprivate func setupView() {
        title = isAdding ? "Add Tag" : "Edit Tag"
        
        setupTextField()
    }
    
    fileprivate func setupTextField() {
        tagTextField.text = tag?.name ?? ""
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let tagName = tagTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if isAdding {
            addTag(name: tagName)
        } else {
            updateTag(tag: tag!, to: tagName)
        }
        
        dismiss(dismiss(animated: true, completion: nil))
    }
    
    // MARK: - Data Model
    
    fileprivate func addTag(name: String) {
        guard let managedObjectContext = managedObjectContext else { return }
        
        // Create Tag
        let tag = Tag(context: managedObjectContext)
        
        // Configure Tag
        tag.name = name
    }
    
    fileprivate func updateTag(tag: Tag, to name: String) {
        // Update Properties
        tag.name = name
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
