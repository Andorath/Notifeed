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
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var browserBackButton: UIBarButtonItem!
    @IBOutlet weak var browserForwardButton: UIBarButtonItem!
    @IBOutlet weak var safariViewButton: UIBarButtonItem!
    @IBOutlet weak var cleanButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var post: Post = Post()
        {
        didSet
        {
            self.title = post.title
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        initActivityController()
        initWebViewLoading()
        
        if #available(iOS 9.0, *)
        {
            safariViewButton.enabled = true
        }
        else
        {
            self.navigationItem.rightBarButtonItems?.removeFirst()
        }
    }
    
    func initActivityController()
    {
        let pub = NSLocalizedString("Shared with Notifeed - ", comment: "Pubblicità nell'activityController")
        let safariActivity = MGSOpenWithSafari()
        activityViewController = UIActivityViewController(activityItems: [pub, post.link], applicationActivities: [safariActivity])
        activityViewController?.excludedActivityTypes = [UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAirDrop,
            UIActivityTypePostToFlickr]
    }
    
    func initWebViewLoading()
    {
        if let URL = NSURL(string: post.link)
        {
            let request = NSURLRequest(URL: URL)
            webView.loadRequest(request)
        }
        else
        {
            showInvalidURLAlert()
        }
    }
    
    func showInvalidURLAlert()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Warning!", comment: "Attenzione alert url invalido"),
                                                message: NSLocalizedString("Invalid URL format! Insert a correct one.", comment: "Messaggio alert url invalido"),
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
    
    override func viewWillAppear(animated: Bool)
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad && traitCollection.horizontalSizeClass == .Regular
        {
            cleanButton.enabled = true
        }
        else
        {
            self.navigationItem.rightBarButtonItems?.removeLast()
        }
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
        browserForwardButton.enabled = browserForwardButton.enabled
        
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
        webView.reload()
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
        if let url = NSURL(string: post.link)
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
