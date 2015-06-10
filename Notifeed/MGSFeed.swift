//
//  MGSFeed.swift
//  Notifeed
//
//  Created by Marco Salafia on 05/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import Foundation

class MGSFeed : NSObject, Printable
{
    var title: String
    var link: String
    var creazione: NSDate
    
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
    
    convenience override init()
    {
        self.init(title: "", link: "", creazione: NSDate())
    }
    
}