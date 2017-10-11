//
//  CCCategoryTableViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/8/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class CCCategoryTableViewController: UITableViewController {

    // MARK: - Properties
    var managedObjectContext: NSManagedObjectContext?
    
    var isAdding = false
    
    var color: UIColor = .black
    
    var category: Category?
    
    @IBOutlet var categoryTextField: UITextField!
    @IBOutlet var colorView: UIView!
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAdding {
            categoryTextField.becomeFirstResponder()
        }
    }
    
    fileprivate func setupView() {
        // Adjust Navigation Title
        title = isAdding ? "Add Category" : "Edit Category"
        
        categoryTextField.text = category?.name ?? ""
        color = category?.color ?? .black
        
        setupSliders()
        setupColorView()
    }
    
    fileprivate func setupSliders() {
        // Helpers
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0
        
        // Extract color
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        redSlider.value = Float(r)
        greenSlider.value = Float(g)
        blueSlider.value = Float(b)
        
        let shadowColor = UIColor.black.cgColor
        let shadowOpacity = Float(0.2)
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius = CGFloat(2)
        
        redSlider.layer.shadowColor = shadowColor
        redSlider.layer.shadowOpacity = shadowOpacity
        redSlider.layer.shadowOffset = shadowOffset
        redSlider.layer.shadowRadius = shadowRadius
        
        greenSlider.layer.shadowColor = shadowColor
        greenSlider.layer.shadowOpacity = shadowOpacity
        greenSlider.layer.shadowOffset = shadowOffset
        greenSlider.layer.shadowRadius = shadowRadius
        
        blueSlider.layer.shadowColor = shadowColor
        blueSlider.layer.shadowOpacity = shadowOpacity
        blueSlider.layer.shadowOffset = shadowOffset
        blueSlider.layer.shadowRadius = shadowRadius
    }
    
    fileprivate func setupColorView() {
        colorView.layer.cornerRadius = 12
        colorView.layer.shadowRadius = 2
        colorView.layer.shadowColor = UIColor.black.cgColor
        colorView.layer.shadowOpacity = 0.2
        colorView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        updateColorView()
    }
    
    func updateColorView() {
        let newColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1)
        
        colorView.backgroundColor = newColor
        color = newColor
    }
    
    @IBAction private func changeColor(_ sender: UISlider) {
        updateColorView()
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let categoryName = categoryTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        
        if isAdding {
            addCategory(name: categoryName)
        } else {
            updateCategory(category: category!, to: categoryName)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Data Model
    
    fileprivate func addCategory(name: String) {
        guard let managedObjectContext = managedObjectContext else { return }
        
        // Create Category
        let category = Category(context: managedObjectContext)
        
        // Configure Category
        category.name = name
        category.color = color
    }
    
    fileprivate func updateCategory(category: Category, to name: String) {
        // Update Properties
        category.name = name
        category.color = color
    }
}
