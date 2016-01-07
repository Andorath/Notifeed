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

extension UITabBarController
{
    public func incrementBadgeForTabAtIndex(index: Int)
    {
        if let badge = self.viewControllers?[index].tabBarItem.badgeValue
        {
            if let badgeVal = Int(badge)
            {
                self.viewControllers?[index].tabBarItem.badgeValue = String(badgeVal + 1)
            }
        }
        else
        {
            self.viewControllers?[index].tabBarItem.badgeValue = String(1)
        }
    }
    
    public func decrementBadgeForTabAtIndex(index: Int)
    {
        if let badge = self.viewControllers?[index].tabBarItem.badgeValue
        {
            if let badgeVal = Int(badge)
            {
                self.viewControllers?[index].tabBarItem.badgeValue = (badgeVal-1 == 0) ? nil : String(badgeVal-1)
            }
        }
    }
}