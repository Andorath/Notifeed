//
//  MGSAddFeedTableViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 12/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import UIKit

class MGSAddFeedTableViewController: UITableViewController
{
    
    var model: MGSDataModel?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        model = (UIApplication.sharedApplication().delegate as? AppDelegate)?.model
        
        doneButton.enabled = false;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChangeNotification", name: UITextFieldTextDidChangeNotification, object: titleTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChangeNotification", name: UITextFieldTextDidChangeNotification, object: linkTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func addAction(sender: AnyObject)
    {
        var titleNoSpaces = titleTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var linkNoSpaces = linkTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if model!.alreadyExists(titleNoSpaces as String)
        {
            let alreadyExistAlert = UIAlertController(title: NSLocalizedString("Warning!", comment: "Titolo popup errore nome Feed"), message: NSLocalizedString("A Feed with this title already exists!", comment: "Messaggio popup errore Feed"), preferredStyle: UIAlertControllerStyle.Alert)
            alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione prescrizione"), style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alreadyExistAlert, animated: true, completion: nil)
        }
        else
        {
            
            var feed: MGSFeed = MGSFeed(title: titleNoSpaces as String, link: linkNoSpaces as String, creazione: NSDate())
            model?.addNewFeedToModel(feed)
        NSNotificationCenter.defaultCenter().postNotificationName("MGSNewFeedAddedNotification", object: nil)
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func handleTextFieldDidChangeNotification()
    {
        doneButton.enabled = titleTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).utf16.count >= 1 && linkTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).utf16.count >= 1
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
