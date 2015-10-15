//
//  NotifeedStore.swift
//  Notifeed
//
//  Created by Marco Salafia on 13/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import iAd

private enum NotifeedVersion: Int
{
    case Lite = 0
    case Full = 1
    
    func canShowAd() -> Bool
    {
        switch self
        {
            case .Lite:
                return true
            case .Full:
                return false
        }
    }
}

class NotifeedStore
{
    private var applicationVersion: NotifeedVersion
    
    static var sharedInstance = NotifeedStore()
    
    private init() { applicationVersion = .Lite }
    
    func canShowiAd() -> Bool
    {
        return applicationVersion.canShowAd()
    }
}