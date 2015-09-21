//
//  MGSWebViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 03/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import UIKit

class MGSWebViewController: UIViewController, UIWebViewDelegate
{
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var browserBackButton: UIBarButtonItem!
    @IBOutlet weak var browserForwardButton: UIBarButtonItem!
    
    var popup: UIPopoverController?
    
    var post: MGSPost = MGSPost()
    {
        didSet
        {
            self.title = post.title
        }
            
    }
    
    var activityViewController: UIActivityViewController?
    
    override func viewDidAppear(animated: Bool)
    {
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        initActivityController()
        
        let URL = NSURL(string: post.link)
        let request = NSURLRequest(URL: URL!)
        webView.loadRequest(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Web View Delegate
    
    /*func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked
        {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        return true
    }*/
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        spinner.stopAnimating()
        
        if webView.canGoBack
        {
            browserBackButton.enabled = true
        }
        else
        {
            browserBackButton.enabled = false
        }
        
        if webView.canGoForward
        {
            browserForwardButton.enabled = true
        }
        else
        {
            browserForwardButton.enabled = false
        }
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
    
    func initActivityController()
    {
        let pub = NSLocalizedString("- Shared with Notifeed -", comment: "Pubblicità nell'activityController")
        let safariActivity = MGSOpenWithSafari()
        activityViewController = UIActivityViewController(activityItems: [pub, post.link], applicationActivities: [safariActivity])
        activityViewController?.excludedActivityTypes = [
                UIActivityTypeAssignToContact,
                UIActivityTypeSaveToCameraRoll,
                UIActivityTypeAirDrop,
                UIActivityTypePostToFlickr
            ]
    }
    
    @IBAction func showActivityController(sender: UIBarButtonItem)
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            navigationController?.presentViewController(activityViewController!, animated: true, completion: nil)
        }
        else if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            popup = UIPopoverController(contentViewController: activityViewController!)
            popup?.presentPopoverFromBarButtonItem(actionButton, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
