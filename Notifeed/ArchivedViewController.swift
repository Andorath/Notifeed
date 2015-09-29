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
    var postArray: [Post] = FeedModel.getSharedInstance().getPosts()
    
    var filteredTableData = [Post]()
    var resultSearchController = UISearchController()
    
    var originalIndexPath: NSIndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initAllObservers()
        resultSearchController = getResultSearchController()
    }
    
    func initAllObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "archivingUpdate", name: "MGSArchivedNotification", object: nil)
    }
    
    func archivingUpdate()
    {
        incrementTabBarItemBadge()
        postArray = FeedModel.getSharedInstance().getPosts()
        tableView.reloadData()
    }
    
    func incrementTabBarItemBadge()
    {
        if let badge = splitViewController?.tabBarItem.badgeValue
        {
            if let badgeVal = Int(badge)
            {
                splitViewController?.tabBarItem.badgeValue = String(badgeVal + 1)
            }
        }
        else
        {
            splitViewController?.tabBarItem.badgeValue = String(1)
        }
    }
    
    func decrementTabBarItemBadge()
    {
        if let badge = splitViewController?.tabBarItem.badgeValue
        {
            if let badgeVal = Int(badge)
            {
                splitViewController?.tabBarItem.badgeValue = (badgeVal-1 == 0) ? nil : String(badgeVal-1)
            }
        }
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
        
        var post: Post
        
        if self.resultSearchController.active
        {
            post = filteredTableData[indexPath.row]
            cell.textLabel?.text = post.title
        }
        else
        {
            post = postArray[indexPath.row]
            cell.textLabel?.text = post.title
        }
        
        cell.accessoryView = post.checked ? nil : getDot()
        
        return cell
    }
    
    func getDot() -> UIImageView
    {
        let image = UIImageView(image: UIImage(named: "archived_dot.png"))
        image.frame = CGRectMake(0, 0, 15, 15)
        
        return image
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        var post: Post
        
        if self.resultSearchController.active
        {
            post = filteredTableData[indexPath.row]
            if let index = postArray.indexOf(post)
            {
                originalIndexPath = NSIndexPath(forRow: index, inSection: 0)
            }
        }
        else
        {
            post = postArray[indexPath.row]
            originalIndexPath = nil
        }
        
        if !post.checked
        {
            decrementTabBarItemBadge()
            post.checked = true
            FeedModel.getSharedInstance().setCheckedPost(post)
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.endUpdates()
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let oip = originalIndexPath
        {
            tableView.selectRowAtIndexPath(oip, animated: true, scrollPosition: .Top)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            var post: Post
            
            if resultSearchController.active
            {
                post = filteredTableData[indexPath.row]
                FeedModel.getSharedInstance().deletePost(post)
                filteredTableData.removeAtIndex(indexPath.row)
            }
            else
            {
                post = postArray[indexPath.row]
                FeedModel.getSharedInstance().deletePost(post)
                postArray.removeAtIndex(indexPath.row)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if !post.checked
            {
                decrementTabBarItemBadge()
            }
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let unreadAction = getUnreadRowAction()
        let deleteAction = getDeleteRowAction()
        
        return [deleteAction, unreadAction]
    }
    
    func getUnreadRowAction() -> UITableViewRowAction
    {
        let unreadLabel = NSLocalizedString("Unread", comment: "Azione Unread")
        let unreadAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal,
                                                title: unreadLabel,
                                                handler: unreadHandler)
        
        unreadAction.backgroundColor = UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 102.0/255.0, alpha: 1)
        
        return unreadAction
    }
    
    func unreadHandler(action: UITableViewRowAction, index: NSIndexPath)
    {
        var post: Post
        
        if self.resultSearchController.active
        {
            post = filteredTableData[index.row]
        }
        else
        {
            post = postArray[index.row]
        }
        
        if post.checked
        {
            unreadPost(post)
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Right)
            tableView.endUpdates()
        }
        
        self.setEditing(false, animated: true)
    }
    
    func unreadPost(post: Post)
    {
        post.checked = false
        FeedModel.getSharedInstance().setUncheckedPost(post)
        incrementTabBarItemBadge()
    }
    
    func getDeleteRowAction() -> UITableViewRowAction
    {
        let deleteLabel = NSLocalizedString("Delete", comment: "Azione elimina")
        let tv: UITableView? = tableView
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: deleteLabel)
            {
                (action, index) in
                tv!.dataSource?.tableView!(tv!,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: index)
        }
        
        return deleteAction
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return indexPath != tableView.indexPathForSelectedRow
    }
    
    //MARK: - Searching Result Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let posts = postArray
        let array: [Post]
        if searchController.searchBar.text!.isEmpty
        {
            array = postArray
        }
        else
        {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchController.searchBar.text!)
            array = posts.filter{searchPredicate.evaluateWithObject($0)}
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let segueId = segue.identifier
        {
            switch segueId
            {
                case "toBrowser2":
                    
                    if let webVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? WebViewController
                    {
                        if let cell = sender as? UITableViewCell
                        {
                            if let selectedIndex = self.tableView.indexPathForCell(cell)
                            {
                                let selectedPost = resultSearchController.active == true ?
                                    filteredTableData[selectedIndex.row] :
                                    postArray[selectedIndex.row]
                                
                                webVC.post = selectedPost
                                
                                resultSearchController.active = false
                            }
                        }
                    }
                    
                default:
                    break
            }
        }
    }

}
