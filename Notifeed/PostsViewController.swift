//
//  PostsViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit
import SafariServices

class PostsViewController: UITableViewController, NSXMLParserDelegate, UISearchResultsUpdating
{
    var selectedFeed: Feed? {
        didSet {
            self.navigationItem.title = selectedFeed?.title
        }
    }
    var postArray: [Post] = []
    
    var filteredTableData = [Post]()
    var resultSearchController = UISearchController()

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
            postArray = FeedParser().parseLink(feed.link)
            if postArray.isEmpty
            {
                showInvalidURLAlert()
            }
            updateInterfaceBySections()
        }
    }
    
    func showInvalidURLAlert()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Attenzione alert url invalido"),
            message: NSLocalizedString("Invalid URL! Please insert a valid URL for an RSS Feed.", comment: "Messaggio alert url invalido"),
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
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let archiveAction = getArchiveRowAction()
        
        return [archiveAction]
    }
    
    func getArchiveRowAction() -> UITableViewRowAction
    {
        let editLabel = NSLocalizedString("Archive", comment: "Azione archivia")
        let editAction = UITableViewRowAction(style: .Normal,
                                              title: editLabel){
                                              (action, index) in
                                              self.showCheckMarkOverlay()
                                                self.setEditing(false, animated: true)
                                      }
        editAction.backgroundColor = UIColor(red: 255.0/255.0, green: 151.0/255.0, blue: 12.0/255.0, alpha: 1)
        
        return editAction
    }
    
    // MARK: - Animazioni
    
    func showCheckMarkOverlay()
    {
        let contentView = PKHUDImageView(image: PKHUDAssets.checkmarkImage)
        PKHUD.sharedHUD.contentView = contentView
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 1)
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





