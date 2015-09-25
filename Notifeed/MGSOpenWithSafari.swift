//
//  MGSOpenWithSafari.swift
//  Notifeed
//
//  Created by Marco Salafia on 07/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import UIKit

class MGSOpenWithSafari: UIActivity
{
    var url: NSURL?
    
    override func activityType() -> String?
    {
        return "Open given URL with Safari"
    }
    
    override func activityTitle() -> String?
    {
        return NSLocalizedString("Open in Safari", comment: "Comento dell'activity di Safari")
    }
    
    override func activityImage() -> UIImage?
    {
        return UIImage(named: "SafariActivity@2x.png")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool
    {
        if activityItems[1] is String
        {
            return true
        }
        
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject])
    {
        if let site = activityItems[1] as? String
        {
            url = NSURL(string: site)
        }
    }
    
    override func performActivity()
    {
        if let _ = url
        {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}
