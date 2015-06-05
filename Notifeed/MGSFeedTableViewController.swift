//
//  MGSFeedTableViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 04/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import UIKit
import CoreData

class MGSFeedTableViewController: UITableViewController, UITextFieldDelegate
{
    
    var model: MGSDataModel? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.model
    
    //Attributi per la logica
    weak var alertView: UIAlertController?
    {
        didSet {
            textFields = alertView?.textFields
        }
    }
    var textFields: [AnyObject]?
    weak var AddAlertSaveAction: UIAlertAction?
    
    
    //METODI

    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "MGSNewFeedAddedNotification", object: nil)
        
        super.viewDidLoad()
    }
    
    //MARK: - Interface Builder Actions
    
    @IBAction func addNewFeed(sender: UIBarButtonItem)
    {
        var textFields: [AnyObject]? = [AnyObject]()
        
        var alertView = UIAlertController(title: NSLocalizedString("New Feed", comment: "Titolo popup creazione feed"),
            message: NSLocalizedString("Insert the Title and the Link for the new Feed.", comment: "Messaggio creazione nuovo feed"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        //Inserisco la textField Titolo
        alertView.addTextFieldWithConfigurationHandler()
            {   textField in
            
                textField.placeholder = NSLocalizedString("Title", comment: "Placeholder del titolo nuovo feed")
                textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
                textField.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:",    name: UITextFieldTextDidChangeNotification, object: textField)
                textFields?.append(textField)
            }
        
        //Inserisco la textField Link
        alertView.addTextFieldWithConfigurationHandler()
            {   textField in
            
                textField.placeholder = NSLocalizedString("Link url of the rss", comment: "Placeholder del link nuovo feed")
                textField.autocapitalizationType = UITextAutocapitalizationType.None
                textField.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:",    name: UITextFieldTextDidChangeNotification, object: textField)
                textFields?.append(textField)
            }
        
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Azione Aggiungi popup creazione nuova prescrizione"), style: UIAlertActionStyle.Default)
            {  [weak self] alert in
            
            var titleNoSpaces: NSString = ((textFields![0] as! UITextField).text as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            var linkNoSpaces: NSString = ((textFields![1] as! UITextField).text as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if self!.model!.alreadyExists(titleNoSpaces as String)
            {
                let alreadyExistAlert = UIAlertController(title: NSLocalizedString("Warning!", comment: "Titolo popup errore nome Feed"), message: NSLocalizedString("A Feed with this title already exists!", comment: "Messaggio popup errore Feed"), preferredStyle: UIAlertControllerStyle.Alert)
                alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"), style: UIAlertActionStyle.Default, handler: nil))
                self!.presentViewController(alreadyExistAlert, animated: true, completion: nil)
            }
            else
            {
                
                var feed: MGSFeed = MGSFeed(title: titleNoSpaces as String, link: linkNoSpaces as String, creazione: NSDate())
                self?.model?.addNewFeedToModel(feed)
                self?.updateInterface()
                
            }
            
        }
        
        addAction.enabled = false
        
        self.alertView = alertView
        AddAlertSaveAction = addAction
        
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Annulla popup creazione nuovo feed"),
            style: UIAlertActionStyle.Default,
            handler: nil))
        
        alertView.addAction(addAction)
        
        presentViewController(alertView, animated: true, completion: nil)
        
    }
    
    //MARK: - Funzioni di diagnostica

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Funzioni ausiliarie
    
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        var textField = notification.object as! UITextField
        AddAlertSaveAction!.enabled = (count((textFields![0] as! UITextField).text.utf16) >= 1) && (count((textFields![1] as! UITextField).text.utf16) >= 1)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return model!.getFeedModel()!.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        if let feed = model!.getFeedModel()?[indexPath.row]
        {
            cell.textLabel?.text = feed.title
        }
        
        if let feed = model!.getFeedModel()?[indexPath.row]
        {
            cell.detailTextLabel?.text = feed.link
        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            model?.deleteFeedFromModel(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }   
    }
    

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
    
    // MARK: - Load from Model and refresh data
    
    func updateInterface()
    {
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
