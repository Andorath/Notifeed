//
//  WebViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 24/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate
{
    var activityViewController: UIActivityViewController?
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var browserBackButton: UIBarButtonItem!
    @IBOutlet weak var browserForwardButton: UIBarButtonItem!
    
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
        
        if let URL = NSURL(string: post.link)
        {
            let request = NSURLRequest(URL: URL)
            webView.loadRequest(request)
        }
        
        //TODO: gestire un errore
    }
    
    func initActivityController()
    {
        let pub = NSLocalizedString("Shared with Notifeed -", comment: "Pubblicità nell'activityController")
        let safariActivity = MGSOpenWithSafari()
        activityViewController = UIActivityViewController(activityItems: [pub, post.link], applicationActivities: [safariActivity])
        activityViewController?.excludedActivityTypes = [UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAirDrop,
            UIActivityTypePostToFlickr]
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

}
