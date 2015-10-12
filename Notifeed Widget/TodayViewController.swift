//
//  TodayViewController.swift
//  Notifeed Widget
//
//  Created by Marco Salafia on 07/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding
{
    var favoriteFeed: Feed?
    var postArray: [Post]?
    
    let userDefaults = NSUserDefaults(suiteName: "group.notifeedcontainer")
    var expanded : Bool {
        get {
            return userDefaults?.boolForKey("widgetExpanded") ?? false
        }
        set {
            userDefaults?.setBool(newValue, forKey: "widgetExpanded")
            userDefaults?.synchronize()
        }
    }
    
    let expandButton = UIButton()
    let updateButton = UIButton()
    
    let defaultNumRows = 2
    let maxNumberOfRows = 4
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpExpandButton()
        setUpHeader()
    }
    
    func setUpHeader()
    {
        tableView.sectionHeaderHeight = 60
    }
    
    func setUpExpandButton()
    {
//        updateExpandButtonTitle()
//        expandButton.addTarget(self, action: "toggleExpand", forControlEvents: .TouchUpInside)        
        tableView.sectionFooterHeight = 45
    }
    
    func updateExpandButtonTitle()
    {
        let title = expanded ? NSLocalizedString("Show less", comment: "Mstra meno widget") :
            NSLocalizedString("Show More", comment: "Mostra di più widget")
        
        expandButton.setTitle(title, forState: .Normal)
    }
    
    func toggleExpand()
    {
        expanded = !expanded
        updateExpandButtonTitle()
        tableView.reloadData()
        updatePreferredContentSize()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void))
    {
        // Perform any setup necessary in order to update the view.
        favoriteFeed = getFavoriteFeed()
        postArray = favoriteFeed != nil ? scanFavoriteFeed(favoriteFeed!) : nil
        tableView.reloadData()
        self.updatePreferredContentSize()
        NSLog("ereoto")
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    func getFavoriteFeed() -> Feed?
    {
        guard let title = userDefaults?.valueForKey("favoriteFeed") as? String else
        {
            return nil
        }
        
        return FeedModel.getSharedInstance().getFeedWithTitle(title)
    }
    
    func scanFavoriteFeed(feed: Feed) -> [Post]?
    {
        let postarray = try? FeedParser().parseLink(feed.link)
        return postarray
    }
    
    // MARK: - Metodi di View
    
    func updatePreferredContentSize()
    {
        guard let posts = postArray else
        {
            preferredContentSize = CGSizeMake(0, tableView.sectionHeaderHeight)
            return
        }
        
        preferredContentSize = posts.isEmpty ? CGSizeMake(0, tableView.sectionHeaderHeight) :
                                               CGSizeMake(0, CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * tableView.rowHeight + tableView.sectionHeaderHeight + tableView.sectionFooterHeight)
        print(preferredContentSize)
    }
    
    func updateInterface()
    {
        print("Aggiorno interfaccia")
        favoriteFeed = getFavoriteFeed()
        postArray = favoriteFeed != nil ? scanFavoriteFeed(favoriteFeed!) : []
        self.updatePreferredContentSize()
        tableView.reloadData()
    }
    
    // MARK: - TableView Delegate and Datasource
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! WidgetHeaderCell
        headerCell.titleLabel.text = favoriteFeed?.title ?? "--"
        headerCell.updateButton.addTarget(self, action: "updateInterface", forControlEvents: .TouchUpInside)
        
        return headerCell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        guard let _ = postArray else { return nil }
        
        guard !postArray!.isEmpty else { return nil }
        
        let footerCell = tableView.dequeueReusableCellWithIdentifier("footerCell") as! WidgetFooterCell
        footerCell.expandButton.addTarget(self, action: "toggleExpand", forControlEvents: .TouchUpInside)
        let title = expanded ? NSLocalizedString("Show less", comment: "Mstra meno widget") :
                               NSLocalizedString("Show More", comment: "Mostra di più widget")
        footerCell.expandButton.setTitle(title, forState: .Normal)
        
        return footerCell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let posts = postArray else { NSLog("Nessun Post!"); return 0 }
        
        guard !postArray!.isEmpty else { return 0 }
        
        return min(posts.count, expanded ? maxNumberOfRows : defaultNumRows)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("wcell", forIndexPath: indexPath)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        if let post = postArray?[indexPath.row]
        {
            cell.textLabel?.text = post.title
            
            if let date = post.published
            {
                cell.detailTextLabel?.text = formatter.stringFromDate(date)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        guard let link = postArray?[indexPath.row].link else { return }

        if let url = NSURL(string: link)
        {
            self.extensionContext?.openURL(url, completionHandler: nil)
        }
    }
    
    
    
}
