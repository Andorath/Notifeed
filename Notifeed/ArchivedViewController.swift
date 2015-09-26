//
//  ArchivedViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 26/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class ArchivedViewController: UITableViewController, UISearchResultsUpdating
{
    var postArray: [Post] = []
    
    var filteredTableData = [Post]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        resultSearchController = getResultSearchController()
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
    
    func updateInterfaceByCell()
    {
        tableView.reloadData()
        filteredTableData = FeedModel.getSharedInstance().getPosts()
    }
    
    func updateInterfaceBySections()
    {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        filteredTableData = FeedModel.getSharedInstance().getPosts()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            if self.resultSearchController.active
            {
                return self.filteredTableData.count
            }
            else
            {
                return FeedModel.getSharedInstance().getPosts().count
            }
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            if resultSearchController.active
            {
                FeedModel.getSharedInstance().deletePost(filteredTableData[indexPath.row])
                filteredTableData.removeAtIndex(indexPath.row)
            }
            else
            {
                FeedModel.getSharedInstance().deletePostAtIndex(indexPath.row)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    //MARK: - Searching Result Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let posts = FeedModel.getSharedInstance().getPosts()
        let array: [Post]
        if searchController.searchBar.text!.isEmpty
        {
            array = FeedModel.getSharedInstance().getPosts()
        }
        else
        {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchController.searchBar.text!)
            array = posts.filter{searchPredicate.evaluateWithObject($0)}
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
