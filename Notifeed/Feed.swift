//
//  Feed.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
//TODO: Levare questo commento
//Era conforme a CustomStringConvertible ??? Non so cosa sia, lo avrà messo il convertitore
//automatico a Swift 2

class Feed : NSObject
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
