//
//  MGSFeed.swift
//  Notifeed
//
//  Created by Marco Salafia on 05/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

import Foundation

class MGSFeed
{
    var title: String
    var link: String
    var creazione: String
    
    init(title: String, link: String, creazione: String)
    {
        self.title = title
        self.link = link
        self.creazione = creazione
    }
    
    convenience init()
    {
        self.init(title: "", link: "", creazione: "")
    }
}