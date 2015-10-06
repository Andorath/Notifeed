//
//  Reachability.swift
//  Notifeed
//
//  Created by Marco Salafia on 06/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    class func showNoConnectionAlert(presenter: UIViewController, actionHandler: ((UIAlertAction) -> ())?)
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Attenzione alert no connessione"),
            message: NSLocalizedString("There is no network connection.", comment: "Messaggio alert no connessione"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
         alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Action invalid url alert"),
                                                 style: .Default,
                                                 handler: actionHandler))
        
        presenter.presentViewController(alertController, animated: true, completion: nil)
    }
    
}