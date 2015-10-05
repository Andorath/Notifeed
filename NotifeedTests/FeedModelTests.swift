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
        FeedModel.destroySharedInstance()
        context = setUpInMemoryManagedObjectContext()
        model = FeedModel.getSharedInstance(context!)
    }
    
    override func tearDown()
    {
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
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate(), position: 0))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate(), position: 1))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate(), position: 2))
        
        let request = NSFetchRequest(entityName: "Feed")
        request.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = try! context!.executeFetchRequest(request) as? [NSManagedObject]
        
        XCTAssertTrue(results?.count == 3)
    }
    
    func testDeleteFeed()
    {
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate(), position: 0))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate(), position: 1))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate(), position: 2))
        
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
        
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate(), position: 0))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate(), position: 1))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate(), position: 2))
        
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
        
        print(results?.count)
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
        
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate(), position: 0))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate(), position: 1))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate(), position: 2))
        
        managedFeed = model!.getManagedFeedForIndex(1)
        let title = managedFeed!.valueForKey("title") as! String
        XCTAssertTrue(title == "B")
    }
    
    func testEditFeed()
    {
        var feed = Feed(title: "A", link: "url1", creazione: NSDate())
        model!.addFeed(feed)
        
        XCTAssertTrue(model!.alreadyExistsFeedWithTitle("A"))
        
        model!.editFeed(feed, withNewFeed: Feed(title: "B", link: "url2", creazione: NSDate()))
        
        XCTAssertFalse(model!.alreadyExistsFeedWithTitle("A"))
        XCTAssertTrue(model!.alreadyExistsFeedWithTitle("B"))
        
        feed = model!.getFeeds()[0]
        
        XCTAssertTrue(feed.link == "url2")
    }
    
    func testMoveFeedFromIndexToIndex()
    {
        model!.addFeed(Feed(title: "A", link: "url1", creazione: NSDate(), position: 0))
        model!.addFeed(Feed(title: "B", link: "url2", creazione: NSDate(), position: 1))
        model!.addFeed(Feed(title: "C", link: "url3", creazione: NSDate(), position: 2))
        model!.addFeed(Feed(title: "D", link: "url4", creazione: NSDate(), position: 3))
        model!.addFeed(Feed(title: "E", link: "url5", creazione: NSDate(), position: 4))
        
        FeedModel.getSharedInstance().moveFeedFromIndex(3, toIndex: 1)
        
        let feeds = FeedModel.getSharedInstance().getFeeds()
        
        XCTAssertTrue(feeds[0].title == "A")
        XCTAssertTrue(feeds[1].title == "D")
        XCTAssertTrue(feeds[2].title == "B")
        XCTAssertTrue(feeds[3].title == "C")
        XCTAssertTrue(feeds[4].title == "E")
    }
    
    func testAddPost()
    {
        model!.addPost(Post())
        model!.addPost(Post())
        model!.addPost(Post())
        
        let request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "creazione", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let results = try! context!.executeFetchRequest(request) as? [NSManagedObject]
        
        XCTAssertTrue(results?.count == 3)
    }
    
    func testGetPosts()
    {
        model!.addPost(Post())
        model!.addPost(Post())
        model!.addPost(Post())
        
        let posts = model!.getPosts()
        
        XCTAssertTrue(posts.count == 3)
    }
    
    func testDeletePostAtIndex()
    {
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        model!.addPost(Post(title: "B", link: "Url2", postDescription: "b"))
        model!.addPost(Post(title: "C", link: "Url3", postDescription: "c"))
        
        var request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        var results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 1)
        
        model!.deletePostAtIndex(1)
        
        request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 0)
        
        let posts = model!.getPosts()
        
        XCTAssertTrue(posts.count == 2)
    }
    
    func testDeletePost()
    {
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        model!.addPost(Post(title: "B", link: "Url2", postDescription: "b"))
        model!.addPost(Post(title: "C", link: "Url3", postDescription: "c"))
        
        var request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        var results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 1)
        
        model!.deletePost(Post(title: "B", link: "Url55555", postDescription: "AA"))
        
        request = NSFetchRequest(entityName: "Post")
        request.returnsObjectsAsFaults = false
        predicate = NSPredicate(format: "title = %@", "B")
        request.predicate = predicate
        results = try? context!.executeFetchRequest(request)
        
        XCTAssertTrue(results?.count == 0)
        
        let posts = model!.getPosts()
        
        XCTAssertTrue(posts.count == 2)
    }
    
    func testAlreadyExistsPost()
    {
        XCTAssertFalse(model!.alreadyExistsPost(Post(title: "A", link: "url1", postDescription: "a")))
        
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        
        XCTAssertTrue(model!.alreadyExistsPost(Post(title: "A", link: "url1", postDescription: "a")))
    }
    
    func testSetCheckedPostAtIndex()
    {
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        model!.addPost(Post(title: "B", link: "Url2", postDescription: "b"))
        model!.addPost(Post(title: "C", link: "Url3", postDescription: "c"))
        
        var check = model!.getPosts()[1].checked
        
        XCTAssertFalse(check)
        
        model!.setCheckedPostAtIndex(1)
        
        check = model!.getPosts()[1].checked
        
        XCTAssertTrue(check)
    }
    
    func testSetCheckedPost()
    {
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        model!.addPost(Post(title: "B", link: "Url2", postDescription: "b"))
        model!.addPost(Post(title: "C", link: "Url3", postDescription: "c"))
        
        var check = model!.getPosts()[1].checked
        
        XCTAssertFalse(check)
        
        model!.setCheckedPost(Post(title: "B", link: "Url2", postDescription: "b"))
        
        check = model!.getPosts()[1].checked
        
        XCTAssertTrue(check)
    }

    func testCountUncheckedPosts()
    {
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        model!.addPost(Post(title: "B", link: "Url2", postDescription: "b"))
        model!.addPost(Post(title: "C", link: "Url3", postDescription: "c"))
        
        model!.setCheckedPostAtIndex(1)
        
        XCTAssertTrue(model!.countUncheckedPosts() == 2)
    }
    
    func testSetUncheckedPost()
    {
        model!.addPost(Post(title: "A", link: "Url1", postDescription: "a"))
        model!.addPost(Post(title: "B", link: "Url2", postDescription: "b"))
        model!.addPost(Post(title: "C", link: "Url3", postDescription: "c"))
        
        model!.setCheckedPostAtIndex(1)
        
        var post = model!.getPosts()[1]
        
        XCTAssertTrue(post.checked)
        
        model!.setUncheckedPost(post)
        
        post = model!.getPosts()[1]
        
        XCTAssertFalse(post.checked)
    }
    
}
