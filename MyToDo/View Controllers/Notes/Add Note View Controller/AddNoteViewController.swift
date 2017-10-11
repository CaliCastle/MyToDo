//
//  AddNoteViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/6/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable Done Bar Button
        doneBarButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // SHow Keyboard
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func nextOnTitleField(_ sender: Any) {
        contentsTextView.becomeFirstResponder()
    }
    
    @IBAction func editingTitle(_ sender: UITextField) {
        if let title = sender.text?.trimmingCharacters(in: .whitespaces) {
            doneBarButton.isEnabled = !title.isEmpty
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        saveNote(sender: sender)
    }
    
    // Save the Note into Core Data
    private func saveNote(sender: UIBarButtonItem) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            showAlert(with: "Type In a Title", and: "Your note doesn't have a title.")
            
            return
        }
        
        // Create Note
        let note = Note(context: managedObjectContext)
        
        // Configure Note
        note.title = titleTextField.text?.trimmingCharacters(in: .whitespaces)
        note.contents = contentsTextView.text
        note.createdAt = Date()
        note.updatedAt = Date()
        
        // Pop Back View Controller
        _ = navigationController?.popViewController(animated: true)
    }

}
