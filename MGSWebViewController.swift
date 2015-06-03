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
    
    var post: MGSPost = MGSPost()
    {
        didSet
        {
            self.title = post.title
        }
            
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view        
        
        var URL = NSURL(string: post.link)
        var request = NSURLRequest(URL: URL!)
        webView.loadRequest(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Web View Delegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked
        {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        spinner.stopAnimating()
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
