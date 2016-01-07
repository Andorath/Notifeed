//
//  WebViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 24/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit
import SafariServices

class WebViewController: UIViewController, UIWebViewDelegate
{
    var activityViewController: UIActivityViewController?
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var auxiliaryBarButtonItem: UIBarButtonItem?
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var browserBackButton: UIBarButtonItem!
    @IBOutlet weak var browserForwardButton: UIBarButtonItem!
    @IBOutlet weak var safariViewButton: UIBarButtonItem!
    @IBOutlet weak var cleanButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var post: Post?
        {
        didSet
        {
            self.title = post!.title
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initActivityController()
        initWebViewLoading()
        let bottomOffset = self.tabBarController!.tabBar.frame.size.height + 44 //44 è la toolbar
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomOffset, right: 0)
        
        if #available(iOS 9.0, *)
        {
            safariViewButton.enabled = true
        }
        else
        {
            self.navigationItem.rightBarButtonItems?.removeFirst()
        }
        
        if traitCollection.horizontalSizeClass == .Regular
        {
            cleanButton.enabled = true
        }
        else
        {
            auxiliaryBarButtonItem = self.navigationItem.rightBarButtonItems?.removeLast()
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?)
    {
        if previousTraitCollection?.horizontalSizeClass == .Regular
        {
            auxiliaryBarButtonItem = self.navigationItem.rightBarButtonItems?.removeLast()
        }
        else if previousTraitCollection?.horizontalSizeClass == .Compact && traitCollection.horizontalSizeClass == .Regular
        {
            if let button = auxiliaryBarButtonItem
            {
                self.navigationItem.rightBarButtonItems?.append(button)
                cleanButton = button
                cleanButton.enabled = true
            }
        }
    }
    
    func initActivityController()
    {
        if let link = post?.link
        {
            let pub = NSLocalizedString("Shared with Notifeed - ", comment: "Pubblicità nell'activityController")
            let safariActivity = MGSOpenWithSafari()
            activityViewController = UIActivityViewController(activityItems: [pub, link], applicationActivities: [safariActivity])
            activityViewController?.excludedActivityTypes = [UIActivityTypeAssignToContact,
                UIActivityTypeSaveToCameraRoll,
                UIActivityTypeAirDrop,
                UIActivityTypePostToFlickr]
        }
    }
    
    func initWebViewLoading()
    {
        if Reachability.isConnectedToNetwork()
        {
            if let link = post?.link
            {
                if let URL = NSURL(string: link)
                {
                    let request = NSURLRequest(URL: URL)
                    webView.loadRequest(request)
                }
                else
                {
                    showInvalidURLAlert()
                }
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
                                                message: NSLocalizedString("Invalid URl found.", comment: "Messaggio alert url invalido"),
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Action invalid url alert"),
                                                style: .Default){
                                                    alert in
                                                    if let navController = self.navigationController
                                                    {
                                                        print("ereoto")
                                                        navController.popViewControllerAnimated(true)
                                                    
                                                    }
                                                    self.hideActivityIndicator()
                                                })
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showActivityIndicator()
    {
        spinner.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        spinner.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Web View Delegate
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        showActivityIndicator()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        hideActivityIndicator()
        
        browserBackButton.enabled = webView.canGoBack
        browserForwardButton.enabled = webView.canGoForward
        
    }
    
    //MARK: - Web Browsing
    
    @IBAction func goBack(sender: UIBarButtonItem)
    {
        webView.goBack()
    }
    
    @IBAction func goForward(sender: UIBarButtonItem)
    {
        webView.goForward()
    }
    
    @IBAction func refreshPage(sender: UIBarButtonItem)
    {
        if Reachability.isConnectedToNetwork()
        {
            webView.reload()
        }
        else
        {
            Reachability.showNoConnectionAlert(self, actionHandler: nil)
        }
    }
    
    //MARK: - Activity
    
    @IBAction func showActivityController(sender: UIBarButtonItem)
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            navigationController?.presentViewController(activityViewController!, animated: true, completion: nil)
        }
        else if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            let popup = UIPopoverController(contentViewController: activityViewController!)
            popup.presentPopoverFromBarButtonItem(actionButton, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
        }
        
    }
    
    // MARK: IBAction Utility
    @IBAction func cleanViewController(sender: AnyObject)
    {
        if let split = self.splitViewController
        {
            let count = split.viewControllers.count
            if let nav = split.viewControllers[count-1] as? UINavigationController
            {
                if nav.topViewController is WebViewController
                {
                    nav.setToolbarHidden(true, animated: true)
                    nav.setViewControllers([MGSEmptyDetailViewController(nibName: "MGSEmptyDetailViewController", bundle: nil)], animated: true)
                }
            }
        }
    }
    
    @available(iOS 9.0, *)
    @IBAction func safariViewAction(sender: AnyObject)
    {
        if let url = NSURL(string: post!.link)
        {
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            svc.delegate = self
            self.modalPresentationStyle = .FormSheet
            self.presentViewController(svc, animated: true, completion: nil)
        }
        else
        {
            showInvalidURLAlert()
        }
    }
    
}

@available(iOS 9.0, *)
extension WebViewController: SFSafariViewControllerDelegate
{
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
