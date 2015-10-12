//
//  FeedCell.swift
//  Notifeed
//
//  Created by Marco Salafia on 10/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell
{
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
