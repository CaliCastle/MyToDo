//
//  CCNoteTableViewCell.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/6/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class CCNoteTableViewCell: UITableViewCell {

    // MARK: - Static Properties
    
    static let reuseIdentifier = "NoteTableViewCell"
    
    // MARK: - Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var updatedAtLabel: UILabel!
    @IBOutlet var colorView: UIView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
