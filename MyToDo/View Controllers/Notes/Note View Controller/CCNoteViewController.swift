//
//  CCNoteViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/7/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class CCNoteViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    
    @IBOutlet var doneBarButton: UIBarButtonItem!
    
    fileprivate enum Segue {
        
        static let Categories = "Categories"
        static let Tags = "Tags"
        
    }
    
    // MARK: -
    
    var note: Note?
    
    var activeField: UIView? {
        willSet {
            if activeField != nil && newValue == nil {
                // Hide Keyboard When Nil
                activeField?.resignFirstResponder()
            }
        }
        
        didSet {
            if activeField != nil {
                // Become the First Responder and Show Keyboard
                activeField?.becomeFirstResponder()
                
                // Update Done Bar Button State
                doneBarButton.isEnabled = !(titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
            } else {
                doneBarButton.isEnabled = false
            }
        }
    }
    
    // Tap Gesture Recognizer For Text View
    
    var textViewTapper: UITapGestureRecognizer {
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tappedTextView(_:)))
        
        return tapper
    }
    
    var categoryLabelTapper: UITapGestureRecognizer {
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tappedCategoryLabel(_:)))
        
        return tapper
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        setupNotificationHandling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var updated = false
        
        // Update Note
        if let title = titleTextField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty && note?.title != title {
            note?.title = title
            updated = true
        }
        
        if let contents = contentsTextView.text, note?.contents != contents {
            note?.contents = contents
            updated = true
        }
        
        if updated {
            note?.updatedAt = Date()
        }
    }
    
    fileprivate func setupView() {
        setupTagsLabel()
        setupTitleTextField()
        setupContentsTextView()
        setupCategoryLabel()
        
        // Disable Done Bar Button
        doneBarButton.isEnabled = false
        
        // Add Tap Gesture Recognizer
        contentsTextView.addGestureRecognizer(textViewTapper)
    }
    
    // MARK: - Helper Methods
    
    fileprivate func setupTagsLabel() {
        updateTagsLabel()
    }
    
    fileprivate func updateTagsLabel() {
        tagsLabel.text = note?.alphabetizedTagsAsString ?? "No Tags"
    }
    
    fileprivate func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: note?.managedObjectContext)
    }
    
    @objc fileprivate func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        
        if (updates.filter { return $0 == note }).count > 0 {
            updateCategoryLabel()
            updateTagsLabel()
        }
    }
    
    /// When Single-Tapped On Text View
    ///
    /// - Parameter recognizer: The tap recognizer
    @objc fileprivate func tappedTextView(_ recognizer: UITapGestureRecognizer) {
        contentsTextView.removeGestureRecognizer(recognizer)
        contentsTextView.dataDetectorTypes = []
        contentsTextView.isEditable = true
        
        activeField = contentsTextView
    }
    
    /// When Single-Tapped On Category Label
    ///
    /// - Parameter recognizer: The tap recognizer
    @objc fileprivate func tappedCategoryLabel(_ recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: Segue.Categories, sender: nil)
    }

    fileprivate func setupTitleTextField() {
        titleTextField.text = note?.title
    }
    
    fileprivate func setupContentsTextView() {
        contentsTextView.text = note?.contents
    }
    
    fileprivate func setupCategoryLabel() {
        categoryLabel.text = note?.category?.name ?? "No Category"
        categoryLabel.addGestureRecognizer(categoryLabelTapper)
        categoryLabel.isUserInteractionEnabled = true
    }
    
    fileprivate func updateCategoryLabel() {
        // Configure Category Label
        categoryLabel.text = note?.category?.name ?? "No Category"
    }
    
    @IBAction func beginEditing(_ sender: Any) {
        activeField = sender as? UIView
        
        if let title = titleTextField.text?.trimmingCharacters(in: .whitespaces) {
            doneBarButton.isEnabled = !title.isEmpty
        }
    }
    
    @IBAction func startTypingTitle(_ sender: UITextField) {
        if let title = sender.text?.trimmingCharacters(in: .whitespaces) {
            doneBarButton.isEnabled = !title.isEmpty
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        activeField = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.Categories:
            guard let destination = segue.destination as? CCCategoriesTableViewController else { return }
            
            // Configure Destination
            destination.note = note
            
            break
        case Segue.Tags:
            guard let destination = segue.destination as? CCTagsTableViewController else { return }
            
            // Configure Destination
            destination.note = note
            
            break
        default:
            break
        }
    }
}

extension CCNoteViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        
        textView.addGestureRecognizer(textViewTapper)
        
        doneBarButton.isEnabled = false
    }
}
