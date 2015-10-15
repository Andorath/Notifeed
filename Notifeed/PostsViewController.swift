//
//  PostsViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit
import iAd

class PostsViewController: UITableViewController, UISearchResultsUpdating, ADBannerViewDelegate
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
        initInterfaceComponent()
        showActivityIndicator()
        setStoreProperties()
    }
    
    func initInterfaceComponent()
    {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "scanSelectedFeed", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.backgroundColor = UIColor.whiteColor()
        if let _ = refreshControl { self.tableView.addSubview(refreshControl!) }
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
        if Reachability.isConnectedToNetwork()
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
                catch FeedParserError.UnknownFeedFormat
                {
                    showUnknownFeedFormatAlert()
                }
                catch FeedParserError.UnableToConnect
                {
                    showUnableToConnectAlert()
                }
                catch
                {}
                
                updateInterfaceBySections()
                refreshControl?.endRefreshing()
            }
        }
        else
        {
            Reachability.showNoConnectionAlert(self) {
                [unowned self] action in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func showInvalidURLAlert()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Attenzione alert url invalido"),
                                                message: NSLocalizedString("Unable to connect! Check the status of the URL.", comment: "Messaggio alert url invalido"),
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
    
    func showUnknownFeedFormatAlert()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Attenzione alert formato invalido"),
                                                                         message: NSLocalizedString("Format of feed set for \(selectedFeed!.title) is not suported! Notifeed can read only RSS and Atom format.", comment: "Messaggio alert url invalido"),
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
    
    func showUnableToConnectAlert()
    {
        
        let alertController = UIAlertController(title: NSLocalizedString("Error!", comment: "Errore unable to connect"),
                                                message: NSLocalizedString("Unable to connect to the link. Check the URL status, your internet connection or check if you have inserted an URL with the right format.", comment: "Messsaggio unable to connect"),
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
    
    // MARK: - Metodi di Store e Purchaing
    
    func setStoreProperties()
    {
        self.canDisplayBannerAds = NotifeedStore.sharedInstance.canShowiAd()
    }
    
    // MARK: -

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
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        if self.resultSearchController.active
        {
            let post = filteredTableData[indexPath.row]
            cell.textLabel?.text = post.title
            if let date = post.published
            {
                cell.detailTextLabel?.text = formatter.stringFromDate(date)
            }
        }
        else
        {
            let post = postArray[indexPath.row]
            cell.textLabel?.text = post.title
            if let date = post.published
            {
                cell.detailTextLabel?.text = formatter.stringFromDate(date)
            }
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
        let contentView = PKHUDTitleView(title: NSLocalizedString("Archived", comment: "Archiviato!"),
            image: PKHUDAssets.checkmarkImage)
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





