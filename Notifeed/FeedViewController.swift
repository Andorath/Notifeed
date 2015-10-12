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
    
    let userDefaults = NSUserDefaults(suiteName: "group.notifeedcontainer")
    var favoriteFeed : Feed? {
        get {
            guard let title = userDefaults?.valueForKey("favoriteFeed") as? String else
            {
                return nil
            }
            
            return FeedModel.getSharedInstance().getFeedWithTitle(title)
        }
        
        set {
            let title = newValue?.title
            userDefaults?.setValue(title, forKey: "favoriteFeed")
            userDefaults?.synchronize()
        }
    }
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FeedCell
        
        let currentFeed: Feed
        
        if self.resultSearchController.active
        {
            currentFeed = filteredTableData[indexPath.row]
            cell.titleLabel.text = currentFeed.title
            cell.linkLabel.text = currentFeed.link
        }
        else
        {
            currentFeed = FeedModel.getSharedInstance().getFeeds()[indexPath.row]
            
            cell.titleLabel.text = currentFeed.title
            cell.linkLabel.text = currentFeed.link
        }
        
        cell.favoriteIcon.image = favoriteFeed?.title == currentFeed.title ?
                                  UIImage(named: "FavoriteFeed.png") : nil

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            if resultSearchController.active
            {
                if let fav = favoriteFeed
                {
                    if fav.title == filteredTableData[indexPath.row].title { favoriteFeed = nil }
                }
                try! FeedModel.getSharedInstance().deleteFeed(filteredTableData[indexPath.row])
                filteredTableData.removeAtIndex(indexPath.row)
            }
            else
            {
                if let fav = favoriteFeed
                {
                    if fav.title == FeedModel.getSharedInstance().getFeeds()[indexPath.row].title { favoriteFeed = nil }
                }
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
        let menuAction = getMenuAction()
        
        return [deleteAction, editAction, menuAction]
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
    
    func getMenuAction() -> UITableViewRowAction
    {
        func showMenuSheet(action: UITableViewRowAction, indexPath: NSIndexPath)
        {
            func getFavoriteFeedActionForFeedAtIndex() -> UIAlertAction
            {
                let currentFeed = self.resultSearchController.active ?
                                  self.filteredTableData[indexPath.row] :
                                  FeedModel.getSharedInstance().getFeeds()[indexPath.row]
                
                if currentFeed.title == favoriteFeed?.title
                {
                    let unfavoriteAction = UIAlertAction(title: NSLocalizedString("Remove this Feed As Favorite", comment: "Comando rimuovi Feed"),
                                                        style: UIAlertActionStyle.Destructive) {
                                                            [weak self] action in
                                                            self?.favoriteFeed = nil
                                                            self?.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
                                                    }
                    
                    return unfavoriteAction
                }
                else
                {
                    let favoriteAction = UIAlertAction(title: NSLocalizedString("Set this Feed as Favorite", comment: "Comando imposta preferito"),
                        style: .Default) {
                            [weak self] action in
                            self?.favoriteFeed = currentFeed
                            self?.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
                    }
                    
                    return favoriteAction
                }
            }
            
            let menuSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            menuSheet.addAction(getFavoriteFeedActionForFeedAtIndex())
            
            menuSheet.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: "Comando annulla menu"),
                                              style: UIAlertActionStyle.Cancel,
                                              handler: nil))
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FeedCell
            menuSheet.popoverPresentationController?.sourceView = cell.titleLabel
            menuSheet.popoverPresentationController?.permittedArrowDirections = .Down
            
            
            self.tableView.setEditing(false, animated: true)
            
            self.presentViewController(menuSheet, animated: true, completion: nil)
        }
        
        let menuAction = UITableViewRowAction(style: .Normal, title: "       ", handler: showMenuSheet)
        menuAction.backgroundColor = UIColor(patternImage: UIImage(named: "MenuAction.png")!)
        
        return menuAction
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
