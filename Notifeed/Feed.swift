//
//  Feed.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation

enum FeedCategory : String
{
    case Technology = "technology"
}

class Feed : NSObject
{
    var title: String
    var link: String
    var creazione: NSDate
    var position: Int?
    var category: FeedCategory?
    
    override var description: String
        {
        get {
            return self.title + ": " + link + "\n"
        }
    }
    
    init(title: String, link: String, creazione: NSDate)
    {
        self.title = title
        self.link = link
        self.creazione = creazione
    }
    
    init(title: String, link: String, creazione: NSDate, position: Int)
    {
        self.title = title
        self.link = link
        self.creazione = creazione
        self.position = position
    }
    
    init(title: String, link: String, creazione: NSDate, position: Int, category: FeedCategory)
    {
        self.title = title
        self.link = link
        self.creazione = creazione
        self.position = position
        self.category = category
    }
    
    convenience override init()
    {
        self.init(title: "", link: "", creazione: NSDate())
    }
    
}

func == (left: Feed, right: Feed) -> Bool
{
    return left.title == right.title
}

func != (left: Feed, right: Feed) -> Bool
{
    return left.title != right.title
}
