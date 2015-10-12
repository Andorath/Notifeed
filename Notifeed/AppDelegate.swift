//
//  AppDelegate.swift
//  Notifeed
//
//  Created by Marco Salafia on 01/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var splitViewController: UISplitViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        setAllSplitController()
        setCustomAppearance()
        updateAchivedTabBadge()
        initUserDefaults()
        return true
    }

    
    func setAllSplitController()
    {
        if let split1 = (self.window?.rootViewController as? UITabBarController)?.viewControllers?[0] as? UISplitViewController
        {
            split1.delegate = self
            let cnt = split1.viewControllers.count
            (split1.viewControllers[cnt - 1] as! UINavigationController).viewControllers[0] = MGSEmptyDetailViewController(nibName: "MGSEmptyDetailViewController", bundle: nil)
            split1.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        }
        
        if let split2 = (self.window?.rootViewController as? UITabBarController)?.viewControllers?[1] as? UISplitViewController
        {
            split2.delegate = self
            let cnt = split2.viewControllers.count
            (split2.viewControllers[cnt - 1] as! UINavigationController).viewControllers[0] = MGSEmptyDetailViewController(nibName: "MGSEmptyDetailViewController", bundle: nil)
            split2.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        }
    }
    
    func setCustomAppearance()
    {
        UIBarButtonItem.my_appearanceWhenContainedIn(UISearchBar).tintColor = UIColor(red: 246.0/255.0, green: 106.0/255.0, blue: 75.0/255.0, alpha: 1)
        UIBarButtonItem.my_appearanceWhenContainedIn(UIToolbar).tintColor = UIColor(red: 246.0/255.0, green: 106.0/255.0, blue: 75.0/255.0, alpha: 1)
    }
    
    func updateAchivedTabBadge()
    {
        if let tabItem = (self.window?.rootViewController as? UITabBarController)?.tabBar.items?[1]
        {
            let count = FeedModel.getSharedInstance().countUncheckedPosts()
            
            tabItem.badgeValue = count == 0 ? nil : String(count)
        }
    }
    
    func initUserDefaults()
    {
        _ = NSUserDefaults(suiteName: "group.notifeedcontainer")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        FeedDataBase.sharedInstance.saveContext()
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool
    {
        let urlString = "\(url)"
        
        if urlString == "mgsnotifeed://"
        {
            let userDefaults = NSUserDefaults(suiteName: "group.notifeedcontainer")
            if let title = userDefaults?.valueForKey("favoriteFeed") as? String, let tabVC = self.window?.rootViewController as? UITabBarController
            {
                if let splitVC = tabVC.viewControllers?[0] as? UISplitViewController
                {
                    let favoriteFeed = FeedModel.getSharedInstance().getFeedWithTitle(title)
                    
                    if let navigationVC = splitVC.viewControllers[0] as? UINavigationController
                    {
                        if let feedVC = navigationVC.viewControllers[0] as? FeedViewController
                        {
                            let storyboard = UIStoryboard(name: "Main3", bundle: nil)
                            let favoriteVC = storyboard.instantiateViewControllerWithIdentifier("postViewController") as! PostsViewController
                            favoriteVC.selectedFeed = favoriteFeed
                            
                            tabVC.selectedIndex = 0
                            
                            navigationVC.setViewControllers([feedVC, favoriteVC], animated: true)
                        }
                    }
                }
            }
        }
        
        return true
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

