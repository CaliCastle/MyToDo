//
//  CCCategoryTableViewCell.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/8/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol CCCategoryTableViewCellDelegate {
    func iconButtonTapped(at indexPath: IndexPath)
}

class CCCategoryTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "CategoryTableViewCell"
    
    @IBOutlet var colorView: UIView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var iconButton: UIButton!
    
    var indexPath: IndexPath?
    
    var delegate: CCCategoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func tappedIconButton(_ sender: UIButton) {
        delegate?.iconButtonTapped(at: indexPath!)
    }
}
