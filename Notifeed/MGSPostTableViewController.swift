//
//  MGSPostTableViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 01/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import UIKit
import CoreData

class MGSPostTableViewController: UITableViewController, NSXMLParserDelegate, UISearchResultsUpdating
{
    var model: MGSDataModel?
    
    //Attributi inerenti Feeds e Posts
    var selectedFeed: MGSFeed?
    var postArray: [MGSPost] = []
    var post: MGSPost = MGSPost()
    
    var parser: NSXMLParser = NSXMLParser()
    
    //Attributi per la logica
    var isItemTag : Bool = false
    var selectedIndex : Int? = nil
    
    //Search
    var filteredTableData = [MGSPost]()
    var resultSearchController = UISearchController()
    
    override func viewDidAppear(animated: Bool)
    {
        self.navigationController?.setToolbarHidden(true, animated: false)
        //updateInterface()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "MGSFeedDeletedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "MGSNewFeedAddedNotification", object: nil)
        //startByExample()
        //Commentato per compilare
        //model = (UIApplication.sharedApplication().delegate as? AppDelegate)?.model
        updateInterface()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .Minimal
            
            self.tableView.tableHeaderView = controller.searchBar
            self.tableView.contentOffset = CGPointMake(0.0, 44.0)
            
            return controller
        })()

    }
    
    //MARK: - Funzioni di Diagnostica

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startByExample()
    {
        //let url: NSURL = NSURL(string: "http://www.xcoding.it/feed")!
        let url: NSURL = NSURL(string: "http://feeds.blogo.it/melablog/it")!
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        
        parser.parse()
    }
    
    //MARK: - Funzioni di Model
    
    func updateInterface()
    {
        var link: String
        var url: NSURL
        
        postArray = []
        
        if let feed = selectedFeed
        {
            url = NSURL(string: feed.link)!
            parser = NSXMLParser(contentsOfURL: url)!
            parser.delegate = self
            
            parser.parse()
        }
        
        tableView.reloadData()
    }
    
    // MARK: - NSXMLParser
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        post.eName = elementName
        if elementName == "item"
        {
            isItemTag = true
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        let data = string!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if(!data.isEmpty)
        {
            if post.eName == "title" && isItemTag
            {
                post.title += " " + data
            }
            else if post.eName == "description"
            {
                post.postDescription += data
            }
            else if post.eName == "link"
            {
                post.link = data
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "item"
        {
            let newPost: MGSPost = MGSPost()
            newPost.title = post.title
            newPost.postDescription = post.postDescription
            newPost.link = post.link
            self.postArray.append(newPost)
            post = MGSPost()
            isItemTag = false
        }
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
    
    //MARK: - Table view delegate

    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedIndex = indexPath.row;
        self.performSegueWithIdentifier("toDetailSegue", sender: nil)
    }
    
    //MARK: - Searching Result Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        //filteredTableData.removeAll(keepCapacity: false)
        let array: [MGSPost]
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toDetailSegue"
        {
            if let mvc = segue.destinationViewController as? UINavigationController
            {
                (mvc.topViewController as! MGSWebViewController).post = postArray[selectedIndex!]
                resultSearchController.active = false
            }
        }
    }
    

}
