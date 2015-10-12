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
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.imageView?.frame = CGRectMake(15, 16, 36, 36)
        self.imageView?.image = UIImage(named: "feed_icon.png")
        
        self.textLabel?.frame = CGRectMake(66, 12, super.textLabel!.frame.size.width - 100, super.textLabel!.frame.size.height)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 22)
        self.textLabel?.minimumScaleFactor = 0.6
        
        self.detailTextLabel?.frame = CGRectMake(66, 38, super.detailTextLabel!.frame.size.width - 100, super.detailTextLabel!.frame.size.height)
        self.detailTextLabel?.adjustsFontSizeToFitWidth = true
        self.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        self.detailTextLabel?.minimumScaleFactor = 0.6
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
