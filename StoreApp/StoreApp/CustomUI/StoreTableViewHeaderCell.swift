//
//  StoreTableViewHeaderCell.swift
//  StoreApp
//
//  Created by 조재흥 on 19. 4. 23..
//  Copyright © 2019 hngfu. All rights reserved.
//

import UIKit

class StoreTableViewHeaderCell: UITableViewCell {
    
    //MARK: - Properties
    //MARK: IBOutlet
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var sectionDescriptionLabel: UILabel!
    
    //MARK: Type
    static let nibName = "StoreTableViewHeaderCell"
    static let identifier = "storeTableViewHeaderCell"
    
    //MARK: - Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}