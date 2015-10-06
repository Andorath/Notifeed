//
//  FeedTableViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController, UISearchResultsUpdating
{
    var filteredTableData = [Feed]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        resultSearchController = getResultSearchController()
        setUserInterfaceComponents()
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
    
    func setUserInterfaceComponents()
    {
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        checkEditButton()
    }
    
    func checkEditButton()
    {
        if tableView.editing && tableView.numberOfRowsInSection(0) == 0
        {
            setEditing(false, animated: true)
        }
        self.navigationItem.leftBarButtonItem?.enabled = tableView.numberOfRowsInSection(0) != 0
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    func updateInterfaceByCell()
    {
        tableView.reloadData()
        filteredTableData = FeedModel.getSharedInstance().getFeeds()
        checkEditButton()
    }
    
    func updateInterfaceBySections()
    {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        filteredTableData = FeedModel.getSharedInstance().getFeeds()
        checkEditButton()
    }

    @IBAction func addFeedAction(sender: AnyObject)
    {
        FeedAddingPerformer(delegator: self).showAlertController()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

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
                return FeedModel.getSharedInstance().getFeeds().count
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
            cell.detailTextLabel?.text = filteredTableData[indexPath.row].link
        }
        else
        {
            let feed = FeedModel.getSharedInstance().getFeeds()[indexPath.row]
            
            cell.textLabel?.text = feed.title
            cell.detailTextLabel?.text = feed.link
            
            return cell
        }

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            if resultSearchController.active
            {
                try! FeedModel.getSharedInstance().deleteFeed(filteredTableData[indexPath.row])
                filteredTableData.removeAtIndex(indexPath.row)
            }
            else
            {
                try! FeedModel.getSharedInstance().deleteFeedAtIndex(indexPath.row)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            checkEditButton()
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let editAction = getEditRowAction()
        let deleteAction = getDeleteRowAction()
        
        return [deleteAction, editAction]
    }
    
    func getEditRowAction() -> UITableViewRowAction
    {
        let editLabel = NSLocalizedString("Edit", comment: "Azione modifica")
        let editAction = UITableViewRowAction(style: .Normal,
                                              title: editLabel,
                                              handler: editHandler)

        editAction.backgroundColor = UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 102.0/255.0, alpha: 1)
        
        return editAction
    }
    
    func editHandler(action: UITableViewRowAction, index: NSIndexPath)
    {
        var feed: Feed
        
        /* Il FeedEditingPerformer(delegator: self, feed: feed).performEditingProcedure() è
        volutamente ripetuto due volte all'interno dei branch del IF per una questione di
        animazioni più piacevoli */
        
        if resultSearchController.active
        {
            feed = filteredTableData[index.row]
            FeedEditingPerformer(delegator: self, feed: feed).performEditingProcedure()
            resultSearchController.active = false
        }
        else
        {
            feed = FeedModel.getSharedInstance().getFeeds()[index.row]
            FeedEditingPerformer(delegator: self, feed: feed).performEditingProcedure()
        }
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
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if resultSearchController.active
        {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        FeedModel.getSharedInstance().moveFeedFromIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    //MARK: - Searching Result Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let feeds = FeedModel.getSharedInstance().getFeeds()
        let array: [Feed]
        if searchController.searchBar.text!.isEmpty
        {
            array = FeedModel.getSharedInstance().getFeeds()
        }
        else
        {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchController.searchBar.text!)
            array = feeds.filter{searchPredicate.evaluateWithObject($0)}
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }

    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
        if Reachability.isConnectedToNetwork() { return true }
        else
        {
            Reachability.showNoConnectionAlert(self, actionHandler: nil)
            if let selectedIndex = self.tableView.indexPathForSelectedRow
            {
                self.tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
            }
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let segueId = segue.identifier
        {
            switch segueId
            {
                case "toPosts":
                
                    if let destinationPostController = segue.destinationViewController as? PostsViewController
                    {
                        if let cell = sender as? UITableViewCell
                        {
                            if let selectedIndex = self.tableView.indexPathForCell(cell)
                            {
                                let selectedFeed = resultSearchController.active == true ?
                                                   filteredTableData[selectedIndex.row] :
                                                   FeedModel.getSharedInstance().getFeeds()[selectedIndex.row]
                                
                                destinationPostController.selectedFeed = selectedFeed
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
