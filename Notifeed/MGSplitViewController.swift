//
//  MGSplitViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 18/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class MGSplitViewController: UISplitViewController, UISplitViewControllerDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        func setSplitController()
        {
            self.delegate = self
            let cnt = self.viewControllers.count
            (self.viewControllers[cnt - 1] as! UINavigationController).viewControllers[0] = MGSEmptyDetailViewController(nibName: "MGSEmptyDetailViewController", bundle: nil)
            self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        }
        
        setSplitController()
    }
    
    // MARK: - Split view
    
    func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController) -> UIViewController?
    {
        return splitViewController.viewControllers[0] as? UINavigationController
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        if let _ = (secondaryViewController as? UINavigationController)?.topViewController as? MGSEmptyDetailViewController
        {
            return true
        }
        else if let _ = secondaryViewController as? MGSEmptyDetailViewController
        {
            return true
        }
        
        return false
    }
    
    func primaryViewControllerForExpandingSplitViewController(splitViewController: UISplitViewController) -> UIViewController?
    {
        if let masterNav = splitViewController.viewControllers[0] as? UINavigationController
        {
            return masterNav
        }
        
        return nil
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController?
    {
        if let _ = (primaryViewController as? UINavigationController)?.topViewController as? PostsViewController
        {
            return MGSEmptyDetailViewController(nibName: "MGSEmptyDetailViewController", bundle: nil)
        }
        else if let vc = (primaryViewController as? UINavigationController)?.topViewController as? MGSEmptyDetailViewController
        {
            return vc
        }
        
        return nil
    }

}
