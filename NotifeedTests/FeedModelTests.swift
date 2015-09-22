//
//  FeedModelTests.swift
//  Notifeed
//
//  Created by Marco Salafia on 21/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//
@testable import Notifeed
import XCTest
import CoreData

class FeedModelTests: XCTestCase
{
    var model: FeedModel?
    var context: NSManagedObjectContext? = nil
    
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext
    {
        if let _context = context
        {
            return _context
        }
        else
        {
            let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
            
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do
            {
                try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            } catch _
            {
                
            }
            
            let managedObjectContext = NSManagedObjectContext()
            managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
            
            return managedObjectContext
        }
    }

    override func setUp()
    {
        super.setUp()
        context = setUpInMemoryManagedObjectContext()
        model = FeedModel.getSharedInstance(context!)
    }
    
    override func tearDown()
    {
        FeedModel.destroySharedInstance()
        super.tearDown()
    }

    func testGetSharedIstance()
    {
        let instance = FeedModel.getSharedInstance()
        
        XCTAssertTrue(model === instance)
        
        let newInstance = FeedModel.getSharedInstance(self.setUpInMemoryManagedObjectContext())
        
        XCTAssertTrue(model === newInstance)
    }
    
    func testAddFeed()
    {
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate()))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate()))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate()))
        
        let request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = try! context!.executeFetchRequest(request) as? [NSManagedObject]
        
        XCTAssertTrue(results?.count == 3)
    }
    
    func testDeleteFeed()
    {
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate()))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate()))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate()))
        
        var request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        var results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 1)
        
        do
        {
            try model!.deleteFeed(Feed(title: "B", link: "url1", creazione: NSDate()))
        }
        catch _
        {
            XCTFail("Error catched!")
        }
        
        request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 0)
        
        do
        {
            try model!.deleteFeed(Feed(title: "B", link: "url1", creazione: NSDate()))
            XCTFail("Error catched!")
        }
        catch _
        {
            XCTAssertTrue(true)
        }
        
    }
    
    func testDeleteFeedAtIndex()
    {
        do
        {
            try model!.deleteFeedAtIndex(2)
            XCTFail("Error catched!")
        }
        catch _
        {
            XCTAssertTrue(true)
        }
        
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate()))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate()))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate()))
        
        var request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        var results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 1)
        
        do
        {
            try model!.deleteFeedAtIndex(1)
        }
        catch _
        {
            XCTFail("Error catched!")
        }
        
        request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 0)
        
        do
        {
            try model!.deleteFeedAtIndex(2)
            XCTFail("Error catched!")
        }
        catch _
        {
            XCTAssertTrue(true)
        }
    }
    
    func testAlreadyExistsFeedWithTitle()
    {
        XCTAssertFalse(model!.alreadyExistsFeedWithTitle("A"))
        
        model!.addFeed(Feed(title: "A", link: "url2", creazione: NSDate()))
        
        XCTAssertTrue(model!.alreadyExistsFeedWithTitle("A"))
    }
    
    func testGetFeeds()
    {
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate()))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate()))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate()))
        
        let feeds = model!.getFeeds()
        
        XCTAssertTrue(feeds.count == 3)
    }
    
    func testGetManagedFeedForIndex()
    {
        var managedFeed = model!.getManagedFeedForIndex(0)
        XCTAssertTrue(managedFeed == nil)
        
        managedFeed = model!.getManagedFeedForIndex(3)
        XCTAssertTrue(managedFeed == nil)
        
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate()))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate()))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate()))
        
        managedFeed = model!.getManagedFeedForIndex(1)
        let title = managedFeed!.valueForKey("title") as! String
        XCTAssertTrue(title == "B")
    }

}
