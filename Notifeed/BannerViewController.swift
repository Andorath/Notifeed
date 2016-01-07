//
//  BannerViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 18/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit
import iAd

class BannerViewManager: NSObject, ADBannerViewDelegate
{
    static var sharedInstance = BannerViewManager()
    
    var bannerView: ADBannerView!
    var bannerViewControllers: Set<BannerViewController>!
    
    private override init()
    {
        super.init()
        
        if ADBannerView.instancesRespondToSelector("initWithAdType:")
        {
            bannerView = ADBannerView(adType: .Banner)
        }
        else
        {
            bannerView = ADBannerView()
        }
        
        bannerView.delegate = self
        bannerViewControllers = []
    }
    
    func addBannerViewController(controller: BannerViewController)
    {
        bannerViewControllers.insert(controller)
    }
    
    func removeBannerViewController(controller: BannerViewController)
    {
        bannerViewControllers.remove(controller)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!)
    {
        NSLog("bannerViewDidLoad")

        for bvc in bannerViewControllers
        {
            bvc.updateLayout()
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
    {
        NSLog("didFailToReceiveAdWithError: \(error)")
        
        for bvc in bannerViewControllers
        {
            bvc.updateLayout()
        }
    }
}

class BannerViewController: UIViewController
{
    var contentController: UIViewController!
    
    deinit { BannerViewManager.sharedInstance.removeBannerViewController(self) }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        BannerViewManager.sharedInstance.addBannerViewController(self)
        initContentController()
    }
    
    func initContentController()
    {
        let children = self.childViewControllers
        assert(!children.isEmpty)
        
        contentController = children[0]
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return self.contentController.preferredInterfaceOrientationForPresentation()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        var contentFrame = self.view.bounds, bannerFrame = CGRectZero
        let bannerView = BannerViewManager.sharedInstance.bannerView
        
        bannerFrame.size = bannerView.sizeThatFits(contentFrame.size)
        
        if bannerView.bannerLoaded
        {
            contentFrame.size.height -= bannerFrame.size.height
            bannerFrame.origin.y = contentFrame.size.height - self.tabBarController!.tabBar.frame.size.height
        }
        else
        {
            bannerFrame.origin.y = contentFrame.size.height - self.tabBarController!.tabBar.frame.size.height
        }
        
        self.contentController.view.frame = contentFrame
        
        if self.isViewLoaded() && self.view.window != nil
        {
            self.view.addSubview(bannerView)
            bannerView.frame = bannerFrame
            self.view.layoutSubviews()
        }
    }
    
    func updateLayout()
    {
        UIView.animateWithDuration(0.25) {
            [weak self] in
            self!.view.setNeedsLayout()
            self!.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.view.addSubview(BannerViewManager.sharedInstance.bannerView)
    }
    
}
