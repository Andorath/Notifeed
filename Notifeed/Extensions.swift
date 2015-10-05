//
//  Extensions.swift
//  Notifeed
//
//  Created by Marco Salafia on 29/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController
{
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationBar.setBackgroundImage(UIImage(named: "navigation_bar.png"),
                                              forBarPosition: UIBarPosition.TopAttached,
                                              barMetrics: UIBarMetrics.Default)
    }
}
