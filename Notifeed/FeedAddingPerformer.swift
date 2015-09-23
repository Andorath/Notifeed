//
//  FeedAddingPerformer.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import UIKit

protocol FeedAddingDelegate
{
    var delegator: FeedViewController? {get}
    var feed: Feed? {get set}
    var alertController: UIAlertController? {get}
    
    init(delegator: FeedViewController)
    
    func showAlertController()
}

class FeedAddingPerformer: NSObject, FeedAddingDelegate, UITextFieldDelegate
{
    var delegator: FeedViewController?
    var feed: Feed?
    
    var alertController: UIAlertController?
    var saveAction: UIAlertAction?
    
    required init(delegator: FeedViewController)
    {
        super.init()
        self.delegator = delegator
        self.feed = nil
        initAlertController()
    }
    
    func initAlertController()
    {
        alertController = UIAlertController(title: NSLocalizedString("New Feed", comment: "Titolo popup creazione feed"),
                                          message: NSLocalizedString("Insert the Title and the Link for the new Feed.", comment: "Messaggio creazione nuovo feed"),
                                          preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(titleTextFieldConfigurationHandler)
        alertController!.addTextFieldWithConfigurationHandler(urlTextFieldConfigurationHandler)
        
        // TODO: Verificare che funzioni il dismiss
        alertController!.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   comment: "Annulla popup creazione nuovo feed"),
                                                                   style: UIAlertActionStyle.Default) {
                                                                       action in
                                                                       self.alertController!.dismissViewControllerAnimated(true,completion: nil)
                                                                    })
        
        let addFeed = getAddAction()
        alertController!.addAction(addFeed)
    }
    
    func titleTextFieldConfigurationHandler(textField: UITextField)
    {
        textField.placeholder = NSLocalizedString("Title", comment: "Placeholder del titolo nuovo feed")
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
        textField.placeholder = NSLocalizedString("Link url of the rss", comment: "Placeholder del link nuovo feed")
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "handleTextFieldTextDidChangeNotification:",
                                                         name: UITextFieldTextDidChangeNotification,
                                                         object: textField)
    }
    
    func getAddAction() -> UIAlertAction
    {
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Azione Aggiungi popup creazione nuova prescrizione"),
            style: .Default, handler: addActionHandler)
        
        addAction.enabled = false
        saveAction = addAction
        return addAction
    }
    
    func addActionHandler(action: UIAlertAction)
    {
        if let titleNoSpaces = alertController!.textFields?[0].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        {
            if titleNoSpaces.isEmpty
            {
                showEmptyTitleAlert()
            }
            else if FeedModel.getSharedInstance().alreadyExistsFeedWithTitle(titleNoSpaces)
            {
                showAlreadyExistsAlert()
            }
            else
            {
                if let linkNoSpaces = alertController!.textFields?[1].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                {
                    let feed = Feed(title: titleNoSpaces, link: linkNoSpaces, creazione: NSDate())
                    FeedModel.getSharedInstance().addFeed(feed)
                    delegator!.updateInterfaceByCell()
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
                                               handler: { action in
                                                          delegator?.dismissViewControllerAnimated(true, completion: nil)
                                                        }))
        
        delegator!.presentViewController(emptyNameAlert, animated: true, completion: nil)
    }
    
    func showAlreadyExistsAlert()
    {
        let alreadyExistAlert = UIAlertController(title: NSLocalizedString("Warning!", comment: "Titolo popup errore nome Feed"),
                                                  message: NSLocalizedString("A Feed with this title already exists!", comment: "Messaggio popup errore Feed"),
                                                  preferredStyle: UIAlertControllerStyle.Alert)
        
        alreadyExistAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok popup errore creazione feed"),
                                                  style: UIAlertActionStyle.Default,
                                                  handler: { action in
                                                             delegator?.dismissViewControllerAnimated(true, completion: nil)
                                                           }))
        
        delegator!.presentViewController(alreadyExistAlert, animated: true, completion: nil)
    }
    
    func handleTextFieldTextDidChangeNotification (notification: NSNotification)
    {
        if let _ = notification.object as? UITextField
        {
            saveAction!.enabled = alertController!.textFields?[0].text!.utf16.count >= 1 &&
                                  alertController!.textFields?[1].text!.utf16.count >= 1
        }
    }
    
    func showAlertController()
    {
        if delegator!.editing
        {
            delegator!.setEditing(false, animated: true)
        }
        
        delegator!.presentViewController(alertController!, animated: true, completion: nil)
    }
    
}