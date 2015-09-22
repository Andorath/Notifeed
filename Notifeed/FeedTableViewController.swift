//
//  FeedTableViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, UISearchResultsUpdating
{
    var feedAdderDelegate: FeedAddingDelegate?
    
    //Search
    var filteredTableData = [Feed]()
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

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateInterfaceByCell()
    {
        tableView.reloadData()
        filteredTableData = FeedModel.getSharedInstance().getFeeds()
    }
    
    func updateInterfaceBySections()
    {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        filteredTableData = FeedModel.getSharedInstance().getFeeds()
    }

    @IBAction func addFeedAction(sender: AnyObject)
    {
        feedAdderDelegate = FeedAddingPerformer(delegator: self)
        feedAdderDelegate!.showAlertController()
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

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            try! FeedModel.getSharedInstance().deleteFeedAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
                                              title: editLabel){
                                                    (action, index) in
                                                    //TODO: completare la modifica implementando l'editor
                                                    print("Modifica!")
                                                    
                                                }
        editAction.backgroundColor = UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 102.0/255.0, alpha: 1)
        
        return editAction
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
