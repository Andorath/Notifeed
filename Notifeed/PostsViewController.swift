//
//  PostsViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class PostsViewController: UITableViewController, UISearchResultsUpdating
{
    var selectedFeed: Feed? {
        didSet {
            self.navigationItem.title = selectedFeed?.title
        }
    }
    var postArray: [Post] = []
    
    var filteredTableData = [Post]()
    var resultSearchController = UISearchController()
    
    var originalIndexPath: NSIndexPath?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        resultSearchController = getResultSearchController()
        showActivityIndicator()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        scanSelectedFeed()
        hideActivityIndicator()
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
            do
            {
                try postArray = FeedParser().parseLink(feed.link)
            }
            catch FeedParserError.InvalidURL
            {
                showInvalidURLAlert()
            }
            catch
            {}
            
            updateInterfaceBySections()
        }
    }
    
    func showInvalidURLAlert()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Attenzione alert url invalido"),
                                                message: NSLocalizedString("Unable to connect! Check the status of the URL or be sure if the URL is an RSS feed URL.", comment: "Messaggio alert url invalido"),
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Action invalid url alert"),
                                                style: .Default){
                                                                    alert in
                                                                    if let navController = self.navigationController
                                                                    {
                                                                        navController.popViewControllerAnimated(true)
                                                                    }
                                                                })
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateInterfaceBySections()
    {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    func showActivityIndicator()
    {
        let contentView = PKHUDSystemActivityIndicatorView()
        PKHUD.sharedHUD.contentView = contentView
        PKHUD.sharedHUD.show()
    }
    
    func hideActivityIndicator()
    {
        PKHUD.sharedHUD.hide()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source e Delegate

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
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let oip = originalIndexPath
        {
            tableView.selectRowAtIndexPath(oip, animated: true, scrollPosition: .Top)
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let archiveAction = getArchiveRowAction()
        
        return [archiveAction]
    }
    
    func getArchiveRowAction() -> UITableViewRowAction
    {
        let editLabel = NSLocalizedString("Archive", comment: "Azione archivia")
        let editAction = UITableViewRowAction(style: .Normal,
                                              title: editLabel,
                                              handler: archiveActionHandler)
        
        editAction.backgroundColor = UIColor(red: 255.0/255.0, green: 151.0/255.0, blue: 12.0/255.0, alpha: 1)
        
        return editAction
    }
    
    func archiveActionHandler(action: UITableViewRowAction, index: NSIndexPath)
    {
        if self.resultSearchController.active
        {
            archivePost(filteredTableData[index.row])
        }
        else
        {
            archivePost(postArray[index.row])
        }
        
        self.setEditing(false, animated: true)
    }
    
    func archivePost(post: Post)
    {
        if FeedModel.getSharedInstance().alreadyExistsPost(post)
        {
            showAlreadyArchivedAlert()
        }
        else
        {
            FeedModel.getSharedInstance().addPost(post)
            showCheckMarkOverlay()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "MGSArchivedNotification", object: nil))
        }
        
    }
    
    func showAlreadyArchivedAlert()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Titolo post già archiviato"),
                                                message: NSLocalizedString("This post has been already archived.", comment: "Messaggio post già archiviato"),
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok action post già archiviato"),
                                                style: UIAlertActionStyle.Default,
                                                handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return indexPath != tableView.indexPathForSelectedRow
    }
    
    // MARK: - Animazioni

    func showCheckMarkOverlay()
    {
        let contentView = PKHUDImageView(image: PKHUDAssets.checkmarkImage)
        PKHUD.sharedHUD.contentView = contentView
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 0.5)
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
        if let segueId = segue.identifier
        {
            switch segueId
            {
                case "toBrowser":
                
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





