//
//  MGSDataModel.swift
//  Notifeed
//
//  Created by Marco Salafia on 05/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MGSDataModel
{
    let del: AppDelegate
    let context: NSManagedObjectContext
    
    //Model Property
    var feedArray: [AnyObject]? = [AnyObject]()
    
    init()
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        context = del.managedObjectContext!
        updateDataFromModel()
    }
    
    //MARK: - Managing Data
    
    func updateDataFromModel()
    {
        var request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        var sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        feedArray = context.executeFetchRequest(request, error: nil)!
    }
    
    func addNewFeedToModel(feed: MGSFeed)
    {
        var feedMO = NSEntityDescription.insertNewObjectForEntityForName("Feed", inManagedObjectContext: context) as! NSManagedObject
        
        feedMO.setValue(feed.title, forKey: "title")
        feedMO.setValue(feed.link, forKey: "link")
        feedMO.setValue(feed.creazione, forKey: "creazione")
        context.save(nil)
        
        feedArray?.append(feedMO)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSNewFeedAddedNotification", object: nil)
    }
    
    func deleteFeedFromModel(index: Int)
    {
        context.deleteObject(feedArray![index] as! NSManagedObject)
        context.save(nil)
        
        feedArray?.removeAtIndex(index)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSFeedDeletedNotification", object: nil)
    }
    
    //MARK: - Getting Data
    
    func alreadyExists (title: String) -> Bool
    {
        var request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "title = %@", title)
        request.predicate = predicate
        var results = context.executeFetchRequest(request, error: nil)
        
        return !results!.isEmpty
    }
    
    func getFeedModel() -> ([MGSFeed]?)
    {
        var feeds: [MGSFeed]? = [MGSFeed]()
        var temp: MGSFeed
        
        if let vector = feedArray
        {
            for feedMO in vector
            {
                temp = MGSFeed()
                temp.title = (feedMO as! NSManagedObject).valueForKey("title") as! String
                temp.link = (feedMO as! NSManagedObject).valueForKey("link") as! String
                temp.creazione = (feedMO as! NSManagedObject).valueForKey("creazione") as! NSDate
                feeds?.append(temp)
            }
        }
        
        return feeds
    }
    
    func getManagedObjectFeedForIndex(index: Int) -> NSManagedObject
    {
        return feedArray![index] as! NSManagedObject
    }
    
}
