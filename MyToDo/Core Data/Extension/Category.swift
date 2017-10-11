//
//  Category.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/8/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension Category {
    
    var color: UIColor? {
        get {
            guard let hex = colorHex else { return nil }
            
            return UIColor(hex: hex)
        }
        
        set(newColor) {
            if let newColor = newColor {
                colorHex = newColor.toHex
            }
        }
    }
    
}
