//
//  UIViewController.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/6/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Alerts
    
    func showAlert(with title: String, and message: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Configure Alert Action
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Empty Message Label
    
    func createEmptyMessageLabel(message: String) -> UILabel {
        let label = UILabel()
        
        label.text = message
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        
        return label
    }
}
