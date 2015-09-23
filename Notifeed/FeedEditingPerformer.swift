//
//  FeedEditingPerformer.swift
//  Notifeed
//
//  Created by Marco Salafia on 23/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

protocol FeedEditingDelegate
{
    var delegator: FeedViewController? {get}
    var feed: Feed? {get set}
    
    init(delegator: FeedViewController, feed: Feed)
    
    func performEditingProcedure()
}

class FeedEditingPerformer: NSObject, FeedEditingDelegate, UITextFieldDelegate
{
    var delegator: FeedViewController?
    var feed: Feed?
    
    var alertController: UIAlertController?
    var editAction: UIAlertAction?
    
    required init(delegator: FeedViewController, feed: Feed)
    {
        super.init()
        self.delegator = delegator
        self.feed = feed
        initAlertController()
    }
    
    func initAlertController()
    {
        alertController = UIAlertController(title: NSLocalizedString("Edit the name of the Feed",
                                                                     comment: "Titolo popup modifica nome feed"),
                                            message: NSLocalizedString("Change the name of the Feed",
                                                                       comment: "Messaggio vuoto popup modifica nome Feed"),
                                            preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(titleTextFieldConfigurationHandler)
        alertController!.addTextFieldWithConfigurationHandler(urlTextFieldConfigurationHandler)
        
        alertController!.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Annulla popup modifica feed"),
                                                 style: UIAlertActionStyle.Cancel,
                                                 handler: nil))
        
        let editFeed = getEditAction()
        alertController!.addAction(editFeed)
    }
    
    func titleTextFieldConfigurationHandler(textField: UITextField)
    {
        textField.text = feed?.title
        textField.placeholder = NSLocalizedString("Title", comment: "Placeholder del titolo modifica feed")
        textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "handleTextFieldTextDidChangeNotification:",
                                                         name: UITextFieldTextDidChangeNotification,
                                                         object: textField)
    }
    
    func urlTextFieldConfigurationHandler(textField: UITextField)
    {
        textField.text = feed?.link
        textField.placeholder = NSLocalizedString("Link url of the rss", comment: "Placeholder del link modifica feed")
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "handleTextFieldTextDidChangeNotification:",
                                                         name: UITextFieldTextDidChangeNotification,
                                                         object: textField)
    }
    
    func getEditAction() -> UIAlertAction
    {
        let addAction = UIAlertAction(title: NSLocalizedString("Edit", comment: "Azione Aggiungi popup creazione nuova prescrizione"),
            style: .Default, handler: editActionHandler)
        
        addAction.enabled = false
        editAction = addAction
        return addAction
    }
    
    func editActionHandler(action: UIAlertAction)
    {
        if let titleNoSpaces = alertController!.textFields?[0].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        {
            if titleNoSpaces.isEmpty
            {
                showEmptyTitleAlert()
            }
            else
            {
                if let linkNoSpaces = alertController!.textFields?[1].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                {
                    
                    let newFeed = Feed(title: titleNoSpaces, link: linkNoSpaces, creazione: NSDate())
                    FeedModel.getSharedInstance().editFeed(feed!, withNewFeed: newFeed)
                    delegator!.updateInterfaceBySections()
                }
            }
            
        }
    }
    
    func showEmptyTitleAlert()
    {
        let emptyNameAlert = UIAlertController(title: NSLocalizedString("Warning!", comment: "Titolo popup errore titolo Feed vuoto"),
                                               message: NSLocalizedString("You can't create a feed with an empty title",
                comment: "Messaggio popup errore prescrizione"),
                                               preferredStyle: UIAlertControllerStyle.Alert)
        
        emptyNameAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione feed"),
                                               style: UIAlertActionStyle.Default,
                                               handler: nil))
        
        delegator!.presentViewController(emptyNameAlert, animated: true, completion: nil)
    }
    
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        if let _ = notification.object as? UITextField
        {
            editAction!.enabled = alertController!.textFields?[0].text!.utf16.count >= 1 &&
                alertController!.textFields?[1].text!.utf16.count >= 1
        }
    }
    
    func performEditingProcedure()
    {
        delegator?.presentViewController(alertController!, animated: true, completion: nil)
    }
}