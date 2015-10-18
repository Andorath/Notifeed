//
//  BannerViewController.swift
//  Notifeed
//
//  Created by Marco Salafia on 18/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class BannerViewController: UIViewController
{
    var contentController: UIViewController!
    
    override func viewDidLoad()
    {
        initContentController()
        super.viewDidLoad()
    }
    
    func initContentController()
    {
        let children = self.childViewControllers
        assert(!children.isEmpty)
        
        contentController = children[0]
    }
}
