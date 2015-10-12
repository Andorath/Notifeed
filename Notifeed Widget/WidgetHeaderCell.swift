//
//  WidgetHeaderCell.swift
//  Notifeed
//
//  Created by Marco Salafia on 09/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class WidgetHeaderCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var goToAppButton: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }

}
