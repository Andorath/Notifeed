//
//  PostsViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class PostsViewController: UITableViewController, NSXMLParserDelegate, UISearchResultsUpdating
{
    var selectedFeed: Feed?
    var postArray: [Post] = []
    
    var filteredTableData = [Post]()
    var resultSearchController = UISearchController()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        resultSearchController = getResultSearchController()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        scanSelectedFeed()
    }
    
    func getResultSearchController() -> UISearchController
    {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.searchBarStyle = .Minimal
        
        self.tableView.tableHeaderView = controller.searchBar
        
        return controller
    }
    
    func scanSelectedFeed()
    {
        if let feed = selectedFeed
        {
            postArray = FeedParser().parseLink(feed.link)
            updateInterfaceBySections()
        }
    }
    
    func updateInterfaceBySections()
    {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.resultSearchController.active
        {
            return self.filteredTableData.count
        }
        else
        {
            return postArray.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if self.resultSearchController.active
        {
            cell.textLabel?.text = filteredTableData[indexPath.row].title
        }
        else
        {
            cell.textLabel?.text = postArray[indexPath.row].title
            
            return cell
        }
        
        return cell
    }
    
    //MARK: - Searching Result Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let array: [Post]
        if searchController.searchBar.text!.isEmpty
        {
            array = postArray
        }
        else
        {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchController.searchBar.text!)
            array = postArray.filter{searchPredicate.evaluateWithObject($0)}
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
    }

}
