//
//  FeedModel.swift
//  Notifeed
//
//  Created by Marco Salafia on 21/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum FeedModelError: ErrorType
{
    case EmptyModel
    case NoSuchElement
    case OutOfBound
    case BadFetching
}

class FeedModel
{
    static private var sharedInstance: FeedModel?
    
    let del: AppDelegate
    let context: NSManagedObjectContext
    
    private init()
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        context = del.managedObjectContext!
    }
    
    private init(context: NSManagedObjectContext)
    {
        del = UIApplication.sharedApplication().delegate as! AppDelegate
        self.context = context
    }
    
    // MARK: - Metodi singleton
    
    static func getSharedInstance() -> FeedModel
    {
        if let singleton = sharedInstance
        {
            return singleton
        }
        else
        {
            sharedInstance = FeedModel()
            return sharedInstance!
        }
    }
    
    static func getSharedInstance(context: NSManagedObjectContext) -> FeedModel
    {
        if let singleton = sharedInstance
        {
            return singleton
        }
        else
        {
            sharedInstance = FeedModel(context: context)
            return sharedInstance!
        }
    }
    
    static func destroySharedInstance()
    {
        sharedInstance = nil
    }
    
    //MARK: - Medoti di Managing dei dati
    
    func addFeed(feed: Feed)
    {
        let feedMO = NSEntityDescription.insertNewObjectForEntityForName("Feed", inManagedObjectContext: context)
        
        feedMO.setValue(feed.title, forKey: "title")
        feedMO.setValue(feed.link, forKey: "link")
        feedMO.setValue(feed.creazione, forKey: "creazione")
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func deleteFeedAtIndex(index: Int) throws
    {
        let results = getManagedFeeds()
        
        if let res = results
        {
            if res.isEmpty
            {
                throw FeedModelError.EmptyModel
            }
            else if index < 0 || index > res.count - 1
            {
                throw FeedModelError.OutOfBound
            }
            else
            {
                context.deleteObject(res[index])
                do
                {
                    try context.save()
                }
                catch _
                {}
            }
        }
        else
        {
            throw FeedModelError.BadFetching
        }
    }
    
    func getManagedFeeds() -> [NSManagedObject]?
    {
        let request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = try! context.executeFetchRequest(request) as? [NSManagedObject]
        return results
    }
    
    func deleteFeed(feed: Feed) throws
    {
        let results = getManagedFeedsWithTitle(feed.title)
        if let res = results
        {
            if res.isEmpty
            {
                throw FeedModelError.NoSuchElement
            }
            else
            {
                context.deleteObject(res[0])
                do
                {
                    try context.save()
                }
                catch _
                {}
            }
        }
        else
        {
            throw FeedModelError.BadFetching
        }
    }
    
    func getManagedFeedsWithTitle(title: String) -> [NSManagedObject]?
    {
        let request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "title = %@", title)
        request.predicate = predicate
        let results = try? context.executeFetchRequest(request) as! [NSManagedObject]
        return results
    }
    
    // MARK: - Getting Data
    
    func alreadyExistsFeedWithTitle (title: String) -> Bool
    {
        let results = getManagedFeedsWithTitle(title)
        
        return !results!.isEmpty
    }
    
    func getFeeds() -> [Feed]
    {
        var feeds: [Feed] = [Feed]()
        var temp: Feed
        
        let _results = getManagedFeeds()
        
        if let results = _results
        {
            for feedMO in results
            {
                temp = Feed()
                temp.title = feedMO.valueForKey("title") as! String
                temp.link = feedMO.valueForKey("link") as! String
                temp.creazione = feedMO.valueForKey("creazione") as! NSDate
                feeds.append(temp)
            }
        }
        
        return feeds
    }
    
    func getManagedFeedForIndex(index: Int) -> NSManagedObject?
    {
        let results = getManagedFeeds()

        if let feeds = results
        {
            if index < 0 || index > results!.count - 1
            {
                return nil
            }
            
            return feeds[index]
        }
        
        return nil
    }
    
    func editFeed(feed: Feed, withNewFeed newFeed: Feed)
    {
        if let oldFeed = getManagedFeedsWithTitle(feed.title)?[0]
        {
            oldFeed.setValue(newFeed.title, forKey: "title")
            oldFeed.setValue(newFeed.link, forKey: "link")
            do
            {
                try context.save()
            }
            catch _
            {}
        }
    }
    
    // MARK: Managing Posts
    
    func addPost(post: Post)
    {
        let managedPost = NSEntityDescription.insertNewObjectForEntityForName("Post", inManagedObjectContext: context)
        
        managedPost.setValue(post.title, forKey: "title")
        managedPost.setValue(post.link, forKey: "link")
        managedPost.setValue(post.postDescription, forKey: "postDescription")
        managedPost.setValue(post.eName, forKey: "eName")
        managedPost.setValue(NSDate(), forKey: "creazione")
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func getPosts() -> [Post]
    {
        var feeds: [Post] = [Post]()
        var temp: Post
        
        let _results = getManagedPosts()
        
        if let results = _results
        {
            for managedPost in results
            {
                temp = Post()
                temp.title = managedPost.valueForKey("title") as! String
                temp.link = managedPost.valueForKey("link") as! String
                temp.postDescription = managedPost.valueForKey("postDescription") as! String
                temp.eName = managedPost.valueForKey("eName") as! String

                feeds.append(temp)
            }
        }
        
        return feeds
    }
    
    func getManagedPosts() -> [NSManagedObject]?
    {
        let request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = try! context.executeFetchRequest(request) as? [NSManagedObject]
        return results
    }
    
    func deletePostAtIndex(index: Int)
    {
        if let results = getManagedPosts()
        {
            context.deleteObject(results[index])
            do
            {
                try context.save()
            }
            catch _
            {}
        }
    }
    
    func deletePost(post: Post)
    {
        if let results = getManagedPostWithTitle(post.title)
        {
            context.deleteObject(results[0])
            do
            {
                try context.save()
            }
            catch _
            {}
        }
    }
    
    func getManagedPostWithTitle(title: String) -> [NSManagedObject]?
    {
        let request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "title = %@", title)
        request.predicate = predicate
        let results = try? context.executeFetchRequest(request) as! [NSManagedObject]
        return results
    }
    
}